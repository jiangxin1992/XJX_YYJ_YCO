//
//  LookBook+CoreDataProperties.h
//  
//
//  Created by Apple on 15/12/23.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LookBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface LookBook (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *coverPic;
@property (nullable, nonatomic, retain) NSNumber *createTime;
@property (nullable, nonatomic, retain) NSNumber *designerId;
@property (nullable, nonatomic, retain) NSNumber *lookBookId;
@property (nullable, nonatomic, retain) NSNumber *isOnHomepage;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *note;
@property (nullable, nonatomic, retain) NSNumber *picCount;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *pics;

@end

@interface LookBook (CoreDataGeneratedAccessors)

- (void)addPicsObject:(NSManagedObject *)value;
- (void)removePicsObject:(NSManagedObject *)value;
- (void)addPics:(NSSet<NSManagedObject *> *)values;
- (void)removePics:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
