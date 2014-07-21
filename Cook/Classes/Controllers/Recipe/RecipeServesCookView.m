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
#import "NSString+Utilities.h"
#import "DateHelper.h"
#import "CKMeasureConverter.h"

@interface RecipeServesCookView ()

@property (nonatomic, strong) RecipeDetails *recipeDetails;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) CGFloat layoutOffset;
@property (nonatomic, strong) UIView *servesStatView;
@property (nonatomic, strong) UIView *prepStatView;
@property (nonatomic, strong) UIView *cookStatView;

@end

@implementation RecipeServesCookView

#define kWidth                  200.0
#define kIconStatGap            12.0
#define kValueTextGap           -6.0
#define kStatViewOffset         -4.0
#define kStatRowGap             -10.0
#define kLabelTag               300
#define kContentInsets          (UIEdgeInsets){ 0.0, 0.0, -7.0, 12.0 }

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails editMode:(BOOL)editMode {
    if (self = [super initWithFrame:CGRectZero]) {
        self.recipeDetails = recipeDetails;
        self.editMode = editMode;
        self.backgroundColor = [UIColor clearColor];
        [self updateLayout];
    }
    return self;
}

- (void)updateWithRecipeDetails:(RecipeDetails *)recipeDetails editMode:(BOOL)editMode {
    self.recipeDetails = recipeDetails;
    self.editMode = editMode;
    
    // Remove all subviews and relayout.
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.servesStatView = nil;
    self.prepStatView = nil;
    self.cookStatView = nil;
    
    [self updateLayout];
}

#pragma mark - Private methods
    
- (void)updateLayout {
    self.layoutOffset = 0.0;
    [self updateServes];
    [self updatePrepCook];
    [self updateFrame];
}

- (void)updateServes {
    if (self.editMode || self.recipeDetails.numServes) {
        
        NSString *imageString = [NSString stringWithFormat:@"cook_book_recipe_icon_%@%@",
                                 self.recipeDetails.quantityType == CKQuantityMakes ? @"makes" : @"serves",
                                 self.editMode ? @"_edit" : @""];
        UIImageView *servesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageString]];
        
        self.servesStatView = [self viewForStatText:self.recipeDetails.quantityType == CKQuantityMakes ? NSLocalizedString(@"Makes", nil) : NSLocalizedString(@"Serves", nil) statValue:[self servesTextValueForStatNumber:self.recipeDetails.numServes]];
        CGRect servesFrame = self.servesStatView.frame;
        CGRect imageFrame = servesImageView.frame;
        servesFrame.origin.x = servesImageView.frame.origin.x + servesImageView.frame.size.width + kIconStatGap;
        self.servesStatView.frame = servesFrame;
        
        CGRect combinedFrame = CGRectUnion(imageFrame, servesFrame);
        UIView *containerView = [[UIView alloc] initWithFrame:combinedFrame];
        containerView.backgroundColor = [UIColor clearColor];
        imageFrame.origin.y = floorf((combinedFrame.size.height - imageFrame.size.height) / 2.0);
        servesImageView.frame = imageFrame;
        servesFrame.origin.y = floorf((combinedFrame.size.height - servesFrame.size.height) / 2.0) + kStatViewOffset;
        self.servesStatView.frame = servesFrame;
        
        [containerView addSubview:servesImageView];
        [containerView addSubview:self.servesStatView];
        [self addSubview:containerView];
        self.layoutOffset += containerView.frame.size.height;
    }
}

- (void)updatePrepCook {
    CGFloat prepCookGap = 20.0;
    
    CGRect prepFrame = CGRectZero;
    CGRect cookFrame = CGRectZero;
    
    if (self.editMode ||self.recipeDetails.prepTimeInMinutes || self.recipeDetails.cookingTimeInMinutes) {
        
        UIImageView *prepCookImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.editMode ? @"cook_book_recipe_icon_time_edit.png" : @"cook_book_recipe_icon_time"]];
        CGRect imageFrame = prepCookImageView.frame;
        
        if (self.editMode ||self.recipeDetails.prepTimeInMinutes) {
            
            // Prep.
            self.prepStatView = [self viewForStatText:NSLocalizedString(@"Prep", nil) statValue:[self textValueForStatNumber:self.recipeDetails.prepTimeInMinutes formatted:YES ]];
            prepFrame = self.prepStatView.frame;
            prepFrame.origin.x = prepCookImageView.frame.origin.x + prepCookImageView.frame.size.width + kIconStatGap;
            
            // Vertically align with the serves label if it's there.
            if (self.servesStatView) {
                
                CGRect servesFrame = self.servesStatView.frame;
                CGFloat targetOffset = floorf((servesFrame.size.width - prepFrame.size.width) / 2.0);
                if (targetOffset >= 0) {
                    prepFrame.origin.x += floorf((servesFrame.size.width - prepFrame.size.width) / 2.0);
                    self.prepStatView.frame = prepFrame;
                } else {
                    servesFrame.origin.x += floorf((prepFrame.size.width - servesFrame.size.width) / 2.0);
                    self.servesStatView.frame = servesFrame;
                }
                
            }
        }
        
        if (self.editMode || self.recipeDetails.cookingTimeInMinutes) {
            
            // Cook.
            self.cookStatView = [self viewForStatText:NSLocalizedString(@"Cook", nil) statValue:[self textValueForStatNumber:self.recipeDetails.cookingTimeInMinutes formatted:YES]];
            cookFrame = self.cookStatView.frame;
            
            if (!CGRectEqualToRect(prepFrame, CGRectZero)) {
                cookFrame.origin.x = prepFrame.origin.x + prepFrame.size.width + prepCookGap;
            } else {
                
                cookFrame.origin.x = prepCookImageView.frame.origin.x + prepCookImageView.frame.size.width + kIconStatGap;
                
                // Vertically align with the serves label if it's there.
                if (self.servesStatView) {
                    
                    CGRect servesFrame = self.servesStatView.frame;
                    CGFloat targetOffset = floorf((servesFrame.size.width - cookFrame.size.width) / 2.0);
                    if (targetOffset >= 0) {
                        cookFrame.origin.x += floorf((servesFrame.size.width - cookFrame.size.width) / 2.0);
                        self.cookStatView.frame = cookFrame;
                    } else {
                        servesFrame.origin.x += floorf((cookFrame.size.width - servesFrame.size.width) / 2.0);
                        self.servesStatView.frame = servesFrame;
                    }

                }
                
            }
            
        }
        
        // Merge the frame to get our container frame.
        CGRect combinedFrame = CGRectUnion(prepCookImageView.frame, prepFrame);
        combinedFrame = CGRectUnion(combinedFrame, cookFrame);
        UIView *containerView = [[UIView alloc] initWithFrame:combinedFrame];
        CGRect containerFrame = containerView.frame;
        
        if (self.servesStatView) {
            containerFrame.origin.y = kStatRowGap + self.layoutOffset;
        }
        containerView.frame = containerFrame;
        containerView.backgroundColor = [UIColor clearColor];
        
        // Reposition everything within the container.
        imageFrame.origin.y = floorf((combinedFrame.size.height - imageFrame.size.height) / 2.0);
        prepCookImageView.frame = imageFrame;
        
        prepFrame.origin.y = floorf((combinedFrame.size.height - prepFrame.size.height) / 2.0) + kStatViewOffset;
        self.prepStatView.frame = prepFrame;
        cookFrame.origin.y = floorf((combinedFrame.size.height - cookFrame.size.height) / 2.0) + kStatViewOffset;
        self.cookStatView.frame = cookFrame;
        prepCookImageView.frame = imageFrame;
        self.prepStatView.frame = prepFrame;
        self.cookStatView.frame = cookFrame;
        [containerView addSubview:prepCookImageView];
        [containerView addSubview:self.prepStatView];
        [containerView addSubview:self.cookStatView];
        [self addSubview:containerView];
        
        self.layoutOffset += kStatRowGap + containerView.frame.size.height;
    }
}

- (void)updateFrame {
    CGRect frame = (CGRect){ 0.0, 0.0, 0.0, 0.0 };;
    for (UIView *subview in self.subviews) {
        frame = (CGRectUnion(frame, subview.frame));
    }
    frame.size.width += kContentInsets.right;
    frame.size.height += kContentInsets.bottom;
    self.backgroundColor = [UIColor clearColor];
    self.frame = frame;
}

- (UIView *)viewForStatText:(NSString *)statText statValue:(NSString *)statValue {
    CGFloat textValueGap = kValueTextGap;
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabel.backgroundColor = [UIColor clearColor];
    valueLabel.font = [Theme recipeStatValueFont];
    valueLabel.textColor = [Theme recipeStatValueColour];
    valueLabel.text = statValue;
    valueLabel.tag = kLabelTag;
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [valueLabel sizeToFit];
    CGRect valueFrame = valueLabel.frame;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [Theme recipeStatTextFont];
    textLabel.textColor = [Theme recipeStatTextColour];
    textLabel.text = [statText uppercaseString];
    textLabel.textAlignment = NSTextAlignmentCenter;
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

- (NSString *)defaultValue {
    
    // Ugh.
    return @"0000";
}

- (NSString *)servesTextValueForStatNumber:(NSNumber *)statNumber {
    NSString *statValue = [NSString CK_stringOrNilForNumber:statNumber];
    if (!statValue && self.editMode) {
        statValue = @"0";
    } else {
        if (self.recipeDetails.quantityType == CKQuantityServes && [statNumber integerValue] > [RecipeDetails maxServes]) {
            statValue = [NSString stringWithFormat:@"%@+", [@([RecipeDetails maxServes]) stringValue]];
        } else if (self.recipeDetails.quantityType == CKQuantityMakes && [statNumber integerValue] > [RecipeDetails maxMakes]) {
            statValue = [NSString stringWithFormat:@"%@+", [@([RecipeDetails maxMakes]) stringValue]];
        }
    }
    return statValue;
}

- (NSString *)textValueForStatNumber:(NSNumber *)statNumber {
    return [self textValueForStatNumber:statNumber formatted:NO];
}

- (NSString *)textValueForStatNumber:(NSNumber *)statNumber formatted:(BOOL)formatted {
    NSString *statValue = nil;
    
    if (formatted) {
        if (!statNumber && self.editMode) {
            statValue = @"0";
        } else {
            NSInteger minutes = [statNumber integerValue];
            NSString *minutesDisplay = [[DateHelper sharedInstance] formattedShortDurationDisplayForMinutes:minutes];
            if (minutes >= [RecipeDetails maxPrepCookMinutes]) {
                minutesDisplay = [NSString stringWithFormat:@"%@+", minutesDisplay];
            }
            statValue = minutesDisplay;
        }
    } else {
        statValue = [NSString CK_stringOrNilForNumber:statNumber];
        if (!statValue && self.editMode) {
            statValue = @"0";
        }
    }
    
    return statValue;
}



@end
