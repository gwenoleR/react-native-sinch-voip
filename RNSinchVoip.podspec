require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNSinchVoip"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-sinch-voip
                   DESC
  s.homepage     = "https://github.com/github_account/react-native-sinch-voip"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Gwénolé Roton" => "gwenole.roton@live.com" }
  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/gwenoleR/react-native-sinch-voip.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  
  s.dependency "SinchRTC", "~> 4.2.6"
end

