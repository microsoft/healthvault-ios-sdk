//
//  MHVPendingDeleteThing+CoreDataProperties.h
//  
//
//  This file was automatically generated and should not be edited.
//

#import "MHVPendingDeleteThing+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MHVPendingDeleteThing (CoreDataProperties)

+ (NSFetchRequest<MHVPendingDeleteThing *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *thingId;
@property (nullable, nonatomic, retain) MHVCachedRecord *record;

@end

NS_ASSUME_NONNULL_END
