namespace :delete_message do
  desc "Delete message data more than 3 months ago"
  task delete_message: :environment do
    DeleteMessage::DeleteMessage.batch
  end
end
