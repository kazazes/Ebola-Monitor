//
//  Case.h
//  Ebola
//
//  Created by Peter on 11/4/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class OutbreakDatapoint;

@interface OutbreakDatapoint : NSManagedObject

@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * idString;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSNumber * unconfirmed;
@property (nonatomic, retain) NSNumber * cases;
@property (nonatomic, retain) NSNumber * deaths;
@property (nonatomic, retain) NSSet *child;
@property (nonatomic, retain) OutbreakDatapoint *parent;
@end

@interface OutbreakDatapoint (CoreDataGeneratedAccessors)

- (void)addChildObject:(OutbreakDatapoint *)value;
- (void)removeChildObject:(OutbreakDatapoint *)value;
- (void)addChild:(NSSet *)values;
- (void)removeChild:(NSSet *)values;
- (CLLocation *)location;

@end
