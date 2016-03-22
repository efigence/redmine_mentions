module RedmineMentions
  module JournalPatch
    def self.included(base)
      base.class_eval do
        after_create :send_mail

        def send_mail
          if journalized.is_a?(Issue)
            issue = journalized
            project = journalized.project
            users = project.users.to_a.delete_if { |u| (u.type != 'User') }
            users_regex = users.collect { |u| "#{Setting.plugin_redmine_mentions['trigger']}#{u.login}" }.join('|')
            regex = Regexp.new('\B(' + users_regex + ')\b')
            mentioned_users = notes.try(:scan, regex)
            unless details.empty?
              mentioned_users += details.last.value.try(:scan, regex)
              mentioned_users -= details.last.old_value.try(:scan, regex) unless mentioned_users.empty?
            end
            unless mentioned_users.empty?
              mentioned_users.each do |mentioned_user|
                username = mentioned_user.first[1..-1]
                if user = User.find_by_login(username)
                  MentionMailer.notify_mentioning(issue, self, user).deliver
                end
              end
            end
          end
        end
      end
    end
  end
end
