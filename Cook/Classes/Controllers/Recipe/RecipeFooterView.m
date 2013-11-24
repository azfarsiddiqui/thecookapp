//
//  RecipeFooterView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeFooterView.h"
#import "RecipeDetails.h"
#import "CKLocation.h"
#import "CKUser.h"
#import "UIColor+Expanded.h"
#import "DateHelper.h"

@interface RecipeFooterView ()

@property (nonatomic, strong) NSMutableArray *elementViews;
@property (nonatomic, strong) CKUser *currentUser;

@end

@implementation RecipeFooterView

#define kElementsGap    100.0
#define kIconLabelGap   8.0
#define kLabelFont      [UIFont fontWithName:@"BrandonGrotesque-Regular" size:16.0]
#define kLabelColour    [UIColor colorWithHexString:@"A0A0A0"]
#define kContentInsets  (UIEdgeInsets){ 0.0, 25.0, 0.0, 0.0 }

- (id)init {
    if (self = [super initWithFrame:CGRectZero]) {
        self.currentUser = [CKUser currentUser];
        self.elementViews = [NSMutableArray array];
    }
    return self;
}

- (void)updateFooterWithRecipeDetails:(RecipeDetails *)recipeDetails {
    [self.elementViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.elementViews removeAllObjects];
    
    CGFloat xOffset = kContentInsets.left;
    
    // Visibility.
    UIView *visibilityView = [self elementViewWithIcon:[self imageForPrivacy:recipeDetails.privacy]
                                                  text:[self textForPrivacy:recipeDetails.privacy]];
    visibilityView.frame = (CGRect){
        xOffset,
        0.0,
        visibilityView.frame.size.width,
        visibilityView.frame.size.height
    };
    xOffset += visibilityView.frame.size.width + kElementsGap;
    [self.elementViews addObject:visibilityView];
    
    // Creation date.
    UIView *dateView = [self elementViewWithIcon:[UIImage imageNamed:@"cook_book_recipe_footer_icon_edit.png"]
                                            text:[[[DateHelper sharedInstance] relativeDateTimeDisplayForDate:recipeDetails.createdDateTime] uppercaseString]];
    dateView.frame = (CGRect){
        xOffset,
        0.0,
        dateView.frame.size.width,
        dateView.frame.size.height
    };
    xOffset += dateView.frame.size.width + kElementsGap;
    [self.elementViews addObject:dateView];
    
    // Location if any.
    if (recipeDetails.location) {
        
        UIView *locationView = [self elementViewWithIcon:[UIImage imageNamed:@"cook_book_recipe_footer_icon_public.png"]
                                                    text:[[recipeDetails.location displayName] uppercaseString]];
        locationView.frame = (CGRect){
            xOffset,
            0.0,
            locationView.frame.size.width,
            locationView.frame.size.height
        };
        xOffset += locationView.frame.size.width + kElementsGap;
        [self.elementViews addObject:locationView];
    }
    
    // Combine and add to view.
    __block CGRect combinedFrame = CGRectZero;
    [self.elementViews enumerateObjectsUsingBlock:^(UIView *elementView, NSUInteger elementIndex, BOOL *stop) {
        combinedFrame = CGRectUnion(combinedFrame, elementView.frame);
        combinedFrame.size.width += kContentInsets.right;
        combinedFrame.size.height += kContentInsets.bottom;
        self.frame = combinedFrame;
        [self addSubview:elementView];
    }];
    
}

#pragma mark - Private methods

- (UIView *)elementViewWithIcon:(UIImage *)icon text:(NSString *)text {
    
    // Left icon.
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    CGRect combinedFrame = iconView.frame;
    
    // Right label.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kLabelFont;
    label.textColor = kLabelColour;
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = (CGSize){ 0.0, 1.0 };
    label.text = text;
    [label sizeToFit];
    label.frame = (CGRect){
        iconView.frame.origin.x + iconView.frame.size.width + kIconLabelGap,
        floorf((combinedFrame.size.height - label.frame.size.height) / 2.0),
        label.frame.size.width,
        label.frame.size.height
    };
    
    // Combine their frames.
    combinedFrame = CGRectUnion(combinedFrame, label.frame);
    
    // Container frame.
    UIView *containerView = [[UIView alloc] initWithFrame:combinedFrame];
    containerView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:iconView];
    [containerView addSubview:label];
    return containerView;
}

- (UIImage *)imageForPrivacy:(CKPrivacy)privacy {
    UIImage *image = nil;
    switch (privacy) {
        case CKPrivacyPrivate:
            image = [UIImage imageNamed:@"cook_book_recipe_footer_icon_secret.png"];
            break;
        case CKPrivacyFriends:
            image = [UIImage imageNamed:@"cook_book_recipe_footer_icon_friends.png"];
            break;
        case CKPrivacyPublic:
            image = [UIImage imageNamed:@"cook_book_recipe_footer_icon_public.png"];
            break;
        default:
            break;
    }
    return image;
}

- (NSString *)textForPrivacy:(CKPrivacy)privacy {
    NSString *info = nil;
    switch (privacy) {
        case CKPrivacyPrivate:
            info = @"SECRET";
            break;
        case CKPrivacyFriends:
            info = @"FRIENDS";
            break;
        case CKPrivacyPublic:
            info = @"PUBLIC";
            break;
        default:
            break;
    }
    return info;
}


@end
