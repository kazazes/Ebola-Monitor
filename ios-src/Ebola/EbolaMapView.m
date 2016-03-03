//
//  EbolaMapView.m
//  Ebola
//
//  Created by Peter on 10/30/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import "EbolaMapView.h"
#import "LocalizedOutbreak.h"
#import "EbolaDataManager.h"
#import "UIImage+Overlay.h"
#import "UIImage+Extensions.h"

const float COORDINATE_RANDOM_MODULUS = 0.0004f;

@interface EbolaMapView ()


@end

@implementation EbolaMapView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (id)initWithFrame:(CGRect)frame andTilesource:(id<RMTileSource>)newTilesource {
    if (self = [super initWithFrame:frame andTilesource:newTilesource]) {
        self.lastMapMove = [NSDate date];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedDatapoints:) name:@"UpdatedDatapoints" object:nil];
    }
    
    return self;
}

- (void) layoutSubviews {
    if ([CLLocationManager locationServicesEnabled]) {
        self.showsUserLocation = YES;
    } else {
        self.showsUserLocation = NO;
    }
    [super layoutSubviews];
}

- (void)updatedDatapoints:(NSNotification *)notification {
    __block NSMutableArray *annotationsArray = [NSMutableArray array];
    NSArray *localizedData = [[EbolaDataManager sharedEbolaDataManager] getLocalizedOutbreaks];
    for (LocalizedOutbreak *l in localizedData) {
        // add randomized data at mass points
        int j = 0;
        int casesAdded = 0;
        int deathsAdded = 0;
        while (j < [l.cases intValue] && j <= 50) {
            int rand = arc4random_uniform(100) - 50;
            float xMod = rand * COORDINATE_RANDOM_MODULUS * j / 3;
            rand = arc4random_uniform(100) - 50;
            float yMod = rand * COORDINATE_RANDOM_MODULUS * j / 3;;
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(l.coordinate.latitude + xMod, l.coordinate.longitude + yMod);
            RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self coordinate:coord andTitle:l.country];
            if (j < [l.deaths intValue]) {
                annotation.annotationType = @"death";
                deathsAdded++;
                [annotationsArray addObject:annotation];
            } else if (j < [l.cases intValue] - [l.deaths intValue] && casesAdded <= 25) {
                annotation.annotationType = @"case";
                [annotationsArray addObject:annotation];
            }
            
            j++;
        }
    }
    
    
    [self removeAllAnnotations];
    [self addAnnotations:annotationsArray];
}



- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation {
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    UIImage *annotationImage;
    if ([annotation.annotationType isEqualToString:@"death"]) {
        annotationImage = [UIImage imageNamed:@"Skull"];
    } else if ([annotation.annotationType isEqualToString:@"case"]) {
        annotationImage = [UIImage imageNamed:@"Biohazard"];
    }
    
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:annotationImage];
    
    return marker;
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction {
    if (wasUserAction)
        self.lastMapMove = [NSDate date];
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction {
    if (wasUserAction)
        self.lastMapMove = [NSDate date];
}

@end
