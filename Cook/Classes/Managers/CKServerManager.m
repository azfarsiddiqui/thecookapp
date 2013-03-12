//
//  CKServerManager.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKServerManager.h"
#import <Parse/Parse.h>

@interface CKServerManager ()

@end

@implementation CKServerManager

+ (CKServerManager *)sharedInstance {
    static dispatch_once_t pred;
    static CKServerManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKServerManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)start {
    
    // Set up Parse
    [Parse setApplicationId:@"36DsRqQPcsSgInjBmAiUYDHFtxkFqlxHnoli69VS"
                  clientKey:@"c4J2TvKqYVh7m7pfZRasve4HuySArVSDxpAOXmMN"];
    
    // Automatic creation of anonymous user.
    [PFUser enableAutomaticUser];
    
    // Set up Facebook
    [PFFacebookUtils initializeFacebook];
    
    DLog(@"Started ServerManager");
}

- (void)stop {
    DLog(@"Stopped ServerManager");
}

- (BOOL)handleFacebookCallback:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

@end
