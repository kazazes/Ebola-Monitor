//
//  PrimaryViewController.h
//  Outbreak
//
//  Created by Peter on 10/9/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

@import Mapbox;

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OutbreakMapView.h"
#import "UIImage+Overlay.h"
#import <FlatUIKit/UIColor+FlatUI.h>
#import <QuartzCore/QuartzCore.h>
#import "CircleView.h"
#import <POP/POP.h>
#import "OutbreakDataManager.h"
#import "objc/message.h"
#import "OutbreakDatapoint.h"
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "StatsView.h"
#import "OutbreakLocationManager.h"


@interface PrimaryViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) OutbreakMapView *mapView;
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) UIButton *maximizeButton;
@property (strong, nonatomic) UIButton *notificationButton;
@property (strong, nonatomic) CircleView *circleView;
@property (nonatomic, strong) CWStatusBarNotification *notification;
@property (nonatomic, strong) StatsView *statsView;
@property (nonatomic, strong) NSDate *lastStoredLocationDate;
@property (nonatomic, strong) OutbreakLocationManager *ebolaLocationManager;

@end

