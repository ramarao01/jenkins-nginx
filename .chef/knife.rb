# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "ramarao01"
client_key               "#{current_dir}/ramarao01.pem"
validation_client_name   "chefjen-validator"
validation_key           "#{current_dir}/chefjen-validator.pem"
chef_server_url          "https://api.chef.io/organizations/chefjen"
cookbook_path            ["#{current_dir}/../cookbooks"]
