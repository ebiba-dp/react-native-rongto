# react-native-rongta.podspec

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-rongta"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-rongta
                   DESC
  s.homepage     = "https://github.com/github_account/react-native-rongta"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-rongta.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,cc,cpp,m,mm,swift}"
  s.ios.vendored_libraries = 'ios/Sdk/libRTPrinterSDK.a'
  s.frameworks = 'CoreBluetooth'
  s.requires_arc = true

  s.dependency "React"
  # ...
  # s.dependency "..."
end

