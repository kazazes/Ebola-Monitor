//
//  OutbreakLocationManager.m
//  Outbreak
//
//  Created by Peter on 11/10/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import "OutbreakLocationManager.h"
#import "OutbreakDataManager.h"

@interface OutbreakLocationManager ()

@property (nonatomic, strong) NSDate* lastUserDataSave;

@end

@implementation OutbreakLocationManager

@synthesize locationManager;
@synthesize locationTrackingPermissionGranted;
@synthesize hasFoundLocation;

+ (OutbreakLocationManager *)sharedOutbreakLocationManager {
    static dispatch_once_t once;
    static OutbreakLocationManager *instance;
    dispatch_once(&once, ^{
        instance = [[OutbreakLocationManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.delegate = self;
        
        hasFoundLocation = NO;
        self.lastUserDataSave = [NSDate dateWithTimeIntervalSince1970:0];
        
        if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse
            || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
            locationTrackingPermissionGranted = YES;
            [locationManager startUpdatingLocation];
        } else {
            locationTrackingPermissionGranted = NO;
        }
    }
    return self;
}

- (void)requestAndUpdateLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        } else {
            
        }
        [locationManager startUpdatingLocation];
    }
}

- (CLLocation *)location {
    return [locationManager location];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (fabs([self.lastUserDataSave timeIntervalSinceNow]) > 60 * 5) {
        self.lastUserDataSave = [NSDate date];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationsUpdated" object:nil userInfo:[NSDictionary dictionaryWithObject:locations forKey:@"locations"]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthorizationStatusChanged" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:status] forKey:@"status"]];
}

@end
