//
//  MHVCachedRecord+CoreDataProperties.h
//  
//
//  This file was automatically generated and should not be edited.
//

#import "MHVCachedRecord+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface MHVCachedRecord (CoreDataProperties)

+ (NSFetchRequest<MHVCachedRecord *> *)fetchRequest;

@property (nonatomic) BOOL isValid;
@property (nonatomic) int64_t newestHealthVaultSequenceNumber;
@property (nonatomic) int64_t newestCacheSequenceNumber;
@property (nullable, nonatomic, copy) NSDate *lastSyncDate;
@property (nullable, nonatomic, copy) NSDate *lastConsistencyDate;
@property (nullable, nonatomic, copy) NSString *recordId;
@property (nullable, nonatomic, retain) NSSet<MHVPendingThingOperation *> *pendingThingOperations;
@property (nullable, nonatomic, retain) NSSet<MHVCachedThing *> *things;

@end

@interface MHVCachedRecord (CoreDataGeneratedAccessors)

- (void)addThingsObject:(MHVCachedThing *)value;
- (void)removeThingsObject:(MHVCachedThing *)value;
- (void)addThings:(NSSet<MHVCachedThing *> *)values;
- (void)removeThings:(NSSet<MHVCachedThing *> *)values;

@end

NS_ASSUME_NONNULL_END
