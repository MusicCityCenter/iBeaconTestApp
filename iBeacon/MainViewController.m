//
//  MainViewController.m
//  iBeacon
//
//  Created by Clark Perkins on 4/16/14.
//  Copyright (c) 2014 Vanderbilt University. All rights reserved.
//

#import "MainViewController.h"
#import "TrackViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UITextField *floorPlanId;

@property (weak, nonatomic) IBOutlet UITextField *locationId;


@end

@implementation MainViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TrackViewController *destinationController = segue.destinationViewController;
    destinationController.floorPlanId = self.floorPlanId.text;
    destinationController.locationId = self.locationId.text;
}

@end
