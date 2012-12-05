//
//  UIEditableView.h
//  Cook
//
//  Created by Jonny Sagorin on 11/30/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

//An editable view has two modes
// - readOnly (default)
// - editable

@interface UIEditableView : UIView
//change the view to allow for editing. this might be new sub-views are displayed, or existing sub-views are enabled
-(void) makeEditable:(BOOL)editable;
-(BOOL) inEditMode;
@end
