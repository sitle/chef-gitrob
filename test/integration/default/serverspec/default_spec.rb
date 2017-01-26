require 'serverspec'

describe command('ruby -v') do
  its(:stdout) { should match "2.3" }
end
