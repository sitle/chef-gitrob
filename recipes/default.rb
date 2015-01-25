#
# Cookbook Name:: gitrob
# Recipe:: default
#
# Copyright (C) 2015 Leonard TAVAE
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.set['postgresql']['password']['postgres'] = node['gitrob']['pgsql_password']

if node['gitrob']['accept_agreement'].nil?
  fail 'You need to accept the agreement first !!!'
end

# install the database software
include_recipe 'postgresql::server'

# create the database
include_recipe 'database::postgresql'

postgresql_connection_info = {
  host: '127.0.0.1',
  port: 5432,
  username: 'postgres',
  password: node['gitrob']['pgsql_password']
}

postgresql_database node['gitrob']['database'] do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user node['gitrob']['database_user'] do
  connection postgresql_connection_info
  password node['gitrob']['database_password']
  action :create
end

postgresql_database_user node['gitrob']['database_user'] do
  connection postgresql_connection_info
  password node['gitrob']['database_password']
  database_name node['gitrob']['database']
  action :grant
end

%w(postgresql-server-dev-9.3 ruby-dev).each do |package|
  package package do
    action :install
  end
end

user node['gitrob']['database_user'] do
  action :create
  comment 'Gitrob User'
  gid 'users'
  home '/home/' + node['gitrob']['database_user']
  shell '/bin/bash'
  password node['gitrob']['database_password']
  supports manage_home: true
end

bash 'Install Gitrob' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  gem install gitrob -v #{node['gitrob']['version']} --no-ri --no-rdoc
  chown -R #{node['gitrob']['database_user']} /var/lib/gems/1.9.1/gems/gitrob-#{node['gitrob']['version']}
  EOH
  not_if { ::File.exist?('/usr/local/bin/gitrob') }
end

execute 'Agreement set' do
  command "echo user accepted > /var/lib/gems/1.9.1/gems/gitrob-#{node['gitrob']['version']}/agreement"
  action :run
  not_if { ::File.exist?("/var/lib/gems/1.9.1/gems/gitrob-#{node['gitrob']['version']}/agreement)") }
end

template '/home/' + node['gitrob']['database_user'] + '/.gitrobrc' do
  source 'gitrobrc.erb'
  owner node['gitrob']['database_user']
  group 'users'
  mode '0644'
end

node['gitrob']['organizations'].each do |organization|
  execute 'Checking ' + organization do
    command 'su ' + node['gitrob']['database_user'] + ' -c "gitrob -o ' + organization + ' --no-server"'
    action :run
    not_if node['gitrob']['enable_check']
  end
end

execute 'Starting server...' do
  command 'su ' + node['gitrob']['database_user'] + ' -c "gitrob -s -b ' + node['gitrob']['bind_address'] + '" &'
  action :run
end
