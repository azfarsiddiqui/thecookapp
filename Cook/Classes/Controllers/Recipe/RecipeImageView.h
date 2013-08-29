//
//  RecipeImageView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 29/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecipeImageViewDelegate <NSObject>

- (void)recipeImageViewTapped;
- (void)recipeImageViewDoubleTappedAtPoint:(CGPoint)point;

@end

@interface RecipeImageView : UIImageView

@property (nonatomic, weak) id<RecipeImageViewDelegate> delegate;
@property (nonatomic, assign) BOOL enableDoubleTap;

@end
