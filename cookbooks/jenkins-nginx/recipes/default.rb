execute 'key2' do
command 'sudo wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -'
end

execute 'key3' do
command "sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'"
end

execute 'key4' do
command "sudo apt-get -f install"
end

execute 'key5' do
command "sudo apt-get update" 
end

package "openjdk-7-jre" 
package "openjdk-7-jdk"

execute 'key' do
command 'sudo dpkg --configure -a'
end

package "jenkins"

service "jenkins" do
  supports [:stop, :start, :restart]
  action [:start, :enable]
end

package 'nginx' do
action :install
end
service "nginx" do
 supports status: true
 action [:enable, :start]
end


execute 'key6' do
command 'cat /file2 >> /etc/default/jenkins'
end

execute 'key7' do
command 'cat /file1 > /etc/nginx/sites-enabled/default'
end  















