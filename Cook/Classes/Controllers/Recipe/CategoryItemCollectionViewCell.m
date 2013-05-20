//
//  CategoryItemCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryItemCollectionViewCell.h"
#import "CKCategory.h"
#import "CKBook.h"
#import "NSString+Utilities.h"

@interface CategoryItemCollectionViewCell ()

@property (nonatomic, strong) CKCategory *category;

@end


@implementation CategoryItemCollectionViewCell

- (void)configureValue:(id)value {
    CKCategory *category = (CKCategory *)value;
    self.category = category;
    [super configureValue:value];
}

- (NSString *)textForValue:(id)value {
    return ((CKCategory *)value).name;
}

- (id)currentValue {
    NSString *categoryName = [self.textField.text CK_whitespaceTrimmed];
    CKCategory *category = nil;
    
    if ([self.category persisted]) {
        category = self.category;
        category.name = categoryName;
    } else {
        category = [CKCategory categoryForName:self.textField.text book:self.book];
    }
    
    return category;
}

@end
