//
//  CKRecipeSocialView.h
//  CKRecipeSocialViewDemo
//
//  Created by Jeff Tan-Ang on 10/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKRecipeSocialViewDelegate

- (void)recipeSocialViewTapped;

@end

@interface CKRecipeSocialView : UIView

- (id)initWithNumComments:(NSInteger)numComments numLikes:(NSInteger)numLikes
                 delegate:(id<CKRecipeSocialViewDelegate>)delegate;

@end
