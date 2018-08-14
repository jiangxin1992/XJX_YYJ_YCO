//
//  LookBookPics+CoreDataProperties.h
//  
//
//  Created by Apple on 15/12/23.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LookBookPics.h"

NS_ASSUME_NONNULL_BEGIN

@interface LookBookPics (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *picUrl;
@property (nullable, nonatomic, retain) NSNumber *lookBookId;
@property (nullable, nonatomic, retain) LookBook *lookBook;

@end

NS_ASSUME_NONNULL_END
