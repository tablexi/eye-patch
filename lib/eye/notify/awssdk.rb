require "aws-sdk-core"
require "aws-sdk-core/ses"

module Eye
  class Notify
    class AWSSDK < Eye::Notify
      param :region, String, true
      param :access_key_id, String, true
      param :secret_access_key, String, true
      param :from, String, true

      def execute
        client = Aws::SES::Client.new(
          region: region,
          credentials: Aws::Credentials.new(access_key_id, secret_access_key))
        client.send_email(message)
      end

      def message
        { source: from,
          destination: {
            to_addresses: [contact]
          },
          message: {
            subject: {
              data: message_subject
            },
            body: {
              text: {
                data: message_body
              },
              html: {
                data: message_body
              }
            }
          }
        }
      end
    end
  end
end
