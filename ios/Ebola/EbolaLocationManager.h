//
//  EbolaLocationManager.h
//  Ebola
//
//  Created by Peter on 11/10/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EbolaLocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    BOOL hasFoundLocation;
    BOOL locationTrackingPermissionGranted;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL hasFoundLocation;
@property (nonatomic) BOOL locationTrackingPermissionGranted;

+ (EbolaLocationManager *)sharedEbolaLocationManager;
- (void)requestAndUpdateLocation;
- (CLLocation *)location;

@end
