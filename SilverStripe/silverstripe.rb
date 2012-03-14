Capistrano::Configuration.instance(:must_exist).load do


namespace :silverstripe do

    namespace :dev do
        desc "Build/rebuild this environment. Call this whenever you have updated your project sources"
        task :build do
            run "#{latest_release}/silverstripe/sapphire/sake dev/build"
        end

        desc "Rebuild the static cache, if you're using StaticPublisher"
        task :buildcache do
            run "#{latest_release}/silverstripe/sapphire/sake dev/buildcache"
        end
        
    end

    namespace :cache do
        desc "Clear cache files"
        task :clear do
            run "rm -rf #{shared_path}/silverstripe-cache/*"
        end

        desc "Fix permissions on your cache files"
        task :fix_perms do
            sudo "chown -R www-data:www-data #{shared_path}/silverstripe-cache"
            sudo "chmod -R 777 #{shared_path}/silverstripe-cache"
        end
    end


    namespace :deploy do
        desc "Silverstripe specific setup"
        task :setup do
            run "mkdir #{shared_path}/assets"
            run "mkdir #{shared_path}/silverstripe-cache"
            run "touch #{shared_path}/_ss_environment.php"
        end

        desc "Create shared symlinks"
        task :symlink_shared do
            # create symlink to shared assets
            run "rm -rf #{latest_release}/silverstripe/assets"
            run "ln -nfs #{shared_path}/assets #{latest_release}/silverstripe/assets"

            # create symlink to shared silverstripe-cache
            run "rm -rf #{latest_release}/silverstripe/silverstripe-cache"
            run "ln -nfs #{shared_path}/silverstripe-cache #{latest_release}/silverstripe/silverstripe-cache"

            # create symlink to shared _ss_environment.php
            run "ln -fs #{shared_path}/_ss_environment.php #{latest_release}/_ss_environment.php"
        end
    end


    namespace :project do
        desc "Puts the site into 503 maintenance mode"
        task :disable, :roles => :web do
            if previous_release
                logger.important "Putting site in maintenance"
                run "echo '<h1>Site Maintenance</h1><p>We're running a few upgrades to site right now and we'll be back online soon</p>' > #{current_release}/maintenance.php"
            end
        end

        desc "Removes the 503 maintenance mode"
        task :enable, :roles => :web do
            if previous_release
                logger.important "Removing site maintenance mode"
                run "rm #{current_release}/maintenance.php"
            end
        end
    end

end

# run silverstripe specific setup
after 'deploy:setup', 'silverstripe:deploy:setup'

# run dev/build after code update
after "deploy:update_code", "silverstripe:dev:build"

# create shared symlink's
after "deploy:update_code", "deploy:symlink_shared"


end # Capistrano::Configuration.instance(:must_exist).load do