# healthvault-ios-sdk

[![CI Status](https://microsofthealth.visualstudio.com/_apis/public/build/definitions/f8da5110-49b1-4e9f-9022-2f58b6124ff9/194/badge)]
[![Version](https://img.shields.io/cocoapods/v/healthvault-ios-sdk.svg?style=flat)](http://cocoapods.org/pods/healthvault-ios-sdk)
[![License](https://img.shields.io/cocoapods/l/healthvault-ios-sdk.svg?style=flat)](http://cocoapods.org/pods/healthvault-ios-sdk)
[![Platform](https://img.shields.io/cocoapods/p/healthvault-ios-sdk.svg?style=flat)](http://cocoapods.org/pods/healthvault-ios-sdk)

# About
**healthvault-ios-sdk** is a static iOS library you use to build applications that leverage the Microsoft HealthVault platform. **healthvault-ios-sdk** is actively used by the [Microsoft HealthVault for iPhone app](https://itunes.apple.com/us/app/microsoft-healthvault/id546835834?mt=8).

**healthvault-ios-sdk** introduces a rich new HealthVault iOS client programming model. It includes built in serialization of most HealthVault data types, and built in support for HealthVault methods.

HealthVault data types are automatically serialized/deserialized from their native XML into Objective-C objects. These objects include programming model to assist with data manipulation. 

## Example

The example project demonstrates how to:

* Authenticate with HealthVault
* View, create, update and delete most core HealthVault types, including blood pressure, medication, conditions, procedures, immunizations, blood glucose, exercise and diet.
* manage files - view, download and upload files in HealthVault.
* de-authorize your application from HealthVault.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

healthvault-ios-sdk is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "healthvault-ios-sdk"
```

## Using MHVLib with your Project

You should link MHVLib as a static library into your project.
 
1. Make sure you are using Xcode workspaces. If not, create a new workspace and add your project to it.
2. Add MHVLib.xcodeproj to your Workspace


## iOS Framework Dependencies
* libxml2.2.dylib OR libxml2.2.tbd (depending on your XCODE version)   [This is part of the core iOS SDK]
* Security.Framework
* MobileCoreServices.Framework
* SystemConfiguration.Framework


## Header Files

```objective-C
//
// Include HealthVault Library
//
#import "MHVLib.h"
```

## Update Build Targets

Make the following changes to your project Target: 

### Build Phases
* Link Binary With Libraries
* Add libMHVLib.a  [This is the HealthVault Library. You should see it listed under "Workspace"]
* Add libxml2.2.dylib OR libxml2.2.tbd (depending on your XCODE version)    [This is part of the core iOS SDK]
* Security.Framework
* SystemConfiguration.Framework
* MobileCoreServices.Framework

### Build Settings

* Architectures
  * Set your Architectures to Standard architectures (armv7, arm64) - $(ARCHS_STANDARD)
  * Build Active Architectures Only — NO
  * Set Code Generation -> No Common Blocks to NO

#### Linking
Add the following flags under the "Other Linker Flags" section:
  * ObjC

#### Search Paths
Add the following flags within the "Header Search Paths" section:
  * $(SDK_DIR)/usr/include/libxml2/**
  * User Header Search Paths: 
    * Add Relative Path to the MHVLib directory. E.g. HealthVault samples use the path:
      * ../../MHVLib/**       [Note: Xcode may add the ** for you by default - i.e. search all subdirectories of the path]
      * OR: ../HVMobile_VNext/**


# Contribute
Contributions to **healthvault-ios-sdk** are welcome.  Here is how you can contribute:

* [Submit bugs](https://github.com/Microsoft/HVMobile_VNext/issues) and help us verify fixes
* [Submit pull requests](https://github.com/Microsoft/HVMobile_VNext/pulls) for bug fixes and features

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
