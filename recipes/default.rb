#
# Cookbook Name:: hhvm_laravel
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


execute 'update ubuntu' do
  command 'apt-get update'
end

package 'unzip vim git-core curl wget build-essential python-software-properties' do
  action :install
end

execute 'install hhvm - add key' do
  command 'apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449'
end

execute 'install hhvm - add source' do
  command "add-apt-repository 'deb http://dl.hhvm.com/ubuntu trusty main'"
end

execute 'install nginx' do
  command "add-apt-repository -y ppa:nginx/stable"
end

execute 'update ubuntu' do
  command 'apt-get update'
end

package 'nginx' do
  action :install
end

package 'hhvm' do
  action :install
end

execute 'installs fastcgi' do
  cwd '/usr/share/hhvm/'
  command 'sh install_fastcgi.sh'
end

execute 'start hhvm on boot' do
  command 'update-rc.d hhvm defaults'
end

service 'hhvm' do
  action [ :enable, :restart ]
end

directory '/srv/www' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  recursive true
  action :create
end

cookbook_file '/etc/nginx/sites-available/laravel' do
  not_if { File.exist?("/etc/nginx/sites-available/laravel") }
  source 'laravel'
  mode '0644'
end

execute 'install composer' do
  not_if { File.exist?("/usr/local/bin/composer") }
  command 'curl -sS https://getcomposer.org/installer | php'
end

execute 'move composer to global folder' do
  not_if { File.exist?("/usr/local/bin/composer") }
  command 'mv composer.phar /usr/local/bin/composer'
end

execute 'install laravel' do
  command 'composer create-project laravel/laravel laravel'
  not_if { File.exist?("/srv/www/laravel") }
  cwd '/srv/www/'
end

execute 'remove default nginx config' do
  only_if { File.exist?("/etc/nginx/sites-enabled/default") }
  command 'rm /etc/nginx/sites-enabled/default'
end

execute 'symlink laravel' do
  not_if { File.exist?("/etc/nginx/sites-enabled/laravel") }
  command 'ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel'
end

# using the execute here because the chef doesn't apply ownership to sub directories

execute 'permission change' do
    command 'chown -R www-data:www-data laravel'
      cwd '/srv/www/'
end

directory "/srv/www/laravel" do
    mode '0755'
      recursive true
end

service 'nginx' do
    action [ :enable, :restart ]
end


