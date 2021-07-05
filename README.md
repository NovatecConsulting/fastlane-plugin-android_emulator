# android_emulator plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-android_emulator)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-android_emulator`, add it to your project by running:

```bash
fastlane add_plugin android_emulator
```

## About android_emulator

Creates and starts a new Android Emulator (AVD)

With additional features:

* set location
* set demo-mode (great for Screengrab 😀)

## Example

**Available Options:** sdk_dir, package, name, device, port, location, demo_mode, cold_boot

```ruby
android_emulator(
	location: '9.1808 48.7771',
	package: "system-images;android-24;google_apis;x86_64",
	demo_mode: true,
	sdk_dir: "PATH_TO_SDK",
	device: "Nexus 5",
	cold_boot: false
)
```

Or you can use it with our [Android SDK Update Plugin](https://github.com/NovaTecConsulting/fastlane-plugin-android_sdk_update) 


```ruby
ENV["AVD_PACKAGE"] = "system-images;android-24;google_apis;x86_64"

# installs the emulator and system-image
 android_sdk_update(
	additional_packages: [
		ENV["AVD_PACKAGE"],
		"emulator"
	]
)

android_emulator(
	location: '9.1808 48.7771'
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
