#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'msal_flutter'
  s.version          = '1.0.0'
  s.summary          = 'MSAL Flutter Wrapper'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://www.moodio.co.uk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Moodio Ltd' => 'mahmoud@moodio.co.uk' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'MSAL', '~> 1.0.3'

  s.swift_version = '4.0'
  s.ios.deployment_target = '10.0'
end

