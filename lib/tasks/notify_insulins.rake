# frozen_string_literal: true

namespace :insulins do
  desc 'Notify insulins'
  task notify: :environment do
    Rails.logger = Logger.new($stdout)
    # log queries
    ActiveRecord::Base.logger = Logger.new($stdout)

    Pets::NotifyInsulins.call
  end
end
