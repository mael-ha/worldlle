env :GEM_PATH, '/usr/local/bundle' # defines where to find rake command
set :output, '/var/log/cron.log' # log location
job_type :rake, "cd :path && bundle exec rake :task --silent :output"


every 1.minute do
    # this will log in cron.log as defined above.
    rake 'log_to_console'
end
# every 1.day, at: '06:40 am' do
#     rake 'log_to_console'
#     rake "worldlle:run"
# end


# We override rake job type, as we don't want envrinoment specific task

# runs every minute