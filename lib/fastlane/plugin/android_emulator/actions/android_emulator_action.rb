require 'fastlane/action'
require_relative '../helper/android_emulator_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class AndroidEmulatorAction < Action
      def self.run(params)
        Actions::AndroidSdkLocateAction.run(params)
        sdk_dir = Actions.lane_context[SharedValues::ANDROID_SDK_DIR]
        adb = "#{sdk_dir}/platform-tools/adb"

        UI.message("Stopping emulator")
        system("#{adb} emu kill > /dev/null 2>&1")

        avd_available = false
        config_file = "#{Dir.home}/.android/avd/#{params[:name]}.avd/config.ini"
        if File.exists?(config_file)
          avd_image = File.open(config_file).grep(/^image\.sysdir\.1=/).first
          avd_available = avd_image.include?(params[:package].gsub(';', '/'))
        end

        if params[:retain_previous_avd] && avd_available
          UI.message("Using existing #{params[:name]} emulator")
        else
          UI.message("Creating new emulator")
          FastlaneCore::CommandExecutor.execute(
            command: "#{sdk_dir}/tools/bin/avdmanager create avd -n '#{params[:name]}' -f -k '#{params[:package]}' -d '#{params[:device_definition]}'",
            print_all: true,
            print_command: false
          )

          UI.message("Override configuration")
          open(config_file, 'a') { |f|
            f << "hw.gpu.mode=auto\n"
            f << "hw.gpu.enabled=yes\n"
            f << "skin.dynamic=yes\n"
            f << "skin.name=1080x1920\n"
          }
        end

        # Verify HAXM installed on mac
        if FastlaneCore::Helper.mac?
          kextstat = Actions.sh("kextstat", log: false)

          UI.user_error! "Please install the HAXM-Extension" unless kextstat.include?("intel")
        end

        UI.message("Starting emulator")
        system("LC_NUMERIC=C; #{sdk_dir}/tools/emulator @#{params[:name]} > /dev/null 2>&1 &")

        error_callback = proc do |error|
          UI.error("Emulator may be having issues... or could have started too quickly!")
        end
        Actions.sh("#{adb} -e wait-for-device", error_callback: error_callback)

        until Actions.sh("#{adb} -e shell getprop init.svc.bootanim", log: false,
                         error_callback: error_callback).include? "stopped" do
          sleep(5)
        end

        if params[:location]
          UI.message("Set location")
          sh("LC_NUMERIC=C; #{adb} emu geo fix #{params[:location]}")
        end

        if params[:demo_mode]
          UI.message("Set in demo mode")
          sh("#{adb} -e shell settings put global sysui_demo_allowed 1")
          sh("#{adb} -e shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0700")
        end
      end

      def self.description
        "Creates and starts an Android Emulator (AVD)"
      end

      def self.details
        "Great for Screengrab"
      end

      def self.example_code
        [
          'android_emulator(
            location: "9.1808 48.7771",
            package: "system-images;android-24;google_apis;x86_64",
            demo_mode: true,
            sdk_dir: "PATH_TO_SDK"
          )'
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :sdk_dir,
                                       env_name: "ANDROID_SDK_DIR",
                                       description: "Path to the Android SDK DIR",
                                       default_value: Actions.lane_context[SharedValues::ANDROID_SDK_DIR],
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("No ANDROID_SDK_DIR given, pass using `sdk_dir: 'sdk_dir'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :package,
                                       env_name: "AVD_PACKAGE",
                                       description: "The selected system image of the emulator",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "AVD_NAME",
                                       description: "Name of the AVD",
                                       default_value: "fastlane",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :device_definition,
                                       env_name: "AVD_DEVICE_DEFINITION",
                                       description: "Device definition for the AVD",
                                       default_value: "Nexus 5",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :location,
                                       env_name: "AVD_LOCATION",
                                       description: "Set location of the the emulator '<longitude> <latitude>'",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :demo_mode,
                                       env_name: "AVD_DEMO_MODE",
                                       description: "Set the emulator in demo mode",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :retain_previous_avd,
                                       env_name: "AVD_RETAIN_PREVIOUS",
                                       description: "Retain previously created AVD (use snapshot)",
                                       is_string: false,
                                       default_value: true)
        ]
      end

      def self.authors
        ["Michael Ruhl"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
