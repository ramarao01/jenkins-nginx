package 'nginx' do
action :install
end
service "nginx" do
 supports status: true
 action [:enable, :start]
end

