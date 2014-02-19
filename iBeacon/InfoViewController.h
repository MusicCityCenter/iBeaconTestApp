//
//  InfoViewController.h
//  iBeacon
//
//  Created by Clark Perkins on 2/17/14.
//  Copyright (c) 2014 Vanderbilt University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface InfoViewController : UIViewController

@property (strong, nonatomic) CLBeacon *beacon;

@end
