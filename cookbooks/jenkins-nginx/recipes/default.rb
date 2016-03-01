#Installing Jenkins and Nginx as reverse proxy with ssl certificate

#1st command in bash block downloads the key from the http link and adds it to apt-key list
#2nd command adds link(from which jenkins has to be downloaded) to apt sources.list
#3rd command will redownload broken apt packages if any
bash 'exe' do
code <<-EOH
sudo wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get -f install
sudo apt-get update 
EOH
end

#Download dependency packages for jenkins like jre and jdk
package "openjdk-7-jre" 
package "openjdk-7-jdk"


#This will remove any broken dpkg packages
execute 'dpkg' do
command 'sudo dpkg --configure -a'
end


#install jenkins package
package "jenkins"

#It will enable and start jenkins package
service "jenkins" do
  supports [:stop, :start, :restart]
  action [:enable, :start]
end

#install nginx package
package 'nginx'

#It will enable and install nginx package
service "nginx" do
 supports status: true
 action [:enable, :start]
end

#Modify default Nginx configuration file for reverse proxy settings
#Give permissions to modify the file
cookbook_file '/etc/nginx/sites-enabled/default' do
source 'default'
cookbook 'jenkins-nginx'
manage_symlink_source true
owner 'root'
group 'root'
mode '0755'
action:create
end


#Comment already existed JENKINS_ARGS and add new line  
bash 'key' do
code <<-EOH
sudo chmod 0755 /etc
sed -i 's/JENKINS_ARGS/#JENKINS_ARGS/' /etc/default/jenkins 
echo 'JENKINS_ARGS="--webroot=/var/cache/jenkins/war --httpListenAddress=127.0.0.1 --httpPort=$HTTP_PORT -ajp13Port=$AJP_PORT"' >> /etc/default/jenkins
EOH
end



keyfile = '/etc/nginx/cert.key'
crtfile = '/etc/nginx/cert.crt'
sslconfig = '/etc/nginx/sslcert.conf'

#If any file doesn't exist it will create all the three files 


unless File.exists?(keyfile) && File.exists?(crtfile) && File.exists?(sslconfig)

#Generate a 2048-bit RSA key and will store into cert.key file
  file keyfile do
    owner "root"
    group "root"
    mode "0644"
    content `/opt/chefdk/embedded/bin/openssl genrsa 2048`
    not_if { File.exists?(keyfile) }
  end
#SSL configuration file which will store all the private data
  file sslconf do
    owner "root"
    group "root"
    mode "0644"
    not_if { File.exists?(sslconfig) }
    content <<-EOH
  [ req ]
  distinguished_name = req_distinguished_name
  prompt = no
  [ req_distinguished_name ]
  C                      = #{node['nginx']['ssl_country_name']}
  ST                     = #{node['nginx']['ssl_state_name']}
  L                      = #{node['nginx']['ssl_locality_name']}
  O                      = #{node['nginx']['ssl_company_name']}
  OU                     = #{node['nginx']['ssl_organizational_unit_name']}
  CN                     = #{node['nginx']['server_name']}
  emailAddress           = #{node['nginx']['ssl_email_address']}
  EOH
  end

#Generate a selfsigned Certificate but it will give some browser warnings,need to get an officially signed certificate to getrid of warnings 
  ruby_block "create crtfile" do
    block do
      r = Chef::Resource::File.new(crtfile, run_context)
      r.owner "root"
      r.group "root"
      r.mode "0755"
      r.content `/opt/chefdk/embedded/bin/openssl req -config '#{sslconfig}' -new -x509 -nodes -sha1 -days 3650 -key #{keyfile}`
      r.not_if { File.exists?(crtfile) }
      r.run_action(:create)
    end
  end
end


service "nginx" do
 supports status: true
 action [:enable, :start]
end
service "jenkins" do
  supports [:stop, :start, :restart]
  action [:enable, :start]
end
