//
//  TagListCell.m
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "TagListCell.h"
#import "CKEditingTextBoxView.h"
#import "CKRecipeTag.h"
#import "CKActivityIndicatorView.h"

@interface TagListCell()

@property (nonatomic, strong) CKActivityIndicatorView *activityIndicator;

@end

@implementation TagListCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.activityIndicator = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleTinyDarkBlue];
        self.activityIndicator.center = self.boxImageView.center;
        [self addSubview:self.activityIndicator];
        self.activityIndicator.hidesWhenStopped = YES;
    }
    return self;
}

- (NSString *)textValueForValue:(id)value {
    if ([value isKindOfClass:[NSString class]])
        return value;
    CKRecipeTag *recipeTag = (CKRecipeTag *)value;
    return [[super textValueForValue:recipeTag.displayName] uppercaseString];
}

//Heh, swizzling to set look of selected state
- (UIImage *)imageForSelected:(BOOL)selected {
    return selected ? [CKEditingTextBoxView textEditingSelectionBoxWhite:YES] : [CKEditingTextBoxView textEditingBoxWhite:YES];
}

- (id)currentValue {
    return self.recipeTag;
}

- (void)configureValue:(id)value selected:(BOOL)selected {
    [super configureValue:value selected:selected];
    if (value)
    {
        [self.activityIndicator stopAnimating];
        self.recipeTag = (CKRecipeTag *)value;
    }
    else
        [self.activityIndicator startAnimating];
}

@end
