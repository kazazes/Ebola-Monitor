//
//  OutbreakMapView.h
//  Outbreak
//
//  Created by Peter on 10/30/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

@import Mapbox;

@interface OutbreakMapView : MGLMapView <MGLMapViewDelegate>

@property NSDate *lastMapMove;

@end
