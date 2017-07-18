//
//  MHVCachedThing+CoreDataProperties.h
//  
//
//  This file was automatically generated and should not be edited.
//

#import "MHVCachedThing+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MHVCachedThing (CoreDataProperties)

+ (NSFetchRequest<MHVCachedThing *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, copy) NSString *createdByAppId;
@property (nullable, nonatomic, copy) NSString *createdByPersonId;
@property (nullable, nonatomic, copy) NSDate *effectiveDate;
@property (nullable, nonatomic, copy) NSString *thingId;
@property (nullable, nonatomic, copy) NSString *typeId;
@property (nullable, nonatomic, copy) NSDate *updateDate;
@property (nullable, nonatomic, copy) NSString *updatedByAppId;
@property (nullable, nonatomic, copy) NSString *updatedByPersonId;
@property (nullable, nonatomic, copy) NSString *version;
@property (nullable, nonatomic, copy) NSString *xmlString;
@property (nonatomic) BOOL isPlaceholder;
@property (nullable, nonatomic, retain) MHVCachedRecord *record;

@end

NS_ASSUME_NONNULL_END
