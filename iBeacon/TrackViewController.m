//
//  TrackViewController.m
//  iBeacon
//
//  Created by Clark Perkins on 1/27/14.
//  Copyright (c) 2014 Vanderbilt University. All rights reserved.
//

#import "TrackViewController.h"
#import "InfoViewController.h"

@interface TrackViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSArray *beacons;

@property (strong, nonatomic) NSURLConnection *conn;
@property (strong, nonatomic) NSMutableData *receivedData;

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

# pragma mark - Button clicks

- (IBAction)sendDataToServer:(UIBarButtonItem *)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://sinfoniaattendance.herokuapp.com/api/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    NSMutableArray *beaconData = [NSMutableArray array];
    for (CLBeacon *beacon in self.beacons) {
        NSMutableDictionary *thisBeacon = [NSMutableDictionary dictionary];
        thisBeacon[@"uuid"] = beacon.proximityUUID.UUIDString;
        thisBeacon[@"major"] = beacon.major;
        thisBeacon[@"minor"] = beacon.minor;
        thisBeacon[@"rssi"] = [NSNumber numberWithInt:beacon.rssi];
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
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:beaconData options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *afterString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",afterString);
    
    
    [request setValue:[NSString stringWithFormat:@"%lu", postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = postData;
    
    self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
    self.receivedData = [NSMutableData dataWithCapacity: 0];
    
    [UIApplication sharedApplication].NetworkActivityIndicatorVisible = YES;
    [self.conn start];
}

# pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse object.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Release the connection and the data object
    // by setting the properties (declared elsewhere)
    // to nil.  Note that a real-world app usually
    // requires the delegate to manage more than one
    // connection at a time, so these lines would
    // typically be replaced by code to iterate through
    // whatever data structures you are using.
    self.conn = nil;
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a property elsewhere
    NSLog(@"Succeeded! Received %lu bytes of data", [self.receivedData length]);
    
    
    NSString *afterString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    
    [UIApplication sharedApplication].NetworkActivityIndicatorVisible = NO;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server says:" message:afterString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    
//    NSDictionary* user = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingMutableContainers error:nil];
    
    
    // Release the connection and the data object
    // by setting the properties (declared elsewhere)
    // to nil.  Note that a real-world app usually
    // requires the delegate to manage more than one
    // connection at a time, so these lines would
    // typically be replaced by code to iterate through
    // whatever data structures you are using.
    self.conn = nil;
    self.receivedData = nil;
}

@end
