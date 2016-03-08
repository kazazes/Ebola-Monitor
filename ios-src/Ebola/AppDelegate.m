//
//  AppDelegate.m
//  Outbreak
//
//  Created by Peter on 10/9/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import "AppDelegate.h"
#import <TwitterKit/TwitterKit.h>
#import "OutbreakDataManager.h"
#import "OutbreakDatapoint.h"
#import <Reachability/Reachability.h>

@import Mapbox;

@interface AppDelegate ()

@property (nonatomic, strong) Reachability *reach;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    // Override point for customization after application launch.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setValue:
         [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                    forKey:@"orientation"];
    });
    
    self.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [self.reach startNotifier];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    [MGLAccountManager setAccessToken:MAPBOX_TOKEN];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationsEnabled" object:deviceToken];
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[OutbreakDataManager sharedOutbreakDataManager] setDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationsDeclined" object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [OutbreakDatapoint MR_truncateAll];
    [[OutbreakDataManager sharedOutbreakDataManager] saveUserInfo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setValue:
         [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                    forKey:@"orientation"];
    });
    
    [[OutbreakDataManager sharedOutbreakDataManager] refreshOutbreakDatapoints];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setValue:
         [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                    forKey:@"orientation"];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[OutbreakDataManager sharedOutbreakDataManager] saveUserInfo];
    [[OutbreakDataManager sharedOutbreakDataManager] logAllCases];
    [MagicalRecord cleanUp];
}

@end