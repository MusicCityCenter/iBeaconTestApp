//
//  TrackViewController.m
//  iBeacon
//
//  Created by Clark Perkins on 1/27/14.
//  Copyright (c) 2014 Vanderbilt University. All rights reserved.
//

#import "TrackViewController.h"
#import "InfoViewController.h"
#import "BeaconClient.h"
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@interface TrackViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSArray *beacons;

@end


@implementation TrackViewController


# pragma mark - Custom Getters

- (CLBeaconRegion *)beaconRegion {
    if (!_beaconRegion) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"8DEEFBB9-F738-4297-8040-96668BB44281"];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                           identifier:@"com.nashvillemusiccitycenter"];
    }
    return _beaconRegion;
}

# pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self locationManager:self.locationManager didEnterRegion:self.beaconRegion];
    
//    CLBeacon *test = [[CLBeacon alloc] init];
//    [test setValue:@1 forKey:@"major"];
//    [test setValue:@184 forKey:@"minor"];
//    [test setValue:[[NSUUID alloc] initWithUUIDString:@"8DEEFBB9-F738-4297-8040-96668BB44281"] forKey:@"proximityUUID"];
//    self.beacons = [NSMutableArray array];
//    [self.beacons addObject:test];
//    test = [[CLBeacon alloc] init];
//    [test setValue:@1 forKey:@"major"];
//    [test setValue:@187 forKey:@"minor"];
//    [test setValue:[[NSUUID alloc] initWithUUIDString:@"8DEEFBB9-F738-4297-8040-96668BB44281"] forKey:@"proximityUUID"];
//    [self.beacons addObject:test];
}

# pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.beacons count] == 0) {
        return 1;
    } else {
        return [self.beacons count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cell_type;
    if ([self.beacons count] == 0) {
        cell_type = @"Empty";
    } else {
        cell_type = @"Cell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_type forIndexPath:indexPath];
    
    if ([self.beacons count] == 0) {
        cell.textLabel.text = @"No iBeacons found";
    } else {
        CLBeacon *beacon = self.beacons[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"Major: %@", beacon.major];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Minor: %@", beacon.minor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

# pragma mark - UITableViewDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender {
    InfoViewController *destCont = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    destCont.beacon = self.beacons[indexPath.row];
}

# pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    self.beacons = beacons;
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    
    NSMutableDictionary *beaconsAtLocation = [NSMutableDictionary dictionary];
    
    beaconsAtLocation[@"floorplanId"] = self.floorPlanId;
    beaconsAtLocation[@"locationId"] = self.locationId;
    beaconsAtLocation[@"beaconIds"] = [NSMutableArray array];
    
    for (CLBeacon *beacon in self.beacons) {
        NSMutableDictionary *thisBeacon = [NSMutableDictionary dictionary];
        thisBeacon[@"beaconId"] = [NSString stringWithFormat:@"%@-%li-%li", beacon.proximityUUID, (long) beacon.major, (long) beacon.minor];
        thisBeacon[@"distance"] = [NSString stringWithFormat:@"%li", beacon.rssi];
        [beaconsAtLocation[@"beaconIds"] addObject:thisBeacon];
    }
    
    NSMutableArray *beaconData = [NSMutableArray array];
    [beaconData addObject:beaconsAtLocation];
    
    /*NSMutableArray *beaconData = [NSMutableArray array];
    for (CLBeacon *beacon in self.beacons) {
        NSMutableDictionary *thisBeacon = [NSMutableDictionary dictionary];
        thisBeacon[@"uuid"] = beacon.proximityUUID.UUIDString;
        thisBeacon[@"major"] = beacon.major;
        thisBeacon[@"minor"] = beacon.minor;
        thisBeacon[@"rssi"] = [NSNumber numberWithLong:beacon.rssi];
        thisBeacon[@"accuracy"] = [NSNumber numberWithDouble:beacon.accuracy];
        if (beacon.proximity == CLProximityUnknown) {
            thisBeacon[@"distance"] = @"Unknown Proximity";
        } else if (beacon.proximity == CLProximityImmediate) {
            thisBeacon[@"distance"] = @"Immediate";
        } else if (beacon.proximity == CLProximityNear) {
            thisBeacon[@"distance"] = @"Near";
        } else if (beacon.proximity == CLProximityFar) {
            thisBeacon[@"distance"] = @"Far";
        }
        [beaconData addObject:thisBeacon];
    }
    
    NSMutableDictionary *locationData = [NSMutableDictionary dictionary];
    locationData[@"beaconData"] = beaconData;
    
    CLLocation *curLocation = [locations lastObject];
    
    NSMutableDictionary *curLocData = [NSMutableDictionary dictionary];
    curLocData[@"latitude"] = [NSNumber numberWithDouble:curLocation.coordinate.latitude];
    curLocData[@"longitude"] = [NSNumber numberWithDouble:curLocation.coordinate.longitude];
    curLocData[@"altitude"] = [NSNumber numberWithDouble:curLocation.altitude];
    curLocData[@"horizontalAccuracy"] = [NSNumber numberWithDouble:curLocation.horizontalAccuracy];
    curLocData[@"verticalAccuracy"] = [NSNumber numberWithDouble:curLocation.verticalAccuracy];
    
    locationData[@"gpsData"] = curLocData;
    
    locationData[@"wifiData"] = [NSMutableDictionary dictionary];
    
    CFArrayRef interfaces = CNCopySupportedInterfaces();
    
    if (interfaces) {
        NSDictionary *netInfo = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(interfaces, 0));
        locationData[@"wifiData"][@"ssid"] = netInfo[@"SSID"];
        locationData[@"wifiData"][@"bssid"] = netInfo[@"BSSID"];
    }*/
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:beaconData options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *afterString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", afterString);
    
    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    postDict[@"beaconsMapping"] = afterString;
    postDict[@"floorplanId"] = self.floorPlanId;
    
    [[BeaconClient sharedClient] postBeaconData:postDict floorPlanId:self.floorPlanId];
}

# pragma mark - Button clicks

- (IBAction)sendDataToServer:(UIBarButtonItem *)sender {
    // Get the current location, then wait for the callback to send data to the server
    [self.locationManager startUpdatingLocation];
}

@end
