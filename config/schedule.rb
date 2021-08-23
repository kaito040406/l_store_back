# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# 出力先のログファイルの指定
set :output, 'log/cron_log.log'
# ジョブの実行環境の指定
set :environment, :production

# 1日１回午前1時に実行
every 1.day, :at => '1:00' do
  # 90日以上前のチャットデータ削除
  rake 'account_check:account_check'
end

# 1日１回午前2時に実行
every 1.day, :at => '2:00' do
  # 90日以上前のチャットデータ削除
  rake 'delete_chat_message:delete_chat_message'
end

# 1日１回午前3時に実行
every 1.day, :at => '3:00' do
  # 90日以上前の一斉送信データ削除
  rake 'delete_message:delete_message'
end