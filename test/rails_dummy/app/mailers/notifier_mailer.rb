# frozen_string_literal: true

class NotifierMailer < ActionMailer::Base
  default from: "app@example.test"

  # Multipart: both an HTML and a plain-text alternative, plus an attachment.
  def welcome(name = "Gardener")
    @name = name
    attachments["welcome.txt"] = "Welcome aboard, #{name}!"
    mail(to: "#{name.downcase}@example.test", cc: "team@example.test", subject: "Welcome to the waiting list") do |format|
      format.html
      format.text
    end
  end

  # HTML-only email.
  def html_only
    mail(to: "gardener@example.test", subject: "HTML only") do |format|
      format.html
    end
  end

  # A richly styled multipart receipt with two attachments.
  def receipt
    @order = {id: "GRD-2048", total: "$36.00", items: [["Tomato seedlings", "$12.00"], ["Compost 20L", "$18.00"], ["Delivery", "$6.00"]]}
    attachments["invoice-GRD-2048.pdf"] = "%PDF-1.4 fake invoice bytes"
    attachments["terms.txt"] = "Terms and conditions apply."
    mail(to: "ada@example.test", cc: "orders@example.test", reply_to: "support@example.test", subject: "Your order GRD-2048 is confirmed") do |format|
      format.html
      format.text
    end
  end

  # Plain-text-only email.
  def text_only
    mail(to: "gardener@example.test", subject: "Text only") do |format|
      format.text
    end
  end
end
