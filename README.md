# About
MHVLib is a static iOS library you use to build applications for Microsoft HealthVault.  MHVLib was originally developed for and is actively used by the [Microsoft HealthVault for iPhone app](https://itunes.apple.com/us/app/microsoft-healthvault/id546835834?mt=8).

MHVLib introduces a rich new HealthVault iOS client programming model.  It includes built in serialization of most HealthVault data types, and built in support for HealthVault methods. You no longer need to manually parse or create XML. 

HealthVault data types are automatically serialized/deserialized from their native XML into Objective-C objects. These objects include programming model to assist with data manipulation. MHVLib also supplies support for local HealthVault data storage, and in the future, synchronization. 


# 64 Bit Support
The latest iOS SDK version supports both 32 and 64 bit applications.


# Sample Code
See MHVLib/Samples/HelloHealthVault for sample code. 

## HelloHealthVault
* Samples/HelloHealthVault.xcworkspace

The HelloHealthVault sample demonstrates how to add, remove, update and query Health information to and from HealthVault. 
To run the sample, make sure you load the WORKSPACE - (HelloHealthVault.xcworkspace) -  so that dependencies and libraries are correctly pulled in. 

HelloHealthVault uses a pre-defined HealthVault application.
You can create your own applications using the HealthVault Application Configuration Center.

## SDK Features Sample App

* Samples/SDKFeatures.xcworkspace

The rich SDKFeatures sample demonstrates how to view, create, update and delete most core HealthVault types, including blood pressure, medication, conditions, procedures, immunizations, blood glucose, exercise and diet. It also shows you how to manage files - view, download and upload files in HealthVault. 

SDKFeatures also demonstrates how to de-authorize your application from HealthVault. 

# Using MHVLib with your Project

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
#### ClientSettings.xml
  * MHVLib loads settings from ClientSettings.xml. Please add ClientSettings.xml to your project. 
  * You can leverage the one included with the HelloHealthVault sample.

```XML
<?xml version="1.0" encoding="utf-8" ?>
<clientSettings>
    <!--
        HealthVault Application ID
     This is the app ID for the default sample Hello World application. 
     Create your own application athttp://config.healthvault-ppe.com
     -->
	<masterAppID>cf36aef7-5d87-4688-88b2-f9b57c086d7d</masterAppID>
    <!--Application name -->
    <appName>Hello Healthvault</appName>
    <!--
        Url for HealthVault service calls - set up for Pre-Production below
     -->
	<serviceUrl>https://platform.healthvault-ppe.com/platform/wildcat.ashx</serviceUrl>
    <!--
        HealthVault Shell - used during app provisioning on the device
     -->
	<shellUrl>https://account.healthvault-ppe.com</shellUrl>
</clientSettings>
```

# Contribute
Contributions to HVMobile_VNext are welcome.  Here is how you can contribute:

* [Submit bugs](https://github.com/Microsoft/HVMobile_VNext/issues) and help us verify fixes
* [Submit pull requests](https://github.com/Microsoft/HVMobile_VNext/pulls) for bug fixes and features

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
