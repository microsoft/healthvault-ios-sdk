//
//  MHVThingConstants.h
//  MHVLib
//
//  Created by Nathan Malubay on 5/12/17.
//  Copyright © 2017 Microsoft Corporation. All rights reserved.
//

#ifndef MHVThingConstants_h
#define MHVThingConstants_h

/**
 Enumeration used to specify the sections of thing type definition that should be returned.
 */
typedef NS_ENUM(NSUInteger, MHVThingTypeSections)
{
    // Indicates no information about the thing type definition should be returned.
    MHVThingTypeSectionsNone = 0x0,
    
    // Indicates the core information about the thing type definition should be returned.
    MHVThingTypeSectionsCore = 0x1,
    
    // Indicates the schema of the thing type definition should be returned.
    MHVThingTypeSectionsXsd = 0x2,
    
    // Indicates the columns used by the thing type definition should be returned.
    MHVThingTypeSectionsColumns = 0x4,
    
    // Indicates the transforms supported by the thing type definition should be returned.
    MHVThingTypeSectionsTransforms = 0x8,
    
    // Indicates the transforms and their XSL source supported by the health record item type definition should be returned.
    MHVThingTypeSectionsTransformSource = 0x10,
    
    // Indicates the versions of the thing type definition should be returned.
    MHVThingTypeSectionsVersions = 0x20,
    
    // Indicates the effective date XPath of the thing type definition should be returned.
    MHVThingTypeSectionsEffectiveDateXPath = 0x40,
    
    // Indicates all information for the thing type definition should be returned.
    MHVThingTypeSectionsAll = MHVThingTypeSectionsCore | MHVThingTypeSectionsXsd | MHVThingTypeSectionsColumns | MHVThingTypeSectionsTransforms | MHVThingTypeSectionsTransformSource | MHVThingTypeSectionsVersions | MHVThingTypeSectionsEffectiveDateXPath
};

#endif /* MHVThingConstants_h */
