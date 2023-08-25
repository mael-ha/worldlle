namespace :worldlle do
    desc "run"
    task run: :environment do
        InstagramPostJob.perform_now
        # WorldlleBot.new.call
    end

    task time: :environment do
        puts "Server time: #{Time.current}"
    end
end