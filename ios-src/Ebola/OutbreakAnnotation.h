//
//  OutbreakAnnotation.h
//  Outbreak
//
//  Created by Peter on 3/4/16.
//  Copyright © 2016 Peter Kazazes. All rights reserved.
//

@import Mapbox;

@interface OutbreakAnnotation : NSObject <MGLAnnotation>

@property BOOL isDeath;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate;

@end
