//
//  IngredientsKeyboardAccessoryViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IngredientsKeyboardAccessoryViewControllerDelegate <NSObject>

- (void)ingredientsKeyboardAccessorySelectedValue:(NSString *)value;

@end

@interface IngredientsKeyboardAccessoryViewController : UICollectionViewController

@property (nonatomic, weak) id<IngredientsKeyboardAccessoryViewControllerDelegate> delegate;

- (NSArray *)allUnitOfMeasureOptions;

@end
