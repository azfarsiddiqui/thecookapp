//
//  CKBookManager.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookManager.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "AppHelper.h"
#import <Parse/Parse.h>
#import "CKRecipeTag.h"

@interface CKBookManager () 

@property (nonatomic, strong) CKBook *myBook;

@end

@implementation CKBookManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static CKBookManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKBookManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - Hang on to my book.

- (CKBook *)myCurrentBook {
    return self.myBook;
}

- (void)holdMyCurrentBook:(CKBook *)book {
    self.myBook = book;
}

@end
