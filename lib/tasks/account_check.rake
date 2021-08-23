namespace :account_check do
  desc "Check the official line information"
  task account_check: :environment do
    AccountCheck::AccountCheck.batch
  end
end
