require File.expand_path('../../test_helper', __FILE__)

class JournalTest < ActiveSupport::TestCase

  def setup
    @issue = Issue.first
    @project = @issue.project
    @user = User.first
  end

  def test_if_changing_the_description_is_sending_proper_mail
    @issue.init_journal(@user, '1')
    @issue.description = '@userrr hej'
    @issue.save
    mail = ActionMailer::Base.deliveries.last
    puts '#'*120
    puts mail.to.inspect
    assert_equal mail.to.first, User.find_by(login: 'userrr').mail
    assert mail.subject.include?("You were mentioned in: #{@issue.subject}")
  end

end
