//
//  MHVPlatformConstants.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/12/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#ifndef MHVPlatformConstants_h
#define MHVPlatformConstants_h

typedef NS_ENUM(NSUInteger, MHVServiceInfoSections)
{
    // Corresponds to ServiceInfo.HealthServiceUrl, ServiceInfo.Version, and ServiceInfo.ConfigurationValues.
    MHVServiceInfoSectionsPlatform = 0x1,
    
    // Corresponds to ServiceInfo.HealthServiceShellInfo.
    MHVServiceInfoSectionsShell = 0x2,
    
    // Corresponds to ServiceInfo.ServiceInstances and ServiceInfo.CurrentInstance.
    MHVServiceInfoSectionsTopology = 0x4,
    
    // Corresponds to ServiceInfo.Methods and ServiceInfo.IncludedSchemaUrls.
    MHVServiceInfoSectionsXmlOverHttpMethods = 0x8,
    
    // Not currently used.
    MHVServiceInfoSectionsMeaningfulUse = 0x10,
    
    // Retrieve all sections.
    MHVServiceInfoSectionsAll = MHVServiceInfoSectionsPlatform | MHVServiceInfoSectionsShell | MHVServiceInfoSectionsTopology | MHVServiceInfoSectionsXmlOverHttpMethods | MHVServiceInfoSectionsMeaningfulUse
};

#endif /* MHVPlatformConstants_h */
