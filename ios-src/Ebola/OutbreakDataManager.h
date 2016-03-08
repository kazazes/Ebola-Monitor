//
//  OutbreakDataManager.h
//  
//
//  Created by Peter on 11/1/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OutbreakDatapoint.h"

@interface OutbreakDataManager : NSObject

+ (OutbreakDataManager *)sharedOutbreakDataManager;
- (void) refreshOutbreakDatapoints;
- (void)logAllCases;
- (NSArray *)getLocalizedOutbreaks;
- (CLLocationDistance)distanceFromOutbreakInMetersFromPoint:(CLLocationCoordinate2D) coord;
- (OutbreakDatapoint *)nearestOutbreakToPoint:(CLLocationCoordinate2D) coord;
- (int)totalCases;
- (int)totalDeaths;
- (int)percentMortality;
- (void)saveUserInfo;
- (int)weeksWorthOfData;
- (int)casesPerWeekWithIndex:(int)week;
- (void)requestPushNotificationPrivileges;

@property (nonatomic, strong) NSString *deviceToken;

@end
