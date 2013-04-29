include_recipe "git"
include_recipe "python"
include_recipe "postgresql::server"
include_recipe "postgresql::libpq"
include_recipe "java"

USER = node[:user]
HOME = "/home/#{USER}"
ENV['VIRTUAL_ENV'] = "#{HOME}/pyenv"
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src/ckan"

# Create user
user USER do
  home HOME
  supports :manage_home => true
end

# Install Python
python_virtualenv ENV['VIRTUAL_ENV'] do
  interpreter "python2.7"
  owner USER
  group USER
  options "--no-site-packages"
  action :create
end

# Install CKAN Package
python_pip "git+https://github.com/okfn/ckan.git#egg=ckan" do
  user USER
  group USER
  virtualenv ENV['VIRTUAL_ENV']
  options "-e"
  action :install
end

# Install CKAN's requirements
python_pip "#{SOURCE_DIR}/pip-requirements.txt" do
  user USER
  group USER
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

# Create Database
pg_user "ckanuser" do
  privileges :superuser => true, :createdb => true, :login => true
  password "pass"
end

pg_database "ckantest" do
  encoding    "utf8"
  locale      "en_US.utf8"
  owner       "ckanuser"
  template    "template0"
end

pg_database "ckan_dev" do
  encoding    "utf8"
  locale      "en_US.utf8"
  owner       "ckanuser"
  template    "template0"
end

# Install and configure Solr
package "solr-jetty"
template "/etc/default/jetty" do
  variables({
    :java_home => node["java"]["java_home"]
  })
end
execute "setup solr's schema" do
  command "sudo ln -f -s #{SOURCE_DIR}/ckan/config/solr/schema-2.0.xml /etc/solr/conf/schema.xml"
  action :run
end
service "jetty" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

# Create configuration file
execute "make paster's config file and setup solr_url and ckan.site_id" do
  user USER
  cwd SOURCE_DIR
  command "paster make-config ckan development.ini --no-interactive && sed -i -e 's/.*solr_url.*/solr_url=http:\\/\\/127.0.0.1:8983\\/solr/;s/.*ckan\\.site_id.*/ckan.site_id=vagrant_ckan/' development.ini"
  creates "#{SOURCE_DIR}/development.ini"
end

# Generate database
execute "create database tables" do
  user USER
  cwd SOURCE_DIR
  command "paster --plugin=ckan db init"
end

# Run tests
python_pip "#{SOURCE_DIR}/pip-requirements-test.txt" do
  user USER
  group USER
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

execute "running tests with SQLite" do
  user USER
  cwd SOURCE_DIR
  command "nosetests --ckan ckan"
end
