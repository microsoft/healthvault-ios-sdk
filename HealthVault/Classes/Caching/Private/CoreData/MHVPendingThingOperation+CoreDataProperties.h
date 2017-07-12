//
//  MHVPendingThingOperation+CoreDataProperties.h
//  
//
//  This file was automatically generated and should not be edited.
//

#import "MHVPendingThingOperation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MHVPendingThingOperation (CoreDataProperties)

+ (NSFetchRequest<MHVPendingThingOperation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSDate *originalRequestDate;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int64_t version;
@property (nullable, nonatomic, copy) NSString *parameters;
@property (nullable, nonatomic, copy) NSString *correlationId;
@property (nullable, nonatomic, retain) MHVCachedRecord *record;

@end

NS_ASSUME_NONNULL_END
