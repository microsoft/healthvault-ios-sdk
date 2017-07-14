//
//  MHVCachedRecord+CoreDataProperties.m
//  
//
//  This file was automatically generated and should not be edited.
//

#import "MHVCachedRecord+CoreDataProperties.h"

@implementation MHVCachedRecord (CoreDataProperties)

+ (NSFetchRequest<MHVCachedRecord *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MHVCachedRecord"];
}

@dynamic isValid;
@dynamic lastSyncDate;
@dynamic lastConsistencyDate;
@dynamic newestHealthVaultSequenceNumber;
@dynamic newestCacheSequenceNumber;
@dynamic recordId;
@dynamic pendingThingOperations;
@dynamic things;

@end
