namespace :worldlle do
    desc "run"
    task run: :environment do
        WorldlleBot.new.call
    end
end