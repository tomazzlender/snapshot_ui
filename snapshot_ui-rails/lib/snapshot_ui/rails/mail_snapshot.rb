# frozen_string_literal: true

require "snapshot_ui/snapshot"

module SnapshotUI
  module Rails
    # Captures an ActionMailer / Mail message as a snapshot.
    #
    # The whole email is serialized to its RFC-822 form (which keeps every MIME
    # part — both the HTML and the plain-text alternatives, and any attachments),
    # so a single stored string round-trips to both views. BCC is stored
    # separately because it is not part of the serialized message.
    module MailSnapshot
      TYPE = "mail"

      module_function

      def persist(mail, context:)
        message = to_mail_message(mail)

        SnapshotUI::Snapshot.persist(
          snapshotee: nil,
          context: context,
          type: TYPE,
          type_data: {
            message: message.to_s,
            bcc: Array(message.bcc),
            mailer: mailer_name(mail),
            action: action_name(mail)
          }
        )
      end

      # ActionMailer hands tests a MessageDelivery; #message is the underlying
      # Mail::Message. A bare Mail::Message is accepted too.
      def to_mail_message(mail)
        mail.respond_to?(:message) ? mail.message : mail
      end

      # The mailer class name. ActionMailer::MessageDelivery stores it as
      # @mailer_class; #mailer_class is unreliable across Rails versions (on some
      # it returns MessageDelivery itself), so prefer the ivar.
      def mailer_name(mail)
        mailer_class =
          if mail.instance_variable_defined?(:@mailer_class)
            mail.instance_variable_get(:@mailer_class)
          elsif mail.respond_to?(:mailer_class)
            mail.mailer_class
          end

        (mailer_class || mail.class).name
      end

      # ActionMailer::MessageDelivery stores the action as @action (a Symbol);
      # some versions/objects expose #action_name. Fall back gracefully.
      def action_name(mail)
        if mail.respond_to?(:action_name)
          mail.action_name
        elsif mail.instance_variable_defined?(:@action)
          mail.instance_variable_get(:@action)&.to_s
        end
      end
    end
  end
end
