Capistrano::Configuration.instance(:must_exist).load do

require "httparty"

# set :newrelic_licence_key, "000000000000000000000"
# set :newrelic_application_id, "00000"

_cset(:newrelic_licence_key) { abort "Please specify the licence key of your New Relic account, set :newrelic_licence_key, '0000000000000000'" }
_cset(:newrelic_application_id) { abort "Please specify the New Relic application id, set :newrelic_application_id, '000000'" }

namespace :newrelic do

    desc "Notify New Relic of a new deploy"
        task :notify, :except => { :no_release => true } do
        rails_env = ENV['DEPLOYED_TO'] || fetch(:newrelic_env, fetch(:stage, "prod"))
        rails_env = "prod" if (rails_env.to_s == "prod")
        local_user = ENV['USER'] || ENV['USERNAME']
        puts "Notifying New Relic of Deploy"
        resp = HTTParty.post("https://rpm.newrelic.com/deployments.xml", :headers => {"x-license-key" => "#{newrelic_licence_key}"}, :body => "deployment[application_id]=#{newrelic_application_id}&deployment[user]=#{local_user}&deployment[revision]=#{current_revision}")
        puts resp.inspect
        puts "New Relic Notification Complete"
    end

end

end # Capistrano::Configuration.instance(:must_exist).load do