# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HealthVault'
  s.version          = '3.0.2-preview'
  s.summary          = 'An iOS framework you can use to build applications that leverage the Microsoft HealthVault platform'


  s.description      = <<-DESC
The healthvault-ios-sdk framework simplifies developing apps that use the Microsoft HealthVault platform. It handles authenticating users, managing credentials, serializing data types and much more.
                       DESC

  s.homepage         = 'https://github.com/Microsoft/healthvault-ios-sdk'
  s.license          = { :type => 'APACHE', :file => 'LICENSE' }
  s.author           = { 'Microsoft' => 'hvtech@microsoft.com' }
  s.source           = { :git => 'https://github.com/Microsoft/healthvault-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'HealthVault/Classes/**/*'
  s.exclude_files = 'HealthVault/Classes/Caching/**/*.{h,m}'

  s.requires_arc     = true
  s.libraries        = "xml2"
  s.xcconfig         = { 'HEADER_SEARCH_PATHS' => '$(inherited) $(SDKROOT)/usr/include/libxml2', 'OTHER_LDFLAGS' => '-lxml2' }
  s.frameworks       = 'UIKit', 'Security', 'MobileCoreServices', 'SystemConfiguration'

  s.subspec 'OfflineThingCache' do |ss|
    ss.source_files = 'HealthVault/Classes/**/*'
    ss.frameworks = 'CoreData'
    ss.compiler_flags = '-D THING_CACHE=1'
    ss.dependency 'EncryptedCoreData', '~> 3.1'
  end
end
