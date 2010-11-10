require "bundler/capistrano"

set :deploy_via, :copy
set :application, "medical"
set :repository,  "git@git.26am.com:medical.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

server = '10.1.50.51'
role :web, server                          # Your HTTP server, Apache/etc
role :app, server                          # This may be the same as your `Web` server
role :db,  server, :primary => true # This is where Rails migrations will run
set :user, 'root'
set :password, 'vfurnace'
set :deploy_to, "/opt/medical"
default_run_options[:pty] = true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  after "deploy:update_code", "deploy:medical"
  task :medical, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
    run <<-CMD
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/snaps #{release_path}/public/snaps &&
      chown -R apache.apache #{release_path}
    CMD
  end
end
