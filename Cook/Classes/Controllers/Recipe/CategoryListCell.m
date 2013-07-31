//
//  CategoryListCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 31/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryListCell.h"
#import "CKCategory.h"
#import "NSString+Utilities.h"

@interface CategoryListCell ()

@property (nonatomic, strong) CKCategory *category;

@end

@implementation CategoryListCell

- (void)configureValue:(id)value {
    CKCategory *category = (CKCategory *)value;
    self.category = category;
    [super configureValue:value];
}

- (NSString *)textValueForValue:(id)value {
    NSString *textValue = nil;
    if ([value isKindOfClass:[CKCategory class]]) {
        textValue = ((CKCategory *)value).name;
    } else {
        textValue = [super textValueForValue:value];
    }
    return [textValue uppercaseString];
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
