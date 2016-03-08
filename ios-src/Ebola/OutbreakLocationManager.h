//
//  OutbreakLocationManager.h
//  Outbreak
//
//  Created by Peter on 11/10/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OutbreakLocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    BOOL hasFoundLocation;
    BOOL locationTrackingPermissionGranted;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL hasFoundLocation;
@property (nonatomic) BOOL locationTrackingPermissionGranted;

+ (OutbreakLocationManager *)sharedOutbreakLocationManager;
- (void)requestAndUpdateLocation;
- (CLLocation *)location;

@end
