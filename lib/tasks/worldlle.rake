namespace :worldlle do
    desc "run"
    task run: :environment do
        WorldlleBot.new.call
    end

    task time: :environment do
        puts "Server time: #{Time.current}"
    end
end