//
//  CKBookInfoView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 21/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookInfoView.h"
#import "CKBook.h"
#import "NSString+Utilities.h"

@interface CKBookInfoView ()

@property (nonatomic, strong) CKBook *book;

@end

@implementation CKBookInfoView

- (id)initWithBook:(CKBook *)book {
    if (self = [super init]) {
        self.book = book;
    }
    return self;
}

- (void)loadData {
}

@end
