default_run_options[:pty] = true
require 'bundler/capistrano'
set :application, "demoapp"
set :repository, "/Users/George/demoapp"
set :deploy_to, "/var/www/#{application}" #path to your app on the production server 

set :scm, :git
set :branch, "master"
set :deploy_via, :copy
set :shallow_clone, 1

set :user, "deploy"
set :password, "secret"
set :use_sudo, "false"

set :mysql_user, "deploy" #this is the mysql user we created
set :mysql_password, "secret"

set :domain, 'youzhaole.com'
role :web, domain
role :app, domain
role :db,  domain, :primary => true

after "deploy:restart", "deploy:cleanup"

#Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:setup", "db_yml:create"
after "deploy:update_code", "db_yml:symlink"

namespace :db_yml do
  desc "Create database.yml in shared path" 
  task :create do
    config = {
              "production" => 
              {
                "adapter" => "mysql2",
                "socket" => "/var/run/mysqld/mysqld.sock",
                "username" => mysql_user,
                "password" => mysql_password,
                "database" => "#{application}_production"
              }
            }
    put config.to_yaml, "#{shared_path}/database.yml"
  end

  desc "Make symlink for database.yml" 
  task :symlink do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml" 
  end
end
