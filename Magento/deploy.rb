require "capistrano/ext/multistage"
require "railsless-deploy"

default_run_options[:pty] = true

set :stages, ["staging", "production"]
set :default_stage, "staging"

set :application, "{YOUR APPLICATION NAME}"
set :repository, "git@github.com:{USER}/{REPOSITORY}.git"
set :scm, :git

set :user, "www-data"
set :use_sudo, false
set :group_writable, true

set :deploy_to, "/var/www/#{application}"
set :keep_releases, 3
set :deploy_via, :remote_cache
set :scm_verbose, true


# Magento folders
set :app_symlinks, ["/media", "/var", "/sitemaps"]
set :app_shared_dirs, ["/app/etc", "/sitemaps", "/media", "/var"]
set :app_shared_files, ["/app/etc/local.xml"]


namespace :deploy do
  task :migrate do; end
  task :migrations do; end
  task :start do; end
  task :stop do; end
  task :restart do; end
end



namespace :mage do

  desc "Clears the cache"
  task :cacheclear, :roles => :app do
    set :user, "root"
    #set :use_sudo, true
    sudo  "service nginx stop"
    sudo  "rm -rf #{latest_release}/web/var/cache/*"
    sudo  "service nginx start"
  end

  desc "Reindexes all data"
  task :reindex, :roles => :app do
    run "php #{latest_release}/web/shell/indexer.php reindexall"
  end

  desc <<-DESC
      Prepares one or more servers for deployment of Magento. Before you can use any \
      of the Capistrano deployment tasks with your project, you will need to \
      make sure all of your servers have been prepared with `cap deploy:setup'. When \
      you add a new server to your cluster, you can easily run the setup task \
      on just that server by specifying the HOSTS environment variable:

        $ cap HOSTS=new.server.com mage:setup

      It is safe to run this task on servers that have already been set up; it \
      will not destroy any deployed revisions or data.
    DESC
  task :setup, :roles => :web, :except => { :no_release => true } do
    if app_shared_dirs
      app_shared_dirs.each { |link| run "#{try_sudo} mkdir -p #{shared_path}/web#{link} && chmod 777 #{shared_path}#{link}" }
    end
    if app_shared_files
      app_shared_files.each { |link| run "#{try_sudo} touch #{shared_path}/web#{link} && chmod 777 #{shared_path}#{link}" }
    end
  end

  desc <<-DESC
    Touches up the released code. This is called by update_code \
    after the basic deploy finishes.

    Any directories deployed from the SCM are first removed and then replaced with \
    symlinks to the same directories within the shared location.
  DESC
  task :finalize_update, :roles => :web, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    if app_symlinks
      # Remove the contents of the shared directories if they were deployed from SCM
      app_symlinks.each { |link| run "#{try_sudo} rm -rf #{latest_release}/web#{link}" }
      # Add symlinks the directoris in the shared location
      app_symlinks.each { |link| run "ln -nfs #{shared_path}#{link} #{latest_release}/web#{link}" }
    end

    if app_shared_files
      # Remove the contents of the shared directories if they were deployed from SCM
      app_shared_files.each { |link| run "#{try_sudo} rm -rf #{latest_release}/web#{link}" }
      # Add symlinks the directoris in the shared location
      app_shared_files.each { |link| run "ln -s #{shared_path}#{link} #{latest_release}/web#{link}" }
    end
  end 

end

after "deploy:finalize_update", "mage:reindex"
after 'deploy:setup', 'mage:setup'
after 'deploy:finalize_update', 'mage:finalize_update'