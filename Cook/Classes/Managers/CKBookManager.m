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

@interface CKBookManager () {
    NSArray *_tagArray;
}

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

#pragma mark - Properties

- (void)setTagArray:(NSArray *)tagArray {
    //Set tag array here
//    if (!error)
//    {
//        NSMutableArray *tagObjects = [NSMutableArray new];
//        for (PFObject *parseTagObject in objects) {
//            CKRecipeTag *recipeTag = [[CKRecipeTag alloc] initWithParseObject:parseTagObject];
//            [tagObjects addObject:recipeTag];
//        }
//        _tagArray = tagObjects;
//    }
}

- (NSArray *)tagArray {
    return _tagArray;
}

@end
