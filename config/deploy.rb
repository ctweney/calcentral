require "rvm/capistrano"
require "bundler/capistrano"
require "config/settings/server_config"

settings = ServerConfig.get_settings(Dir.home + "/.calcentral_config/server_config.yml")

set :application, "Calcentral"

role(:sandbox_dev_host) {
  settings.sandbox.servers << { :branch => settings.sandbox.branch, :project_root => settings.sandbox.root }
}
role(:calcentral_dev_host) { settings.dev.servers }
set :user, settings.common.user
set :branch, settings.common.branch
set :project_root, settings.common.root

# Calcentral_dev is the IST configured server setup we have for calcentral-dev.berkeley.edu. It
# currently consists of 3 app servers, a shared postgres instance, ? memcache servers and ? elasticsearch
# servers.
namespace :calcentral_dev do
  desc "Update and restart the calcentral_dev machine"
  task :update, :roles => :calcentral_dev_host do
    # Take everything offline first.
    script_folder = project_root + ("/script")
    run "cd #{script_folder}; ./stop-trinidad.sh"
    # Run db migrate on the first app server
    servers = find_servers_for_task(current_task)

    transaction do
      servers.each_with_index do |server, index|
        run "cd #{script_folder}; ./update-build.sh", :hosts => server
        if (index == 0)
          logger.debug "---- Server: #{server.host} running migrate in transaction on offline app servers"
          run "cd #{script_folder}; ./migrate.sh", :hosts => server
        end
      end
    end
    servers.each do |server|
      run "cd #{script_folder}; ./start-trinidad.sh", :hosts => server
      run "rm /var/www/html/calcentral/calcentral-in-maintenance", :hosts => server
    end
  end
end

# Sandbox_dev is the sandbox testing server that we have setup in 117. It sits on a old macbook
# and runs headless, used primarily for demos and other testing/experimental purposes.
namespace :sandbox_dev_host do
  desc "Update and restart the sandbox_dev machine"
  task :update, :roles => :sandbox_dev_host do
    rake = fetch(:rake, 'bundle exec rake')
    rails_env = fetch(:rails_env, 'production')
    find_servers_for_task(current_task).each do |server|
      run "cd #{server.options[:project_root].concat('/script')}; ./stop-trinidad.sh", :hosts => server
      run "cd #{server.options[:project_root].concat('/script')}; ./update-build.sh", :hosts => server
      run "cd #{server.options[:project_root].concat('/script')}; ./migrate.sh", :hosts => server
      run "cd #{server.options[:project_root].concat('/script')}; ./start-trinidad.sh", :hosts => server
    end
  end
end
