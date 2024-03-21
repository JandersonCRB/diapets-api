namespace :insulins do
  desc 'Notify insulins'
  task notify: :environment do
    Rails.logger = Logger.new(STDOUT)
    # log queries
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    Pets::NotifyInsulins.call
  end

end
