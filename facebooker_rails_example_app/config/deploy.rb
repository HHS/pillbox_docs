
set :application, "karate_poke"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache
set :repository, "git@github.com:mmangino/karate_poke.git"



set :deploy_to, '/var/www/apps/karate_poke'
set :user, 'elevateddeploy'
set :use_sudo, false
role :web, "production-1.elevatedrails.com"
role :app, "production-1.elevatedrails.com"
role :db,  "production-1.elevatedrails.com", :primary => true

desc "Deploy, migrate and update"
namespace :deploy do
  task :full do
    transaction do
      update_code
      web.disable
      copy_database_yml
      copy_facebooker_yml
      symlink
      migrate
    end

    restart
    web.enable
    cleanup
  end
end

task :copy_facebooker_yml, :roles =>:web do
  run "cp #{shared_path}/facebooker.yml #{release_path}/config/"
end

task :copy_database_yml, :roles =>:web do
  run "cp #{shared_path}/database.yml #{release_path}/config/"
end

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
