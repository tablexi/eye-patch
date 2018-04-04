# frozen_string_literal: true

require "dogapi"

module Eye
  class Notify
    class DATADOG < Eye::Notify
      param :aggregation_key, String
      param :alert_type, String
      param :api_key, String, true
      param :source_type, String
      param :tags, Array

      def execute
        options = {
          alert_type: "error",
          aggregation_key: msg_host + msg_full_name,
          source_type: "None",
          tags: ["eye"]
        }

        options[:alert_type] = alert_type if alert_type
        options[:aggregation_key] = aggregation_key if aggregation_key
        options[:source_type] = source_type if source_type
        options[:tags] = tags if tags

        dog = Dogapi::Client.new(api_key)

        dog.emit_event(
          Dogapi::Event.new(
            message_body,
            aggregation_key: options[:aggregation_key],
            alert_type: options[:alert_type],
            msg_title: message_subject,
            host: msg_host,
            source_type: options[:source_type],
            tags: options[:tags]
          )
        )
      end
    end
  end
end
