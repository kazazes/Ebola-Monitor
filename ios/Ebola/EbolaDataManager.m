//
//  EbolaDataManager.m
//
//
//  Created by Peter on 11/1/14.
//
//

#import "EbolaDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import <MagicalRecord/MagicalRecord.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import "LocalizedOutbreak.h"
#import "EbolaLocationManager.h"
#import "AppDelegate.h"
#import <STTwitter/STTwitter.h>
#import <Accounts/Accounts.h>

@interface EbolaDataManager ()

@property (nonatomic) long oldestEntry;

@end

@implementation EbolaDataManager

+ (EbolaDataManager *)sharedEbolaDataManager {
    static dispatch_once_t once;
    static EbolaDataManager *instance;
    dispatch_once(&once, ^{
        instance = [[EbolaDataManager alloc] init];
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
                if ([d objectForKey:@"parent_id"] != (id)[NSNull null])
                    [a setParentId:[d objectForKey:@"parent_id"]];
            }
        }
        
        for (OutbreakDatapoint *a in [OutbreakDatapoint MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId != nil"]]) {
                [a setParent:[OutbreakDatapoint MR_findFirstByAttribute:@"idString" withValue:a.parentId]];
        }
        
        self.oldestEntry = [[[[OutbreakDatapoint MR_findAllSortedBy:@"date" ascending:YES] firstObject] date] timeIntervalSince1970];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatedDatapoints" object:nil userInfo:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILED TO LOAD. %@", error);
    }];
    [operation start];
}

- (NSArray *)getParentOutbreaks {
    NSArray *setParentIds = [OutbreakDatapoint MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"parentId != ''"]];
    NSMutableArray *parents = [NSMutableArray array];
    
    for (OutbreakDatapoint *d in setParentIds) {
        if (d.parent)
            [parents addObject:d.parent];
    }
    
    return parents;
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
    if ([[OutbreakDatapoint MR_findAll] count] > 0) {
        
        NSArray *countries = [[EbolaDataManager sharedEbolaDataManager] countries];
        int cases = 0;
        
        for (NSString *d in countries) {
            
            NSArray *allInCountry = [OutbreakDatapoint MR_findByAttribute:@"country" withValue:d];
            allInCountry = [allInCountry sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                OutbreakDatapoint *one = (OutbreakDatapoint *) obj1;
                OutbreakDatapoint *two = (OutbreakDatapoint *) obj2;
                
                if ([one.date timeIntervalSince1970] > [two.date timeIntervalSince1970]) {
                    return (NSComparisonResult)NSOrderedAscending;
                } else if ([one.date timeIntervalSince1970] < [two.date timeIntervalSince1970]) {
                    return (NSComparisonResult)NSOrderedDescending;
                } else {
                    return (NSComparisonResult)NSOrderedSame;
                }
            }];
            
            cases += [((OutbreakDatapoint *)[allInCountry firstObject]).cases intValue];
        }
        
        return cases;
    }
    
    return 0;
    
}

- (int)totalDeaths {
    if ([[OutbreakDatapoint MR_findAll] count] > 0) {
        
        NSArray *countries = [[EbolaDataManager sharedEbolaDataManager] countries];
        int deaths = 0;
        
        for (NSString *d in countries) {
            
            NSArray *allInCountry = [OutbreakDatapoint MR_findByAttribute:@"country" withValue:d];
            allInCountry = [allInCountry sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                OutbreakDatapoint *one = (OutbreakDatapoint *) obj1;
                OutbreakDatapoint *two = (OutbreakDatapoint *) obj2;
                
                if ([one.date timeIntervalSince1970] > [two.date timeIntervalSince1970]) {
                    return (NSComparisonResult)NSOrderedAscending;
                } else if ([one.date timeIntervalSince1970] < [two.date timeIntervalSince1970]) {
                    return (NSComparisonResult)NSOrderedDescending;
                } else {
                    return (NSComparisonResult)NSOrderedSame;
                }
            }];
            
            deaths += [((OutbreakDatapoint *)[allInCountry firstObject]).deaths intValue];
        }
        
        return deaths;
    }
    
    return 0;
}

- (int)percentMortality {
    int deaths = [[EbolaDataManager sharedEbolaDataManager] totalDeaths];
    int cases = [[EbolaDataManager sharedEbolaDataManager] totalCases];
    
    return (int)((double) deaths / (double)cases * 100);
}

- (NSArray *)countries {
    NSArray *all = [OutbreakDatapoint MR_findAll];
    NSMutableArray *countries = [NSMutableArray array];
    
    for (OutbreakDatapoint *d in all) {
        if (![countries containsObject:d.country]) {
            [countries addObject:d.country];
        }
    }
    
    return countries;
}

- (int)weeksWorthOfData {
    double oldestDatapointAgeInSeconds = [[[[OutbreakDatapoint MR_findAllSortedBy:@"date" ascending:YES] firstObject] date] timeIntervalSince1970];
    double timeInSeconds = [[NSDate date] timeIntervalSince1970];
    
    double elapsedTime = timeInSeconds - oldestDatapointAgeInSeconds;
    double weeks = elapsedTime / (60*60*24*7);
    return weeks;
}

- (int)deathsForWeekWithIndex:(int)week {
    int deathsInWeek = 0;
    for (NSString *country in [[EbolaDataManager sharedEbolaDataManager] countries]) {
        int deathsInCountryWeek = 0;
        NSArray *sortedDatapoints = [OutbreakDatapoint MR_findAllSortedBy:@"date" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"country like %@", country]];
        double weekStart = self.oldestEntry + (week * 60 * 60 * 24 * 7);
        double weekEnd = weekStart + ((60 * 60 * 24 * 7) - 1);
        
        for (OutbreakDatapoint *d in sortedDatapoints) {
            if ([d.date timeIntervalSince1970] > weekEnd)
                break;
            
            deathsInCountryWeek += [d.deaths intValue] - deathsInCountryWeek;
        }
        deathsInWeek += deathsInCountryWeek;
    }
    
    if (deathsInWeek > 0) {
        return deathsInWeek;
    } else if (deathsInWeek == 0 && week > 0)
        return [self deathsForWeekWithIndex:week - 1];
    else
        return 0;
}

@end
