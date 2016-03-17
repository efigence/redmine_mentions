require File.expand_path('../../test_helper', __FILE__)

class JournalTest < ActiveSupport::TestCase

  def setup
    @issue = Issue.first
    @project = @issue.project
    @user = User.first
    ActionMailer::Base.deliveries.clear
  end

  def test_if_changing_the_description_is_sending_proper_email
    layout_test(:mail_2) { @issue.description = '@userrr hej' }
  end

  def test_if_changing_the_description_is_not_sending_email
    @issue.init_journal(@user, '1')
    @issue.description = '@userrr hejdsfgasgg'
    @issue.save
    ActionMailer::Base.deliveries.clear
    layout_test(:mail_0) { @issue.description = '@userrr hej' }
  end

  def test_if_changing_the_tracker_is_not_sending_email
    layout_test(:mail_1) { @issue.tracker_id = 3 }
  end

  def test_if_changing_the_subject_is_not_sending_email
    layout_test(:mail_1) { @issue.subject = 'userrr hej' }
  end

  def test_if_changing_the_status_is_not_sending_email
    layout_test(:mail_1) { @issue.status_id = 2 }
  end

  private

  def layout_test(mail_send, &var_change)
    @issue.init_journal(@user, '1')
    yield
    case mail_send
    when :mail_0
      assert_no_difference('ActionMailer::Base.deliveries.size') do
        @issue.save
      end
    when :mail_1
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        @issue.save
      end
    when :mail_2
      assert_difference('ActionMailer::Base.deliveries.size', 2) do
        @issue.save
      end
    end
  end

end
