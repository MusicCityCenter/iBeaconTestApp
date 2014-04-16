//
//  BeaconClient.m
//  iBeacon
//
//  Created by Clark Perkins on 4/16/14.
//  Copyright (c) 2014 Vanderbilt University. All rights reserved.
//

#import "BeaconClient.h"

@implementation BeaconClient

+ (instancetype)sharedClient {
    static BeaconClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:@"http://0-1-dot-mcc-backend.appspot.com/mcc"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        
        config.URLCache = cache;
        
        _sharedClient = [[BeaconClient alloc] initWithBaseURL:baseURL
                                      sessionConfiguration:config];
//        _sharedClient.responseSerializer = [MCCResponseSerializer serializer];
    });
    
    return _sharedClient;
}


- (NSURLSessionDataTask *)postBeaconData:(NSDictionary *)beaconData floorPlanId:(NSString *)floorPlanId {
    NSString *targetUrl = [NSString stringWithFormat:@"/beacons/%@", floorPlanId];
    NSURLSessionDataTask *dataTask = [self POST:targetUrl
                                     parameters:beaconData
                                        success:^(NSURLSessionDataTask *task, id responseObject) {
                                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                            NSLog(@"Received HTTP %li", (long) httpResponse.statusCode);
                                            if (httpResponse.statusCode == 200){
                                                NSLog(@"Sent data");
                                            }
                                        }
                                        failure:^(NSURLSessionDataTask *task, NSError *error) {
                                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                                            NSLog(@"Received HTTP %li", (long) httpResponse.statusCode);
                                            [[[UIAlertView alloc] initWithTitle:@"Error Sending Beacon Data"
                                                                        message:[NSString stringWithFormat:@"HTTP %li",(long) httpResponse.statusCode]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil] show];
                                        }];
    
    return dataTask;
}

@end
