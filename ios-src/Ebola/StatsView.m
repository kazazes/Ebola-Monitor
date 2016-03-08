//
//  StatsView.m
//  Outbreak
//
//  Created by Peter on 11/5/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import "StatsView.h"
#import "OutbreakLocationManager.h"
#import "OutbreakDataManager.h"
#import <STTwitter/STTwitter.h>
#import <TwitterKit/TwitterKit.h>
#import "AppDelegate.h"

@interface StatsView()

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) TWTRTweetTableViewCell *prototypeCell;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) NSDate *lastTweetShown;
@property (strong, nonatomic) IBOutlet UISwitch *liveSwitch;
@property (strong, nonatomic) id streamRequest;

@end

@implementation StatsView

- (void)awakeFromNib {
    self.lineGraph.colorTop = [UIColor cloudsColor];
    self.lineGraph.colorLine = [UIColor pomegranateColor];
    self.lineGraph.colorBottom = [UIColor alizarinColor];
    self.lineGraph.colorPoint = [UIColor pomegranateColor];
    self.lineGraph.widthLine = 1.5f;
    //    self.lineGraph.autoScaleYAxis = NO;
    
    self.tweetTableView.estimatedRowHeight = 150;
    self.tweetTableView.rowHeight = UITableViewAutomaticDimension;
    self.tweetTableView.allowsSelection = NO;
    [self.tweetTableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:@"TweetTableCell"];
    [self.tweetTableView setBackgroundColor:[UIColor clearColor]];
    
    self.lastTweetShown = [NSDate dateWithTimeIntervalSince1970:0];
    
    self.tweets = [NSMutableArray array];
    [self loadDemoTweets];
    
    [self.liveSwitch setOnTintColor:[UIColor nephritisColor]];
    [self.liveSwitch setTintColor:[UIColor alizarinColor]];
    
    self.prototypeCell = [[TWTRTweetTableViewCell alloc] init];
    
    self.prototypeCell.tweetView.backgroundColor = [UIColor cloudsColor];
    self.prototypeCell.tweetView.primaryTextColor = [UIColor nephritisColor];
}

#pragma mark - Stats

- (void)statsShouldRefresh:(NSNotification *)notification {
    [self reloadGraph];
    [self refreshDistanceLabel];
    [self refreshMortalityLabels];
}

- (void)reloadGraph {
    [self.lineGraph reloadGraph];
}

- (void)refreshStats {
    [self refreshDistanceLabel];
    [self refreshMortalityLabels];
}

- (void)refreshDistanceLabel {
    OutbreakLocationManager *locationManager = [OutbreakLocationManager sharedOutbreakLocationManager];
    NSLocale *locale = [NSLocale currentLocale];
    BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    
    if ([locationManager locationTrackingPermissionGranted]) {
        if ([locationManager location]) {
            self.distanceLabel.hidden = NO;
            self.distanceButton.hidden = YES;
            CLLocationDistance distanceInMeters = [[OutbreakDataManager sharedOutbreakDataManager] distanceFromOutbreakInMetersFromPoint:[[locationManager location] coordinate]];
            NSString *distanceUnitString;
            if (isMetric) {
                distanceUnitString = [NSString stringWithFormat:@"%.1f kilometers", distanceInMeters / 1000];
            } else {
                if (distanceInMeters / METERS_IN_MILE < 1) {
                    distanceUnitString = @"less than a mile";
                } else if (distanceInMeters / METERS_IN_MILE < 100) {
                    distanceUnitString = [NSString stringWithFormat:@"%.1f miles", distanceInMeters / METERS_IN_MILE];
                } else {
                    distanceUnitString = [NSString stringWithFormat:@"%.0f miles", distanceInMeters / METERS_IN_MILE];
                }
            }
            
            NSString *distanceString = [NSString stringWithFormat:@"You are currently %@ from an %@ case.", distanceUnitString, DISEASE];
            self.distanceLabel.text = distanceString;
        }
    } else {
        // display location button
        self.distanceButton.hidden = NO;
        self.distanceLabel.hidden = YES;
    }
}

- (void)refreshMortalityLabels {
    int deaths = [[OutbreakDataManager sharedOutbreakDataManager] totalDeaths];
    int cases = [[OutbreakDataManager sharedOutbreakDataManager] totalCases];
    int percentMortality = [[OutbreakDataManager sharedOutbreakDataManager] percentMortality];
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.deathsLabel.text = [NSString stringWithFormat:@"%@ reported deaths", [numberFormatter stringFromNumber:[NSNumber numberWithInt:deaths]]];
    self.casesLabel.text = [NSString stringWithFormat:@"%@ reported cases", [numberFormatter stringFromNumber:[NSNumber numberWithInt:cases]]];
    self.mortalityLabel.text = [NSString stringWithFormat:@"~%@%@ mortality", [numberFormatter stringFromNumber:[NSNumber numberWithInt:percentMortality]], @"%"];
}

#pragma mark - Line chart delegate

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    if ([[OutbreakDatapoint MR_findAll] count] > 0) {
        self.lineGraph.hidden = NO;
        int weeks = [[OutbreakDataManager sharedOutbreakDataManager] weeksWorthOfData];
        return weeks;
    } else {
        return 0;
    }
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    if ([[OutbreakDatapoint MR_findAll] count] > 0) {
        int cases = [[OutbreakDataManager sharedOutbreakDataManager] casesPerWeekWithIndex:[[NSNumber numberWithInteger:index] intValue]];
        if (cases == 0) {
            cases = [[OutbreakDataManager sharedOutbreakDataManager] casesPerWeekWithIndex:[[NSNumber numberWithInteger:index - 1] intValue]];
        }
        return cases;
    } else {
        return 0;
    }
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    if ([[OutbreakDatapoint MR_findAll] count] > 0) {
        int weeks = [[OutbreakDataManager sharedOutbreakDataManager] weeksWorthOfData];
        int intdex = [[NSNumber numberWithInteger:index] intValue];
        if (index != 0 && index != weeks - 1) {
            return [[NSNumber numberWithInt:weeks - intdex] stringValue];
        } else {
            return @"";
        }
    } else {
        return @"";
    }
}

- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @" deaths";
}

#pragma mark - Tweet Stream

- (void)loadDemoTweets {
    self.twitter = nil;
    
    NSArray *tweetIDs = @[@"532642763888918529",
                          @"534760625688551424",
                          @"534458766792863746",
                          @"532514504773734400",
                          ];
    
    [[Twitter sharedInstance] logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        [[[Twitter sharedInstance] APIClient] loadTweetsWithIDs:tweetIDs completion:^(NSArray *tweets, NSError *error) {
            for (TWTRTweet *tweet in tweets) {
                [self.tweets addObject:tweet];
            }
            [self.tweetTableView reloadData];
        }];
    }];
}

- (IBAction)liveSwitchValueChanged:(id)sender {
    if ([sender isOn]) {
        NSLog(@"Switch on.");
        [self.liveSwitch setEnabled:NO];
        [self startTwitterStream];
    } else if (![sender isOn]) {
        NSLog(@"Switch off.");
        if (self.streamRequest) {
            [self.streamRequest cancel];
            self.streamRequest = nil;
        }
        self.twitter = nil;
    }
}

- (void)startTwitterStream {
    self.twitter = nil;
    self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
    [[Twitter sharedInstance] logInGuestWithCompletion:nil];
    
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        NSLog(@"-- Account: %@", username);
        self.streamRequest = [self.twitter postStatusesFilterKeyword:@"zika" tweetBlock:^(NSDictionary *dict) {
            if (fabs([self.lastTweetShown timeIntervalSinceNow]) > 1.5 || [[dict objectForKey:@"screen_name"] isEqualToString:username]) {
                if ([dict isKindOfClass:[NSDictionary class]] == NO) {
                    NSLog(@"Invalid tweet (class %@): %@", [dict class], dict);
                    return;
                }
                
                [[[Twitter sharedInstance] APIClient] loadTweetWithID:[dict objectForKey:@"id_str"] completion:^(TWTRTweet *tweet, NSError *error) {
                    if (tweet) {
                        if (![self.liveSwitch isEnabled]) {
                            [self.liveSwitch setEnabled:YES];
                        }
                        
                        [self.tweetTableView beginUpdates];
                        [self insertTweetIntoTweets:tweet];
                        [self.tweetTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                        if ([self.tweetTableView numberOfRowsInSection:0] > 9)
                            [self.tweetTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:9 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.tweetTableView endUpdates];
                        self.lastTweetShown  = [NSDate date];
                    }
                }];
            }
        } errorBlock:^(NSError *error) {
            [self.liveSwitch setEnabled:YES];
            [self.liveSwitch setOn:NO animated:YES];
            NSLog(@"-- %@", [error localizedDescription]);
            if([[error domain] isEqualToString:NSURLErrorDomain] && [error code] == NSURLErrorNetworkConnectionLost) {
                NSLog(@"Stream connection lost, attempting to restart");
                [self startTwitterStream];
            } else if ([error code] == 2) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterAccountAccessDenied" object:nil];
            } else if ([error code] == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterAccountError" object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GenericTwitterError" object:nil];
            }
        }];
    } errorBlock:^(NSError *error) {
        [self.liveSwitch setEnabled:YES];
        [self.liveSwitch setOn:NO animated:YES];
        NSLog(@"-- %@", [error localizedDescription]);
        if([[error domain] isEqualToString:NSURLErrorDomain] && [error code] == NSURLErrorNetworkConnectionLost) {
            NSLog(@"Stream connection lost, attempting to restart");
            [self startTwitterStream];
        } else if ([error code] == 2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterAccountAccessDenied" object:nil];
        } else if ([error code] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterAccountError" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GenericTwitterError" object:nil];
        }
    }];
}


- (void)insertTweetIntoTweets:(TWTRTweet *)tweet {
    [self.tweetTableView beginUpdates];
    if ([self.tweets count] >= 20)
        [self.tweets removeObjectAtIndex:0];
    [self.tweets addObject:tweet];
    [self.tweetTableView endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = [[NSNumber numberWithInteger:[self.tweets count]] intValue];
    if (count > 10) {
        return 10;
    } else return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *) [self.tweetTableView dequeueReusableCellWithIdentifier:@"TweetTableCell" forIndexPath:indexPath];
    [cell configureWithTweet:[self.tweets objectAtIndex:[self.tweets count] - 1 - indexPath.row]];
    cell.tweetView.backgroundColor = [UIColor cloudsColor];
    cell.tweetView.primaryTextColor = [UIColor nephritisColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = [self.tweets objectAtIndex:[self.tweets count] - 1 - indexPath.row];
    [self.prototypeCell configureWithTweet:tweet];
    return [self.prototypeCell calculatedHeightForWidth:CGRectGetWidth([[UIScreen mainScreen] bounds])];
}

- (IBAction)composeTweet:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ComposeTemplateTweet" object:nil];
}

#pragma mark - Button handlers

- (IBAction)distanceFromOutbreakPushed:(id)sender {
    if ([[OutbreakLocationManager sharedOutbreakLocationManager] location]) {
        [self refreshDistanceLabel];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationPermissionsError" object:nil];
    }
}

@end
