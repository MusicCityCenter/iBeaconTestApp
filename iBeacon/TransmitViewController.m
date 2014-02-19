//
//  TransmitViewController.m
//  iBeacon
//
//  Created by Clark Perkins on 1/27/14.
//  Copyright (c) 2014 Vanderbilt University. All rights reserved.
//

#import "TransmitViewController.h"

@interface TransmitViewController () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *identityLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIButton *transmitButton;

@property (nonatomic) BOOL started;

@end

@implementation TransmitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLabels];
    self.started = NO;
}

- (CLBeaconRegion *)beaconRegion {
    if (_beaconRegion == nil) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"8DEEFBB9-F738-4297-8040-96668BB44281"];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:1
                                                                minor:1
                                                            identifier:@"com.nashvillemusiccitycenter"];
    }
    return _beaconRegion;
}

- (IBAction)transmitBeacon:(UIButton *)sender {
    if (!self.started) {
        self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
        self.started = YES;
        self.transmitButton.enabled = NO;
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        self.statusLabel.text = @"Bluetooth On";
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        self.statusLabel.text = @"Bluetooth Off";
        [self.peripheralManager stopAdvertising];
    } else if (peripheral.state == CBPeripheralManagerStateResetting) {
        NSLog(@"Resetting");
        self.statusLabel.text = @"Bluetooth Resetting";
    } else if (peripheral.state == CBPeripheralManagerStateUnauthorized) {
        NSLog(@"Unauthorized");
        self.statusLabel.text = @"Bluetooth Unauthorized";
    } else if (peripheral.state == CBPeripheralManagerStateUnknown) {
        NSLog(@"Unknown");
        self.statusLabel.text = @"Bluetooth Status Unknown";
    } else if (peripheral.state == CBPeripheralManagerStateUnsupported) {
        NSLog(@"Unsupported");
        self.statusLabel.text = @"Bluetooth LE Unsupported";
    }
}

- (void)setLabels {
    self.uuidLabel.text = self.beaconRegion.proximityUUID.UUIDString;
    self.majorLabel.text = [NSString stringWithFormat:@"%@", self.beaconRegion.major];
    self.minorLabel.text = [NSString stringWithFormat:@"%@", self.beaconRegion.minor];
    self.identityLabel.text = self.beaconRegion.identifier;
}

@end
