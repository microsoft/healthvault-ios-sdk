#
# Be sure to run `pod lib lint healthvault-ios-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HealthVault'
  s.version          = '3.0.1-preview'
  s.summary          = 'An iOS library you can use to build applications that leverage the Microsoft HealthVault platform'


  s.description      = <<-DESC
The healthvault-ios-sdk simplifies developing apps that use the Microsoft HealthVault platform. It handles authenticating users, managing credentials, and serializing data types.
                       DESC

  s.homepage         = 'https://github.com/Microsoft/healthvault-ios-sdk'
  s.license          = { :type => 'APACHE', :file => 'LICENSE' }
  s.author           = { 'Microsoft' => 'hvtech@microsoft.com' }
  s.source           = { :git => 'https://github.com/Microsoft/healthvault-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'HealthVault/Classes/**/*'

  s.requires_arc     = true
  s.libraries        = "xml2"
  s.xcconfig         = { 'HEADER_SEARCH_PATHS' => '$(inherited) $(SDKROOT)/usr/include/libxml2', 'OTHER_LDFLAGS' => '-lxml2' }
  s.public_header_files = 'Pod/Classes/Headers/Public/*.h'

    s.frameworks = 'UIKit', 'Security', 'MobileCoreServices', 'SystemConfiguration'

  # s.resource_bundles = {
  #   'healthvault-ios-sdk' => ['healthvault-ios-sdk/Assets/*.png']
  # }

end
