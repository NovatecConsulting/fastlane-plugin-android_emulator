require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class AndroidEmulatorHelper
      # class methods that you define here become available in your action
      # as `Helper::AndroidEmulatorHelper.your_method`

      # copied from fastlane/screengrab/lib/runner.rb
      def self.select_device(devices, specific_device)
        # the first output by adb devices is "List of devices attached" so remove that and any adb startup output
        devices.reject! do |device|
          [
            'server is out of date',    # The adb server is out of date and must be restarted
            'unauthorized',             # The device has not yet accepted ADB control
            'offline',                  # The device is offline, skip it
            '* daemon',                 # Messages printed when the daemon is starting up
            'List of devices attached', # Header of table for data we want
            "doesn't match this client" # Message printed when there is an ADB client/server version mismatch
          ].any? { |status| device.include?(status) }
        end

        UI.user_error!('There are no connected and authorized devices or emulators') if devices.empty?

        devices.select! { |d| d.include?(specific_device) } if specific_device

        UI.user_error!("No connected devices matched your criteria: #{specific_device}") if devices.empty?

        if devices.length > 1
          UI.important("Multiple connected devices, selecting the first one")
          UI.important("To specify which connected device to use, use the specific_device option")
        end

        # grab the serial number. the lines of output can look like these:
        # 00c22d4d84aec525       device usb:2148663295X product:bullhead model:Nexus_5X device:bullhead
        # 192.168.1.100:5555       device usb:2148663295X product:bullhead model:Nexus_5X device:genymotion
        # emulator-5554       device usb:2148663295X product:bullhead model:Nexus_5X device:emulator
        devices[0].match(/^\S+/)[0]
      end
    end
  end
end
