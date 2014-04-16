//
//  BeaconClient.h
//  iBeacon
//
//  Created by Clark Perkins on 4/16/14.
//  Copyright (c) 2014 Vanderbilt University. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface BeaconClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (NSURLSessionDataTask *)postBeaconData:(NSDictionary *)beaconData floorPlanId:(NSString *)floorPlanId;

@end
