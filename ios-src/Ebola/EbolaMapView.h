//
//  EbolaMapView.h
//  Ebola
//
//  Created by Peter on 10/30/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import <Mapbox-iOS-SDK/Mapbox.h>

@interface EbolaMapView : RMMapView <RMMapViewDelegate>

@property (nonatomic, strong) NSDate *lastMapMove;

@end
