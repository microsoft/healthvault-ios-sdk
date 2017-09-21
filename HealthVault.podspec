# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HealthVault'
  s.version          = '3.0-preview.5'
  s.summary          = 'An iOS framework you can use to build applications that leverage the Microsoft HealthVault platform'


  s.description      = <<-DESC
The healthvault-ios-sdk framework simplifies developing apps that use the Microsoft HealthVault platform. It handles authenticating users, managing credentials, serializing data types and much more.
                       DESC

  s.homepage         = 'https://github.com/Microsoft/healthvault-ios-sdk'
  s.license          = { :type => 'APACHE', :file => 'LICENSE' }
  s.author           = { 'Microsoft' => 'hvtech@microsoft.com' }
  s.source           = { :git => 'https://github.com/Microsoft/healthvault-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.requires_arc     = true
  s.libraries        = "xml2"
  s.xcconfig         = { 'HEADER_SEARCH_PATHS' => '$(inherited) $(SDKROOT)/usr/include/libxml2', 'OTHER_LDFLAGS' => '-lxml2' }
  s.frameworks       = 'UIKit', 'Security', 'MobileCoreServices', 'SystemConfiguration'

# Default podspecs include 'Core' and 'CachingSupport'.
  s.default_subspec = 'CachingSupport'

# Core subspec includes only basic HealthVault functionality (no caching or offline support).
  s.subspec 'Core' do |ss|
    ss.source_files = 'HealthVault/Classes/**/*.{h,m}'
    ss.exclude_files = 'HealthVault/Classes/Caching/**/*.{h,m}'
    ss.private_header_files = '**/Private/**/*.h'
  end

# CachingSupport subspec includes caching and offline support.
  s.subspec 'CachingSupport' do |ss|
    ss.resources = 'HealthVault/Assets/MHVThingCacheDatabase.xcdatamodeld'
    ss.preserve_paths = 'HealthVault/Assets/MHVThingCacheDatabase.xcdatamodeld'
    ss.source_files = 'HealthVault/Classes/**/*.{h,m}'
    ss.private_header_files = '**/Private/**/*.h'
    ss.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'THING_CACHE=1' }
    ss.frameworks = 'CoreData'
    ss.dependency 'EncryptedCoreData', '~> 3.1'
end

# Tests subspec for testing only - Exposes private interfaces.
  s.subspec 'Tests' do |ss|
    ss.source_files = 'HealthVault/Classes/**/*.{h,m,xcdatamodeld}'
    ss.resources = 'HealthVault/Assets/**/*'
    ss.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'THING_CACHE=1' }
    ss.frameworks = 'CoreData'
    ss.dependency 'EncryptedCoreData', '~> 3.1'
  end
end
