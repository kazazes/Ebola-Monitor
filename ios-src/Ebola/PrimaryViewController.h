//
//  PrimaryViewController.h
//  Ebola
//
//  Created by Peter on 10/9/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EbolaMapView.h"
#import "UIImage+Overlay.h"
#import <FlatUIKit/UIColor+FlatUI.h>
#import <Mapbox-iOS-SDK/Mapbox.h>
#import <QuartzCore/QuartzCore.h>
#import "CircleView.h"
#import <POP/POP.h>
#import "EbolaDataManager.h"
#import "objc/message.h"
#import "OutbreakDatapoint.h"
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "StatsView.h"
#import "EbolaLocationManager.h"


@interface PrimaryViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) EbolaMapView *mapView;
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) UIButton *maximizeButton;
@property (strong, nonatomic) UIButton *notificationButton;
@property (strong, nonatomic) CircleView *circleView;
@property (nonatomic, strong) CWStatusBarNotification *notification;
@property (nonatomic, strong) StatsView *statsView;
@property (nonatomic, strong) NSDate *lastStoredLocationDate;
@property (nonatomic, strong) EbolaLocationManager *ebolaLocationManager;

@end

