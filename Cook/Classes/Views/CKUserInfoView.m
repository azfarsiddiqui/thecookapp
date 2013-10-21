//
//  CKUserInfoView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKUserInfoView.h"
#import "CKUser.h"
#import "NSString+Utilities.h"

@interface CKUserInfoView ()

@property (nonatomic, strong) CKUser *user;

@end

@implementation CKUserInfoView

- (id)initWithUser:(CKUser *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (void)loadData {
    [self.user userInfoCompletion:^(NSUInteger friendCount, NSUInteger followCount, NSUInteger recipeCount, BOOL areFriends){
        DLog(@"Loaded userInfo friendCount[%d] followCount[%d] recipeCount[%d] areFriends[%@]", friendCount,
             followCount, recipeCount, [NSString CK_stringForBoolean:areFriends]);
    } failure:^(NSError *error) {
        DLog(@"Error loading userInfo: %@", [error localizedDescription]);
    }];
}

@end
