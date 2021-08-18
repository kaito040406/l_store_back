namespace :delete_chat_message do
  desc "Delete chat data more than 3 months ago"
  task delete_chat_message: :environment do
    DeleteChat::DeleteChat.batch
  end
end
