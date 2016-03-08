//
//  OutbreakDataManager.m
//
//
//  Created by Peter on 11/1/14.
//
//

#import "OutbreakDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import <MagicalRecord/MagicalRecord.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "LocalizedOutbreak.h"
#import "OutbreakLocationManager.h"
#import "AppDelegate.h"
#import <STTwitter/STTwitter.h>
#import <Accounts/Accounts.h>

@interface OutbreakDataManager ()

@property (nonatomic) long oldestEntry;

@end

@implementation OutbreakDataManager

+ (OutbreakDataManager *)sharedOutbreakDataManager {
    static dispatch_once_t once;
    static OutbreakDataManager *instance;
    dispatch_once(&once, ^{
        instance = [[OutbreakDataManager alloc] init];
    });
    return instance;
}

- (void)requestPushNotificationPrivileges {
    UIApplication *application = [UIApplication sharedApplication];
    // Register for Push Notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (void) refreshOutbreakDatapoints {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDatapointsStarted" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"progress"]];
    NSString *urlString = [NSString stringWithFormat:@"%@/datapoints", BASE_URL];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSNumber *percentCompleted = [NSNumber numberWithDouble:totalBytesRead / totalBytesExpectedToRead];
        if ([percentCompleted doubleValue] < 0) {
            percentCompleted = [NSNumber numberWithInt:-1];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDatapointsProgress" object:nil userInfo:[NSDictionary dictionaryWithObject:percentCompleted forKey:@"progress"]];
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [OutbreakDatapoint MR_truncateAll];
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        
        for (NSDictionary *d in responseObject) {
            if (![OutbreakDatapoint MR_findFirstByAttribute:@"idString" withValue:[d objectForKey:@"_id"]]) {
                OutbreakDatapoint *a = [OutbreakDatapoint MR_createEntity];
                [a setCountry:[d objectForKey:@"country"]];
                [a setDate:[formatter dateFromString:[d objectForKey:@"date"]]];
                [a setLatitude:[d objectForKey:@"latitude"]];
                [a setLongitude:[d objectForKey:@"longitude"]];
                [a setNotes:[d objectForKey:@"notes"]];
                [a setIdString:[d objectForKey:@"_id"]];
                [a setCases:[d objectForKey:@"cases"]];
                [a setDeaths:[d objectForKey:@"deaths"]];
                [a setUnconfirmed:[d objectForKey:@"unconfirmed"]];
            }
        }
        
        self.oldestEntry = [[[[OutbreakDatapoint MR_findAllSortedBy:@"date" ascending:YES] firstObject] date] timeIntervalSince1970];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatedDatapoints" object:nil userInfo:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED TO LOAD. %@", error);
    }];
    [operation start];
}

- (NSArray *)getLocalizedOutbreaks {
    NSMutableArray *localizedOutbreaks = [[NSMutableArray alloc] init];
    
    for (OutbreakDatapoint *d in [OutbreakDatapoint MR_findAll]) {
        CLLocationCoordinate2D tempCoord = CLLocationCoordinate2DMake([d.latitude doubleValue], [d.longitude doubleValue]);
        int indexOfOutbreak = [self array:localizedOutbreaks containsLocalizedOutbreakAtCoordinate:tempCoord];
        if (indexOfOutbreak > -1) {
            LocalizedOutbreak *existing = [localizedOutbreaks objectAtIndex:indexOfOutbreak];
            if ([existing.lastUpdated compare:d.date] == NSOrderedAscending) {
                existing.deaths = [NSNumber numberWithInt:[d.deaths intValue]];
                existing.cases = [NSNumber numberWithInt:[d.cases intValue]];
                existing.lastUpdated = d.date;
                [localizedOutbreaks replaceObjectAtIndex:indexOfOutbreak withObject:existing];
            }
        } else {
            LocalizedOutbreak *newOutbreak = [[LocalizedOutbreak alloc] init];
            newOutbreak.deaths = d.deaths;
            newOutbreak.cases = d.cases;
            newOutbreak.country = d.country;
            newOutbreak.coordinate = CLLocationCoordinate2DMake([d.latitude floatValue], [d.longitude floatValue]);
            newOutbreak.lastUpdated = d.date;
            [localizedOutbreaks addObject:newOutbreak];
        }
    }
    
    return localizedOutbreaks;
}

- (CLLocationDistance)distanceFromOutbreakInMetersFromPoint:(CLLocationCoordinate2D) coord {
    if ([[OutbreakDatapoint MR_findAll] count] > 0) {
        CLLocationDistance minDistance = CLLocationDistanceMax;
        for (OutbreakDatapoint *d in [OutbreakDatapoint MR_findAll]) {
            CLLocation *coordLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
            CLLocation *datapointLocation = [[CLLocation alloc] initWithLatitude:[d.latitude floatValue] longitude:[d.longitude floatValue]];
            if ([coordLocation distanceFromLocation:datapointLocation] < minDistance) {
                minDistance = [coordLocation distanceFromLocation:datapointLocation];
            }
        }
        
        return minDistance;
    } else {
        return -1;
    }
}

- (OutbreakDatapoint *)nearestOutbreakToPoint:(CLLocationCoordinate2D) coord {
    if ([[OutbreakDatapoint MR_findAll] count] > 0) {
        CLLocationDistance minDistance = CLLocationDistanceMax;
        OutbreakDatapoint *closestPoint;
        for (OutbreakDatapoint *d in [OutbreakDatapoint MR_findAll]) {
            CLLocation *coordLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
            CLLocation *datapointLocation = [[CLLocation alloc] initWithLatitude:[d.latitude floatValue] longitude:[d.longitude floatValue]];
            if ([coordLocation distanceFromLocation:datapointLocation] < minDistance) {
                minDistance = [coordLocation distanceFromLocation:datapointLocation];
                closestPoint = d;
            }
        }
        
        return closestPoint;
    } else
        return nil;
}

- (int)array:(NSArray *)array containsLocalizedOutbreakAtCoordinate:(CLLocationCoordinate2D)coordinate {
    float epsilon = 0.001f;
    for (int i = 0; i < [array count]; i++) {
        LocalizedOutbreak *l = [array objectAtIndex:i];
        if (fabs(l.coordinate.latitude - coordinate.latitude) <= epsilon
            && fabs(l.coordinate.longitude - coordinate.longitude) <= epsilon) {
            return i;
        }
    }
    
    return -1;
}

- (void)logAllCases {
    for (OutbreakDatapoint *c in [OutbreakDatapoint MR_findAll]) {
        NSLog(@"%@", [NSString stringWithFormat:@"%@, Parent: %@", c.idString, c.parent.idString]);
    }
}

- (int)totalCases {
    NSArray *allCases = [OutbreakDatapoint MR_findAll];
    if ([allCases count] > 0) {
        int cases = 0;
        
        for (OutbreakDatapoint *d in allCases) {
            cases += [d.cases intValue];
        }
        return cases;
    }
    return 0;
}

- (int)totalDeaths {
    NSArray *allCases = [OutbreakDatapoint MR_findAll];
    if ([allCases count] > 0) {
        int cases = 0;
        
        for (OutbreakDatapoint *d in allCases) {
            cases += [d.deaths intValue];
        }
        return cases;
    }
    return 0;
}

- (int)percentMortality {
    int deaths = [[OutbreakDataManager sharedOutbreakDataManager] totalDeaths];
    int cases = [[OutbreakDataManager sharedOutbreakDataManager] totalCases];
    
    return (int)((double) deaths / (double)cases * 100);
}

- (int)weeksWorthOfData {
    double oldestDatapointAgeInSeconds = [[[[OutbreakDatapoint MR_findAllSortedBy:@"date" ascending:YES] firstObject] date] timeIntervalSince1970];
    double timeInSeconds = [[NSDate date] timeIntervalSince1970];
    
    double elapsedTime = timeInSeconds - oldestDatapointAgeInSeconds;
    double weeks = elapsedTime / (60*60*24*7);
    return weeks;
}

- (int)casesPerWeekWithIndex:(int)week {
    int casesInWeek = 0;
    NSArray *sortedDatapoints = [OutbreakDatapoint MR_findAllSortedBy:@"date" ascending:YES];
    double weekStart = self.oldestEntry + (week * 60 * 60 * 24 * 7);
    double weekEnd = weekStart + ((60 * 60 * 24 * 7) - 1);
        
    for (OutbreakDatapoint *d in sortedDatapoints) {
        if ([d.date timeIntervalSince1970] > weekEnd)
            break;
        casesInWeek += [d.cases intValue];
    }
    
    if (casesInWeek > 0) {
        return casesInWeek;
    } else if (casesInWeek == 0 && week > 0)
        return [self casesPerWeekWithIndex:week - 1];
    else
        return 0;
}

@end
