//
//  OutbreakAnnotation.m
//  Ebola
//
//  Created by Peter on 3/4/16.
//  Copyright © 2016 Peter Kazazes. All rights reserved.
//

#import "OutbreakAnnotation.h"


@implementation OutbreakAnnotation

- (id) init {
    self = [super init];
    if (self) {
        self.isDeath = false;
    }
    
    return self;
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate {
    self.coordinate = coordinate;
}

@end
