//
//  PrimaryViewController.m
//  Ebola
//
//  Created by Peter on 10/9/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import "PrimaryViewController.h"
#import "CBZSplashView.h"
#import "UIBezierPath+Shapes.h"
#import <Social/Social.h>
#import <STTwitter/STTwitter.h>
#import <Reachability/Reachability.h>
#import "EbolaConfig.h"

@interface PrimaryViewController ()

@property (nonatomic, strong) CBZSplashView *splashView;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic) BOOL hasIntroed;
@property (nonatomic, strong) UIView *noConnectionView;

@end

@implementation PrimaryViewController

- (void)setupStatsView {
    self.statsView = [[[NSBundle mainBundle] loadNibNamed:@"StatsView" owner:self options:nil] firstObject];
    [self.statsView setFrame:CGRectMake(0, self.circleView.frame.size.height + self.circleView.frame.origin.y + 10, [[UIScreen mainScreen] bounds].size.width, 1500 - [[UIScreen mainScreen] bounds].size.height * .45f)];
    [self.scrollView addSubview:self.statsView];
}

- (void)viewDidLoad {
    UIBezierPath *path = [UIBezierPath ebolaShape];
    CBZSplashView *splashView = [CBZSplashView splashViewWithBezierPath:path backgroundColor:[UIColor pomegranateColor]];
    splashView.animationDuration = 1.4;
    splashView.iconStartSize = CGSizeMake(60 / 3, 65 / 3);
    self.splashView = splashView;
    [self.view addSubview:self.splashView];
    
    [super viewDidLoad];
    [self setupProgressNotifications];
    
    self.noConnectionView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] firstObject];
    [self.noConnectionView setFrame:self.view.frame];
    [self.view addSubview:self.noConnectionView];
    self.noConnectionView.hidden = YES;
    
    self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.bounces = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 1500);
    self.view.backgroundColor = [UIColor cloudsColor];
    
    [self setupCircle];
    [self setupButtons];
    [self setupStatsView];
}

- (void)setupProgressNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"UpdateDatapointsStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"UpdateDatapointsProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"UpdatedDatapoints" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorizationStatusChanged:) name:@"AuthorizationStatusChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationsUpdated:) name:@"LocationsUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentLocationServicesError) name:@"LocationPermissionsError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTwitterAccountError) name:@"TwitterAccountError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTwitterDeniedError) name:@"TwitterAccountAccessDenied" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentGenericTwitterError) name:@"GenericTwitterError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(composeTemplateTweet:) name:@"ComposeTemplateTweet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationsEnabled:) name:@"NotificationsEnabled" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationsDeclined) name:@"NotificationsDeclined" object:nil];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    if ([notification.object currentReachabilityStatus] == ReachableViaWiFi
        || [notification.object currentReachabilityStatus] == ReachableViaWWAN) {
        self.noConnectionView.hidden = YES;
        [self setupMap];
        float mapSize = [[UIScreen mainScreen] bounds].size.width - ([[UIScreen mainScreen] bounds].size.width * .2);
        CGRect mapFrame = CGRectMake(([[UIScreen mainScreen] bounds].size.width * .1), [[UIScreen mainScreen] bounds].size.height * .05, mapSize, mapSize);
        [self.mapView setFrame:mapFrame];
        self.mapView.layer.cornerRadius = CGRectGetWidth(self.mapView.frame) / 2;
        [self.view bringSubviewToFront:self.mapView];
        [[EbolaDataManager sharedEbolaDataManager] refreshOutbreakDatapoints];
    } else {
        self.noConnectionView.hidden = NO;
    }
}

- (void)composeTemplateTweet:(NSNotification *)notification {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        EbolaLocationManager *locationManager = [EbolaLocationManager sharedEbolaLocationManager];
        NSLocale *locale = [NSLocale currentLocale];
        BOOL isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
        
        if ([locationManager locationTrackingPermissionGranted]) {
            if ([locationManager location]) {
                CLLocationDistance distanceInMeters = [[EbolaDataManager sharedEbolaDataManager] distanceFromOutbreakInMetersFromPoint:[[locationManager location] coordinate]];
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
                [tweetSheet setInitialText:[NSString stringWithFormat:@"Ebola is %@ away from me! #ebolatracker", distanceUnitString]];
            } else {
                [tweetSheet setInitialText:@"Where's ebola? #ebolatracker"];
            }
        } else {
            [tweetSheet setInitialText:@"Where's ebola? #ebolatracker"];
        }
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
        [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            NSLog(@"-- Account: %@", username);
            [self composeTemplateTweet:nil];
        } errorBlock:^(NSError *error) {
            NSLog(@"-- %@", [error localizedDescription]);
            if ([error code] == 2) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterAccountAccessDenied" object:nil];
            } else if ([error code] == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterAccountError" object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GenericTwitterError" object:nil];
            }
        }];
        
    }
}

- (void)presentTwitterDeniedError {
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationLabelBackgroundColor = [UIColor sunflowerColor];
    self.notification.notificationLabelTextColor = [UIColor midnightBlueColor];
    self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    [self.notification displayNotificationWithMessage:@"Access to Twitter denied. Change in Settings." forDuration:3.0f];
}

- (void)presentGenericTwitterError {
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationLabelBackgroundColor = [UIColor sunflowerColor];
    self.notification.notificationLabelTextColor = [UIColor midnightBlueColor];
    self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    [self.notification displayNotificationWithMessage:@"There was an issue loading the stream." forDuration:3.0f];
}

- (void)presentTwitterAccountError {
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationLabelBackgroundColor = [UIColor sunflowerColor];
    self.notification.notificationLabelTextColor = [UIColor midnightBlueColor];
    self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    [self.notification displayNotificationWithMessage:@"You must add a Twitter account in Settings." forDuration:3.0f];
}

- (void)updateProgress:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"UpdateDatapointsStarted"]) {
        [self.circleView startGlowingWithColor:[UIColor emerlandColor] intensity:1.0f];
    } else if ([notification.name isEqualToString:@"UpdateDatapointsProgress"]) {
        //        NSNumber *progress = [notification.userInfo objectForKey:@"progress"];
    } else if ([notification.name isEqualToString:@"UpdatedDatapoints"]) {
        [self centerInfectionAndLocationBoundingView];
        [self.statsView statsShouldRefresh:nil];
        NSTimer *t = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(stopCircleGlowing) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.hasIntroed) {
        [self.splashView startAnimation];
        self.hasIntroed = YES;
    }
    
    [[EbolaLocationManager sharedEbolaLocationManager] setHasFoundLocation:NO];
    [self viewWillTransitionToSize:[[UIScreen mainScreen] bounds].size withTransitionCoordinator:nil];
    [self centerMapOnMe];
    [self.circleView startGlowingWithColor:[UIColor emerlandColor] intensity:1.0f];
    [self setNotificationButtonToProperState];
}

- (void)stopCircleGlowing {
    [self.circleView stopGlowing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [[EbolaDataManager sharedEbolaDataManager] refreshOutbreakDatapoints];
}

- (BOOL)mapMaximized {
    if (self.mapView.layer.cornerRadius > 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - view setup

- (void)setupMap {
    CGRect mapFrame;
    
    mapFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.mapView = [[EbolaMapView alloc] initWithFrame:mapFrame styleURL:[NSURL URLWithString:MAPBOX_STYLE]];
    self.mapView.layer.cornerRadius = 0;
    
    self.mapView.delegate = self.mapView;
    [self.scrollView addSubview:self.mapView];
    
    [self.mapView setZoomLevel:MAPBOX_DEFAULT_ZOOM];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(MAPBOX_DEFAULT_LATITUDE, MAPBOX_DEFAULT_LONGITUDE)];
    
    self.mapView.clipsToBounds = YES;
    [self.view bringSubviewToFront:self.circleView];
    [self.view bringSubviewToFront:self.statsView];
}

- (void)setupCircle {
    [self.circleView removeFromSuperview];
    self.circleView = nil;
    float mapSize = [[UIScreen mainScreen] bounds].size.width - ([[UIScreen mainScreen] bounds].size.width * .2);
    CGRect mapFrame = CGRectMake(([[UIScreen mainScreen] bounds].size.width * .1), [[UIScreen mainScreen] bounds].size.height * .05, mapSize, mapSize);
    self.circleView = [[CircleView alloc] initWithFrame:CGRectMake(0, 0, mapFrame.size.width + 4, mapFrame.size.height + 4)];
    [self.circleView setCenter:CGPointMake(mapFrame.origin.x + mapFrame.size.width / 2, mapFrame.origin.y + mapFrame.size.height / 2)];
    self.circleView.strokeColor = [UIColor alizarinColor];
    [self.scrollView addSubview:self.circleView];
    [self.scrollView bringSubviewToFront:self.mapView];
    [self.scrollView bringSubviewToFront:self.maximizeButton];
    [self.scrollView bringSubviewToFront:self.locationButton];
    [self.circleView setStrokeEnd:1.0f animated:YES];
}

- (void)refreshStats {
    [self.statsView refreshStats];
    [self.scrollView bringSubviewToFront:self.statsView];
}

- (void)setupButtons {
    [self.locationButton removeFromSuperview];
    [self.maximizeButton removeFromSuperview];
    
    // location button
    self.locationButton = [[UIButton alloc] initWithFrame:CGRectMake(40 - 16, 40 - 16, 28, 28)];
    [self.locationButton addTarget:self action:@selector(locationButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *deselectedImage = [UIImage imageNamed:@"Location deselected"];
    deselectedImage = [deselectedImage imageWithColor:[UIColor alizarinColor]];
    UIImage *selectedImage = [UIImage imageNamed:@"Location selected"];
    selectedImage = [selectedImage imageWithColor:[UIColor alizarinColor]];
    [self.locationButton setImage:deselectedImage forState:UIControlStateNormal];
    [self.locationButton setImage:selectedImage forState:UIControlStateSelected];
    [self.scrollView addSubview:self.locationButton];
    
    // maximize button
    self.maximizeButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 40 - 16, 40 - 16, 28, 28)];
    [self.maximizeButton addTarget:self action:@selector(maximizeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *maximizeImage = [UIImage imageNamed:@"Maximize"];
    maximizeImage = [maximizeImage imageWithColor:[UIColor alizarinColor]];
    UIImage *minimizeImage = [UIImage imageNamed:@"Minimize"];
    minimizeImage = [minimizeImage imageWithColor:[UIColor alizarinColor]];
    [self.maximizeButton setImage:maximizeImage forState:UIControlStateNormal];
    [self.maximizeButton setImage:minimizeImage forState:UIControlStateSelected];
    [self.scrollView addSubview:self.maximizeButton];
    
    // notification button
    self.notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(40 - 16, self.circleView.frame.origin.x + self.circleView.frame.size.height - 28, 28, 28)];
    [self.notificationButton addTarget:self action:@selector(notificationButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *notificationsEnabledImage = [UIImage imageNamed:@"Bell selected"];
    notificationsEnabledImage = [notificationsEnabledImage imageWithColor:[UIColor alizarinColor]];
    UIImage *notificationsDisabledImage = [UIImage imageNamed:@"Bell deselected"];
    notificationsDisabledImage = [notificationsDisabledImage imageWithColor:[UIColor alizarinColor]];
    [self.notificationButton setImage:notificationsDisabledImage forState:UIControlStateNormal];
    [self.notificationButton setImage:notificationsEnabledImage forState:UIControlStateSelected];
    [self.notificationButton.imageView setContentMode:UIViewContentModeCenter];
    [self.notificationButton setFrame:CGRectInset(self.notificationButton.frame, -20, -20)];
    [self.scrollView addSubview:self.notificationButton];
    
    [self.scrollView bringSubviewToFront:self.notificationButton];
    [self.scrollView bringSubviewToFront:self.locationButton];
    [self.scrollView bringSubviewToFront:self.maximizeButton];
}

#pragma mark - button handlers

- (IBAction)locationButtonPushed:(id)sender {
    if (self.locationButton.selected) {
        // if location is being tracked
        if ([self mapMaximized]) {
            [self centerInfectionAndLocationBoundingView];
        } else {
            [self centerMapOnMe];
        }
    } else {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied
            || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
            [self presentLocationServicesError];
        } else {
            [[EbolaLocationManager sharedEbolaLocationManager] requestAndUpdateLocation];
        }
    }
}

- (IBAction)notificationButtonPushed:(id)sender {
    [[EbolaDataManager sharedEbolaDataManager] requestPushNotificationPrivileges];
}

- (void)setNotificationButtonToProperState {
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [[EbolaDataManager sharedEbolaDataManager] requestPushNotificationPrivileges];
    } else {
        [self.notificationButton setSelected:NO];
    }
}

- (void)notificationsEnabled:(NSNotification *)notification {
    [self.notificationButton setHidden:YES];
}

- (void)pushNotificationsEnabledMessage {
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationLabelBackgroundColor = [UIColor emerlandColor];
    self.notification.notificationLabelTextColor = [UIColor cloudsColor];
    self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    [self.notification displayNotificationWithMessage:@"Push alerts succesfully enabled." forDuration:3.0f];
}

- (void)presentLocationServicesError {
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationLabelBackgroundColor = [UIColor pomegranateColor];
    self.notification.notificationLabelTextColor = [UIColor cloudsColor];
    self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    [self.notification displayNotificationWithMessage:@"Please enable location services in Settings." forDuration:3.0f];
}

- (void)notificationsDeclined {
    self.notification = [CWStatusBarNotification new];
    self.notification.notificationLabelBackgroundColor = [UIColor pomegranateColor];
    self.notification.notificationLabelTextColor = [UIColor cloudsColor];
    self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    self.notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    [self.notification displayNotificationWithMessage:@"Please enable notifications in Settings." forDuration:3.0f];
}

- (IBAction)maximizeButtonPushed:(id)sender {
    if ([self mapMaximized]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float mapSize = [[UIScreen mainScreen] bounds].size.width - ([[UIScreen mainScreen] bounds].size.width * .2);
            CGRect mapFrame = CGRectMake(([[UIScreen mainScreen] bounds].size.width * .1), [[UIScreen mainScreen] bounds].size.height * .05, mapSize, mapSize);
            [self.mapView setFrame:mapFrame];
            self.mapView.layer.cornerRadius = CGRectGetWidth(self.mapView.frame) / 2;
            [[UIDevice currentDevice] setValue:
             [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                        forKey:@"orientation"];
            self.maximizeButton.selected = NO;
        });
    } else {
        self.maximizeButton.selected = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mapView.layer.cornerRadius = 0;
            [self.mapView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            [self.scrollView bringSubviewToFront:self.mapView];
            [self.scrollView bringSubviewToFront:self.maximizeButton];
            [self.scrollView bringSubviewToFront:self.locationButton];
            [[UIDevice currentDevice] setValue:
             [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft]
                                        forKey:@"orientation"];
        });
    }
}

#pragma mark - <CLLocationDelegate>

- (void)locationsUpdated:(NSNotification *)notification {
    self.lastStoredLocationDate = [NSDate date];
    
    if (![[EbolaLocationManager sharedEbolaLocationManager] hasFoundLocation] && [[OutbreakDatapoint MR_findAll] count]) {
        [[EbolaLocationManager sharedEbolaLocationManager] setHasFoundLocation:YES];
        [self centerInfectionAndLocationBoundingView];
        [self refreshStats];
    }
    
    unsigned int unitFlags = NSCalendarUnitMinute;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *conversionInfo = [calendar components:unitFlags fromDate:self.lastStoredLocationDate toDate:[NSDate date]  options:0];
    
    long minutesSinceLocalization = [conversionInfo minute];
    
    conversionInfo = [calendar components:unitFlags fromDate:self.mapView.lastMapMove toDate:[NSDate date]  options:0];
    
    long minutesSinceMapMovement = [conversionInfo minute];
    
    if (minutesSinceLocalization > 5 && minutesSinceMapMovement > minutesSinceLocalization ) {
        [self refreshStats];
        [self centerInfectionAndLocationBoundingView];
        self.lastStoredLocationDate = [NSDate date];
    }
}

- (void)authorizationStatusChanged:(NSNotification *)notification {
    int status = [[[notification userInfo] objectForKey:@"status"] intValue];
    if (status == kCLAuthorizationStatusNotDetermined || status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        // set deselected
        self.locationButton.selected = NO;
        [[EbolaLocationManager sharedEbolaLocationManager] setLocationTrackingPermissionGranted:NO];
        [[EbolaLocationManager sharedEbolaLocationManager] setHasFoundLocation:NO];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        // set selected
        self.locationButton.selected = YES;
        self.mapView.showsUserLocation = YES;
        [[EbolaLocationManager sharedEbolaLocationManager] setLocationTrackingPermissionGranted:YES];
        [[EbolaLocationManager sharedEbolaLocationManager] requestAndUpdateLocation];
    }
}

- (void)centerMapOnMe {
    if ([[EbolaLocationManager sharedEbolaLocationManager] locationTrackingPermissionGranted]) {
        CLLocation *location = [[EbolaLocationManager sharedEbolaLocationManager] location];
        if (location) {
            [self.mapView setShowsUserLocation:YES];
            double distance = [[EbolaDataManager sharedEbolaDataManager] distanceFromOutbreakInMetersFromPoint:location.coordinate];
            if (distance > 0 && distance / METERS_IN_MILE < 300) {
                [self centerInfectionAndLocationBoundingView];
            } else {
                [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude) zoomLevel:10 animated:YES];
            }
        }
    }
}

- (void)centerInfectionAndLocationBoundingView {
    if ([[EbolaLocationManager sharedEbolaLocationManager] locationTrackingPermissionGranted]) {
        CLLocation *location = [[EbolaLocationManager sharedEbolaLocationManager] location];
        if (location) {
            [self.mapView showsUserLocation];
            OutbreakDatapoint *closestOutbreak = [[EbolaDataManager sharedEbolaDataManager] nearestOutbreakToPoint:location.coordinate];
            if (closestOutbreak) {
                CLLocationCoordinate2D closestCoordinate = CLLocationCoordinate2DMake([closestOutbreak.latitude floatValue], [closestOutbreak.longitude floatValue]);
                
                CLLocationDegrees minLat = location.coordinate.latitude;
                CLLocationDegrees minLong = location.coordinate.longitude;
                CLLocationDegrees maxLat = location.coordinate.latitude;
                CLLocationDegrees maxLong = location.coordinate.longitude;
                
                if (closestCoordinate.latitude < minLat)
                    minLat = closestCoordinate.latitude;
                if (closestCoordinate.longitude < minLong)
                    minLong = closestCoordinate.longitude;
                if (closestCoordinate.latitude > maxLat)
                    maxLat = closestCoordinate.latitude;
                if (closestCoordinate.longitude > maxLong)
                    maxLong = closestCoordinate.longitude;
                
                CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(minLat, minLong);
                CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(maxLat, maxLong);
                MGLCoordinateBounds bounds = MGLCoordinateBoundsMake(southWest, northEast);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mapView setVisibleCoordinateBounds:bounds animated:YES];
                    [self.mapView setZoomLevel:self.mapView.zoomLevel - 1 animated:NO];
                });
            }
        }
    }
}

#pragma mark - <MPAdViewDelegate>

- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    if (size.width < size.height) {
        // portrait
        [self.maximizeButton setFrame:CGRectMake(size.width - 40 - 16, 40 - 16, 28, 28)];
        float mapSize = size.width - size.width * .2;
        [self.mapView setFrame:CGRectMake(size.width * .1, size.height * .05, mapSize, mapSize)];
        self.scrollView.contentSize = CGSizeMake(size.width, 1500);
        self.mapView.layer.cornerRadius = CGRectGetWidth(self.mapView.frame) / 2;
        [self.statsView setFrame:CGRectMake(0, size.height * .5f, size.width, 1500 - size.height * .45f)];
        [self setupCircle];
        [self.statsView setFrame:CGRectMake(0, self.circleView.frame.size.height + self.circleView.frame.origin.y + 10, size.width, 1500 - size.height * .45f)];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
