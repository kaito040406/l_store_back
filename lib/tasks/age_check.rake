namespace :age_check do
  desc "Update line user age"
  task age_check: :environment do
    AgeCheck::AgeCheck.batch
  end
end
