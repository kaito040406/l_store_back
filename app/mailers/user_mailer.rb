class UserMailer < ActionMailer::Base
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.registration_confirmation.subject
  #
  def registration_confirmation(user)
    @user = user
    mail(
      :from => '"L-STORE" <info@l-store.jp>',
      :to => @user.email, 
      :subject => 'ご登録ありがとうございます')
  end
end