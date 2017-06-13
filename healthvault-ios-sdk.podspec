#
# Be sure to run `pod lib lint healthvault-ios-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'healthvault-ios-sdk'
  s.version          = '3.0.0.0'
  s.summary          = 'A short description of healthvault-ios-sdk.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Microsoft/healthvault-ios-sdk'
  s.license          = { :type => 'APACHE', :file => 'LICENSE' }
  s.author           = { 'namalu' => 'namalu@microsoft.com' }
  s.source           = { :git => 'https://github.com/Microsoft/healthvault-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'healthvault-ios-sdk/Classes/**/*'

    s.requires_arc     = true
    s.libraries        = "xml2"
    s.xcconfig         = { 'HEADER_SEARCH_PATHS' => '$(inherited) $(SDKROOT)/usr/include/libxml2', 'OTHER_LDFLAGS' => '-lxml2' }

    s.frameworks = 'UIKit', 'Security', 'MobileCoreServices', 'SystemConfiguration'

  # s.resource_bundles = {
  #   'healthvault-ios-sdk' => ['healthvault-ios-sdk/Assets/*.png']
  # }

  #s.public_header_files = 'Pod/Classes/MHVLib.h'
  # s.frameworks = 'UIKit'

end
