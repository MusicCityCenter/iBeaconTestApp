//
//  InfoViewController.m
//  iBeacon
//
//  Created by Clark Perkins on 2/17/14.
//  Copyright (c) 2014 Vanderbilt University. All rights reserved.
//

#import "InfoViewController.h"


@interface InfoViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UILabel *UUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end

@implementation InfoViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.beacon.proximityUUID
                                                                major:[self.beacon.major intValue]
                                                                minor:[self.beacon.minor intValue]
                                                           identifier:@"com.nashvillemusiccitycenter"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self locationManager:self.locationManager didEnterRegion:self.beaconRegion];
    
}

# pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    [self updateUI:[beacons firstObject]];
}

- (void)updateUI:(CLBeacon *)beacon {
    self.UUIDLabel.text = beacon.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
    self.rssiLabel.text = [NSString stringWithFormat:@"%li", (long) beacon.rssi];
    
//    NSString *dist = [NSString stringWithFormat:@"%f", beacon.rssi / -59.0];
    
    switch (beacon.proximity) {
        case CLProximityUnknown:
            self.distanceLabel.text = @"Unknown Proximity";
            break;
            
        case CLProximityImmediate:
            self.distanceLabel.text = @"Immediate";
            break;
            
        case CLProximityNear:
            self.distanceLabel.text = @"Near";
            break;
            
        case CLProximityFar:
            self.distanceLabel.text = @"Far";
            break;
            
        default:
            self.distanceLabel.text = @"error";
            break;
    }
    
//    self.distanceLabel.text = [NSString stringWithFormat:@"%@ m (%@)", dist, self.distanceLabel.text];
}

@end
