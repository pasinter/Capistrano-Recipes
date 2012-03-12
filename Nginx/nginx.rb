Capistrano::Configuration.instance(:must_exist).load do

namespace :nginx do
    desc "Restart nginx"
    task :restart, :roles => [:app], :max_hosts => 1 do
      sudo "/etc/init.d/nginx restart"
    end
end

end # Capistrano::Configuration.instance(:must_exist).load do