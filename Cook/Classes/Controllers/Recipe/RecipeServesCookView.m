//
//  RecipeServesCookView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeServesCookView.h"
#import "RecipeDetails.h"
#import "Theme.h"

@interface RecipeServesCookView ()

@property (nonatomic, strong) RecipeDetails *recipeDetails;
@property (nonatomic, assign) CGFloat layoutOffset;

@end

@implementation RecipeServesCookView

#define kWidth                  200.0
#define kIconStatGap            15.0
#define kValueTextGap           -5.0
#define kStatViewOffset         -4.0
#define kStatRowGap             -5.0
#define kContentInsets          (UIEdgeInsets){ 0.0, 0.0, -11.0, 12.0 }

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails {
    if (self = [super initWithFrame:CGRectZero]) {
        self.recipeDetails = recipeDetails;
        self.backgroundColor = [UIColor clearColor];
        [self update];
    }
    return self;
}

- (void)update {
    self.layoutOffset = 0.0;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self updateServes];
    [self updatePrepCook];
    [self updateFrame];
}

#pragma mark - Private methods

- (void)updateServes {
    UIImageView *servesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_icon_serves.png"]];
    UIView *servesStatView = [self viewForStatText:@"Serves" statValue:[NSString stringWithFormat:@"%d", self.recipeDetails.numServes]];
    CGRect servesFrame = servesStatView.frame;
    CGRect imageFrame = servesImageView.frame;
    servesFrame.origin.x = servesImageView.frame.origin.x + servesImageView.frame.size.width + kIconStatGap;
    servesStatView.frame = servesFrame;
    
    CGRect combinedFrame = CGRectUnion(imageFrame, servesFrame);
    UIView *containerView = [[UIView alloc] initWithFrame:combinedFrame];
    containerView.backgroundColor = [UIColor clearColor];
    imageFrame.origin.y = floorf((combinedFrame.size.height - imageFrame.size.height) / 2.0);
    servesImageView.frame = imageFrame;
    servesFrame.origin.y = floorf((combinedFrame.size.height - servesFrame.size.height) / 2.0) + kStatViewOffset;
    servesStatView.frame = servesFrame;
    
    [containerView addSubview:servesImageView];
    [containerView addSubview:servesStatView];
    [self addSubview:containerView];
    
    self.layoutOffset += containerView.frame.size.height;
}

- (void)updatePrepCook {
    CGFloat prepCookGap = 20.0;
    
    UIImageView *prepCookImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_icon_time.png"]];
    CGRect imageFrame = prepCookImageView.frame;
    
    UIView *prepStatView = [self viewForStatText:@"Prep" statValue:[NSString stringWithFormat:@"%d", self.recipeDetails.prepTimeInMinutes]];
    CGRect prepFrame = prepStatView.frame;
    prepFrame.origin.x = prepCookImageView.frame.origin.x + prepCookImageView.frame.size.width + kIconStatGap;
    prepStatView.frame = prepFrame;
    
    UIView *cookStatView = [self viewForStatText:@"Cook" statValue:[NSString stringWithFormat:@"%d", self.recipeDetails.cookingTimeInMinutes]];
    CGRect cookFrame = cookStatView.frame;
    cookFrame.origin.x = prepFrame.origin.x + prepFrame.size.width + prepCookGap;
    cookStatView.frame = cookFrame;
    
    CGRect combinedFrame = CGRectUnion(prepCookImageView.frame, prepFrame);
    combinedFrame = CGRectUnion(combinedFrame, cookFrame);
    
    UIView *containerView = [[UIView alloc] initWithFrame:combinedFrame];
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = kStatRowGap + self.layoutOffset;
    containerView.frame = containerFrame;
    containerView.backgroundColor = [UIColor clearColor];
    
    imageFrame.origin.y = floorf((combinedFrame.size.height - imageFrame.size.height) / 2.0);
    prepCookImageView.frame = imageFrame;
    prepFrame.origin.y = floorf((combinedFrame.size.height - prepFrame.size.height) / 2.0) + kStatViewOffset;
    prepStatView.frame = prepFrame;
    cookFrame.origin.y = floorf((combinedFrame.size.height - cookFrame.size.height) / 2.0) + kStatViewOffset;
    cookStatView.frame = cookFrame;
    prepCookImageView.frame = imageFrame;
    prepStatView.frame = prepFrame;
    cookStatView.frame = cookFrame;
    [containerView addSubview:prepCookImageView];
    [containerView addSubview:prepStatView];
    [containerView addSubview:cookStatView];
    [self addSubview:containerView];
    
    self.layoutOffset += kStatRowGap + containerView.frame.size.height;
}

- (void)updateFrame {
    CGRect frame = (CGRect){ 0.0, 0.0, 0.0, 0.0 };;
    for (UIView *subview in self.subviews) {
        frame = (CGRectUnion(frame, subview.frame));
    }
    frame.size.width += kContentInsets.right;
    frame.size.height += kContentInsets.bottom;
    self.frame = frame;
}

- (UIView *)viewForStatText:(NSString *)statText statValue:(NSString *)statValue {
    CGFloat textValueGap = kValueTextGap;
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabel.backgroundColor = [UIColor clearColor];
    valueLabel.font = [Theme recipeStatValueFont];
    valueLabel.textColor = [Theme recipeStatValueColour];
    valueLabel.text = [statValue uppercaseString];
    [valueLabel sizeToFit];
    CGRect valueFrame = valueLabel.frame;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [Theme recipeStatTextFont];
    textLabel.textColor = [Theme recipeStatTextColour];
    textLabel.text = [statText uppercaseString];
    [textLabel sizeToFit];
    CGRect textFrame = textLabel.frame;
    textFrame.origin.y = valueLabel.frame.origin.y + textValueGap;
    
    // Combine and reposition them.
    CGRect combinedFrame = CGRectUnion(valueFrame, textFrame);
    UIView *containerView = [[UIView alloc] initWithFrame:combinedFrame];
    containerView.backgroundColor = [UIColor clearColor];
    valueFrame.origin.x = floorf((combinedFrame.size.width - valueFrame.size.width) / 2.0);
    valueLabel.frame = valueFrame;
    textFrame.origin.x = floorf((combinedFrame.size.width - textFrame.size.width) / 2.0);
    textFrame.origin.y = valueFrame.origin.y + valueFrame.size.height + textValueGap;
    textLabel.frame = textFrame;
    [containerView addSubview:valueLabel];
    [containerView addSubview:textLabel];
    
    return containerView;
}

@end
