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
user node['gitrob']['database_user'] do
  action :create
  comment 'Gitrob User'
  gid 'users'
  home '/home/' + node['gitrob']['database_user']
  shell '/bin/bash'
  password node['gitrob']['database_password']
  supports manage_home: true
end

%w{ruby2.3 ruby2.3-dev}.each do |pkg|
  package pkg
end

gem_package 'github_api' do
  version '0.13'
end
gem_package 'gitrob' do
  version node['gitrob']['version']
end

execute 'gitrob_agree' do
  command "echo user accepted > /var/lib/gems/2.3.0/gems/gitrob-#{node['gitrob']['version']}/agreement.txt"
  action :run
  not_if { ::File.exist?("/var/lib/gems/2.3.0/gems/gitrob-#{node['gitrob']['version']}/agreement.txt)") }
end

node.set['postgresql']['password']['postgres'] = node['gitrob']['pgsql_password']

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

template '/home/' + node['gitrob']['database_user'] + '/.gitrobrc' do
  source 'gitrobrc.erb'
  owner node['gitrob']['database_user']
  group 'users'
  mode '0644'
end

systemd_service 'gitrob' do
  description 'gitrob'
  after %w{ network.target }
  requires %w{ network.target }
  user 'gitrob'
  working_directory '/home/gitrob'
  install do
    wanted_by 'multi-user.target'
  end
  service do
    type 'simple'
    exec_start '/usr/local/bin/gitrob  server  --bind-address=0.0.0.0 --port=8080'
    restart 'on-failure'
    restart_sec '10'
  end
end
