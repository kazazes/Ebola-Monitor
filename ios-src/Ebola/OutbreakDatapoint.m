//
//  Case.m
//  Outbreak
//
//  Created by Peter on 11/4/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import "OutbreakDatapoint.h"
#import "OutbreakDatapoint.h"


@implementation OutbreakDatapoint

@dynamic country;
@dynamic date;
@dynamic idString;
@dynamic latitude;
@dynamic longitude;
@dynamic notes;
@dynamic parentId;
@dynamic unconfirmed;
@dynamic cases;
@dynamic deaths;
@dynamic child;
@dynamic parent;

- (CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue]  longitude:[self.longitude doubleValue]];
}

@end
