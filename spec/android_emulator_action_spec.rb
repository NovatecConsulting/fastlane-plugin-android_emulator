describe Fastlane::Actions::AndroidEmulatorAction do
  describe '#run' do
    it 'fails without sdk_dir' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
            android_emulator({package: '23'})
          end").runner.execute(:test)
      end.to raise_error("No ANDROID_SDK_DIR given, pass using `sdk_dir: 'sdk_dir'`")
    end
    it 'fails without package' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
            android_emulator({sdk_dir: '23'})
          end").runner.execute(:test)
      end.to raise_error("No value found for 'package'")
    end
  end
end
