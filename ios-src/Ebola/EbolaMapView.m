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
#import "OutbreakAnnotation.h"

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



- (id)initWithFrame:(CGRect)frame styleURL:(nullable NSURL *)styleURL {
    if (self = [super initWithFrame:frame styleURL:styleURL]) {
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
        int deathsAdded = 0;
        while (j < [l.cases intValue] - [l.deaths intValue]) {
            int rand = arc4random_uniform(100) - 50;
            float xMod = rand * COORDINATE_RANDOM_MODULUS * j / 3;
            rand = arc4random_uniform(100) - 50;
            float yMod = rand * COORDINATE_RANDOM_MODULUS * j / 3;;
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(l.coordinate.latitude + xMod, l.coordinate.longitude + yMod);
            OutbreakAnnotation *ann = [[OutbreakAnnotation alloc] init];
            if (j < [l.deaths intValue]) {
                [ann setIsDeath:TRUE];
                deathsAdded++;
            }
            
            if (!isnan(coord.latitude) && !isnan(coord.latitude)) {
                [ann setCoordinate:coord];
//                [annotationsArray addObject:ann];
            }
            j++;
        }
    }
    
    
    [self removeAnnotations:self.annotations];
    [self addAnnotations:annotationsArray];
}

- (MGLAnnotationImage *) mapView:(MGLMapView *)mapView imageForAnnotation:(id<MGLAnnotation>)annotation {
    if ([(OutbreakAnnotation *) annotation isDeath])
        return [MGLAnnotationImage annotationImageWithImage:[UIImage imageNamed:@"Skull"] reuseIdentifier:@"death"];
    else
        return [MGLAnnotationImage annotationImageWithImage:[UIImage imageNamed:@"Biohazard"] reuseIdentifier:@"case"];
}

- (void) mapView:(MGLMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.lastMapMove = [NSDate date];
}

@end
