#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint map_launcher.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'map_launcher'
  s.version          = '7.0.0'
  s.summary          = 'A Flutter plugin for finding and launching installed map applications.'
  s.description      = <<-DESC
Find installed map applications and launch them with markers, directions, or searches.
                       DESC
  s.homepage         = 'https://github.com/mattermoran/map_launcher'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Alex Miller'
  s.source           = { :path => '.' }
  s.source_files = 'map_launcher/Sources/map_launcher/**/*'
  s.resource_bundles = {'map_launcher_privacy' => ['map_launcher/Sources/map_launcher/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

end
