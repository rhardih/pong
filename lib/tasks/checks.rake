namespace :checks do
  desc "Migrate the 'available' property to status"
  task migrate_availablity: :environment do
    checks = Check.where(available: true)

    puts "Updating #{checks.count} checks"

    ActiveRecord::Base.transaction { checks.each(&:up!) }
  end
end
