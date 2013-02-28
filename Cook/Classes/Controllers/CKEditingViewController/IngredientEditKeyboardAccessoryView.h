//
//  IngredientEditKeyboardAccessoryView.h
//  Cook
//
//  Created by Jonny Sagorin on 2/15/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IngredientEditKeyboardAccessoryViewDelegate
-(void)didEnterMeasurementShortCut:(NSString*)name;
@end

@interface IngredientEditKeyboardAccessoryView : UIView
- (id)initWithFrame:(CGRect)frame delegate:(id<IngredientEditKeyboardAccessoryViewDelegate>)delegate;
@end
