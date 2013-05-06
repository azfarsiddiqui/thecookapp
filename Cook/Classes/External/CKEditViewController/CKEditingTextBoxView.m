//
//  CKEditingTextBoxView.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingTextBoxView.h"

@interface CKEditingTextBoxView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *editingView;
@property (nonatomic, strong) UIView *textEditBoxImageView;
@property (nonatomic, strong) UIView *textEditingPencilView;
@property (nonatomic, strong) UIButton *textEditingSaveButton;
@property (nonatomic, assign) CGPoint pencilOffsets;

@end

@implementation CKEditingTextBoxView

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    return button;
}

+ (UIImage *)textEditingBoxWhite:(BOOL)white {
    UIImage *textEditingImage = nil;
    if (white) {
        textEditingImage = [[UIImage imageNamed:@"cook_customise_textbox_white.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)];
    } else {
        textEditingImage = [[UIImage imageNamed:@"cook_customise_textbox_black.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)];
    }
    return textEditingImage;
}

+ (UIImage *)textEditingSelectionBoxWhite:(BOOL)white {
    return [[UIImage imageNamed:@"cook_customise_textbox_blue.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)];
}

- (id)initWithEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
                 delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.editingView = editingView;
        self.editViewFrame = editingView.frame;
        self.delegate = delegate;
        self.contentInsets = contentInsets;
        self.userInteractionEnabled = YES;
        CGPoint pencilOffsets = CGPointMake(-32.0, -11.0);
        self.pencilOffsets = pencilOffsets;
        
        // Text box.
        UIImageView *textEditImageView = [[UIImageView alloc] initWithImage:[CKEditingTextBoxView textEditingBoxWhite:white]];
        textEditImageView.userInteractionEnabled = YES;
        textEditImageView.autoresizingMask = [self textBoxResizingMask];
        self.textEditBoxImageView = textEditImageView;
        
        // Corner pencil icon.
        UIImageView *textEditingPencilView = [[UIImageView alloc] initWithImage:[self textEditingPencilWhite:white]];
        textEditingPencilView.userInteractionEnabled = YES;
        textEditingPencilView.autoresizingMask = [self editIconResizingMask];
        self.textEditingPencilView = textEditingPencilView;
        
        // Update positioning of the editing view.
        [self updateEditingView:editingView];
        
        // Save icon to be hidden at first, and positioned in the top-right corner.
        UIButton *textEditingSaveButton = [CKEditingTextBoxView buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                                                         target:self
                                                                       selector:@selector(saveTapped:)];
        textEditingSaveButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
        textEditingSaveButton.frame = CGRectMake(self.bounds.size.width - textEditingSaveButton.frame.size.width,
                                                 0.0,
                                                 textEditingSaveButton.frame.size.width,
                                                 textEditingSaveButton.frame.size.height);
        textEditingSaveButton.hidden = YES;
        self.textEditingSaveButton = textEditingSaveButton;
        
        // Add them all.
        [self addSubview:textEditImageView];
        [self addSubview:textEditingPencilView];
        [self addSubview:textEditingSaveButton];
        
        // Register tap on self.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textBoxTapped:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];

    }
    return self;
}

- (void)updateEditingView:(UIView *)editingView {
    
    // First set them to no auto-resize as we're gonna position/size them ourselves.
    self.textEditingPencilView.autoresizingMask = UIViewAutoresizingNone;
    self.textEditBoxImageView.autoresizingMask = UIViewAutoresizingNone;
    self.editViewFrame = editingView.frame;
    
    // Get the updatedFrame given the new editViewFrame.
    CGRect updatedFrame = [self updatedFrameForProposedEditingViewFrame:self.editViewFrame];
    self.frame = updatedFrame;
    
    // Reset all the subviews.
    self.textEditingPencilView.frame = CGRectMake(self.contentInsets.left + self.editViewFrame.size.width + self.contentInsets.right + self.pencilOffsets.x,
                                                  0.0,
                                                  self.textEditingPencilView.frame.size.width,
                                                  self.textEditingPencilView.frame.size.height);
    self.textEditBoxImageView.frame = CGRectMake(0.0,
                                              self.textEditingPencilView.frame.origin.y - self.pencilOffsets.y,
                                              self.contentInsets.left + self.editViewFrame.size.width + self.contentInsets.right,
                                              self.contentInsets.top + self.editViewFrame.size.height + self.contentInsets.bottom);
    
    // Restore intended resizing mask so that scaling works in transit.
    self.textEditingPencilView.autoresizingMask = [self editIconResizingMask];
    self.textEditBoxImageView.autoresizingMask = [self textBoxResizingMask];
}

- (CGRect)updatedFrameForProposedEditingViewFrame:(CGRect)editViewFrame {
    CGRect pencilViewFrame = CGRectMake(self.contentInsets.left + editViewFrame.size.width + self.contentInsets.right + self.pencilOffsets.x,
                                        0.0,
                                        self.textEditingPencilView.frame.size.width,
                                        self.textEditingPencilView.frame.size.height);
    CGRect textBoxImageFrame = CGRectMake(0.0,
                                          pencilViewFrame.origin.y - self.pencilOffsets.y,
                                          self.contentInsets.left + editViewFrame.size.width + self.contentInsets.right,
                                          self.contentInsets.top + editViewFrame.size.height + self.contentInsets.bottom);
    
    // Overall frame.
    CGRect frame = CGRectUnion(pencilViewFrame, textBoxImageFrame);
    frame.origin.x = editViewFrame.origin.x - self.contentInsets.left;
    frame.origin.y = editViewFrame.origin.y - self.contentInsets.top;
    return frame;
}

- (void)showEditingIcon:(BOOL)show animated:(BOOL)animated {
    if (show) {
        self.textEditingPencilView.hidden = NO;
        self.textEditingPencilView.alpha = 0.0;
    }
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.textEditingPencilView.alpha = show ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.textEditingPencilView.hidden = show ? NO : YES;
        self.textEditingPencilView.alpha = show ? 1.0 : 0.0;
    }
}

- (void)showSaveIcon:(BOOL)show animated:(BOOL)animated {
    [self showSaveIcon:show enabled:YES animated:animated];
}

- (void)showSaveIcon:(BOOL)show enabled:(BOOL)enabled animated:(BOOL)animated {
    if (show) {
        self.textEditingSaveButton.hidden = NO;
        self.textEditingSaveButton.alpha = 0.0;
    }
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.textEditingSaveButton.alpha = show ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.textEditingSaveButton.enabled = enabled;
                         }];
    } else {
        self.textEditingSaveButton.enabled = enabled;
        self.textEditingSaveButton.hidden = show ? NO : YES;
        self.textEditingSaveButton.alpha = 1.0;
    }
}

- (CGRect)textBoxFrame {
    return self.textEditBoxImageView.frame;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Private methods

- (UIImage *)textEditingPencilWhite:(BOOL)white {
    UIImage *textEditingPencilImage = nil;
    if (white) {
        textEditingPencilImage = [UIImage imageNamed:@"cook_customise_btns_textedit_white.png"];
    } else {
        textEditingPencilImage = [UIImage imageNamed:@"cook_customise_btns_textedit_black.png"];
    }
    return textEditingPencilImage;
}

- (void)textBoxTapped:(UITapGestureRecognizer *)tapGesture {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(editingTextBoxViewTappedForEditingView:)]) {
        [self.delegate editingTextBoxViewTappedForEditingView:self.editingView];
    }
}
- (void)saveTapped:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(editingTextBoxViewSaveTappedForEditingView:)]) {
        [self.delegate editingTextBoxViewSaveTappedForEditingView:self.editingView];
    }
}

- (UIViewAutoresizing)editIconResizingMask {
    return UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
}

- (UIViewAutoresizing)textBoxResizingMask {
    return UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
}

@end
