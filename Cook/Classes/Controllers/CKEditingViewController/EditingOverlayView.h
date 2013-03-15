//
//  EditingOverlayView.h
//  Cook
//
//  Created by Jonny Sagorin on 3/15/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EditingOverlayViewDelegate
-(void) editOverlayViewDidRequestDone;
@end

@interface EditingOverlayView : UIView

- (id)initWithFrame:(CGRect)frame withTransparentOverlay:(CGRect)transparentOverlayRect withEditViewDelegate:(id<EditingOverlayViewDelegate>)editingOverlayViewDelegate;
- (void)viewAppeared;
@end
