//
//  StatsView.h
//  Outbreak
//
//  Created by Peter on 11/5/14.
//  Copyright (c) 2014 Peter Kazazes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface StatsView : UIView <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *casesLabel;
@property (strong, nonatomic) IBOutlet UILabel *deathsLabel;
@property (strong, nonatomic) IBOutlet UILabel *mortalityLabel;
@property (strong, nonatomic) IBOutlet UIButton *distanceButton;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *lineGraph;
@property (strong, nonatomic) IBOutlet UITableView *tweetTableView;
@property (strong, nonatomic) IBOutlet UIButton *loginForTwitter;

- (void)refreshStats;
- (void)reloadGraph;
- (void)statsShouldRefresh:(NSNotification *)notification;

@end
