module SnapshotUI
  module Live
    module WebsocketMessage
      module_function

      def ping
        {type: "ping", message: Time.now.to_i.to_s}.to_json
      end

      def confirm_subscription
        {identifier: "{\"channel\":\"RefreshChannel\"}", type: "confirm_subscription"}.to_json
      end

      def refresh
        {identifier: "{\"channel\":\"RefreshChannel\"}", message: "refresh"}.to_json
      end
    end
  end
end
