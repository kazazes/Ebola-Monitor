//
//  LocalizedOutbreak.h
//  Outbreak
//
//  Created by Peter on 11/4/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocalizedOutbreak : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSNumber *deaths;
@property (nonatomic, strong) NSNumber *cases;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSDate *lastUpdated;

@end
