require "celluloid"
require "aws/ses"

class Eye::Notify::SES < Eye::Notify::Custom

  param :access_key_id, String, true
  param :secret_access_key, String, true
  param :from, String, true

  def execute
    AWS::SES::Base.new(
      access_key_id:     access_key_id,
      secret_access_key: secret_access_key ).send_email(message)
  end

  def message
    { to: contact,
      from: from,
      subject: message_subject,
      text_body: message_body }
  end
end
