//
//  CKEditingTextBoxView.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"

@interface CKEditingTextBoxView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *editingView;
@property (nonatomic, strong) UIImageView *textEditBoxImageView;
@property (nonatomic, strong) UIButton *textEditingSaveButton;
@property (nonatomic, assign) CGPoint iconOffset;
@property (nonatomic, assign) BOOL white;
@property (nonatomic, assign) BOOL editMode;

@end

@implementation CKEditingTextBoxView

#define kSaveButtonScaling 0.78

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    return button;
}

+ (UIImage *)textEditingBoxWhite:(BOOL)white {
    return [self textEditingBoxWhite:white editMode:NO];
}

+ (UIImage *)textEditingBoxWhite:(BOOL)white editMode:(BOOL)editMode {
    UIEdgeInsets capInsets = (UIEdgeInsets){ 50.0, 37.0, 15.0, 45.0 };

    // Construct the required image name.
    NSMutableString *textBoxName = [NSMutableString stringWithString:@"cook_customise_textbox"];
    [textBoxName appendString:white ? @"_white" : @"_black"];
    [textBoxName appendString:editMode ? @"_edit" : @""];
    [textBoxName appendString:@".png"];
    
    UIImage *textBoxImage = [[UIImage imageNamed:textBoxName] resizableImageWithCapInsets:capInsets];
    return textBoxImage;
}

+ (UIImage *)textEditingSelectionBoxWhite:(BOOL)white {
    return [[UIImage imageNamed:@"cook_customise_textbox_blue.png"]
            resizableImageWithCapInsets:(UIEdgeInsets){ 50.0, 37.0, 15.0, 45.0 }];
}

- (id)initWithEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
                 delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    
    return [self initWithEditingView:editingView contentInsets:contentInsets white:white editMode:YES delegate:delegate];
}

- (id)initWithEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
                 editMode:(BOOL)editMode delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.editingView = editingView;
        self.editViewFrame = editingView.frame;
        self.delegate = delegate;
        self.contentInsets = contentInsets;
        self.userInteractionEnabled = YES;
        self.white = white;
        self.editMode = editMode;
        self.iconOffset = CGPointMake(-32.0, -11.0);
        
        // Text box.
        UIImageView *textEditImageView = [[UIImageView alloc] initWithImage:[CKEditingTextBoxView textEditingBoxWhite:white editMode:editMode]];
        textEditImageView.userInteractionEnabled = YES;
        textEditImageView.autoresizingMask = [self textBoxResizingMask];
        self.textEditBoxImageView = textEditImageView;
        
        // Update positioning of the editing view.
        [self updateEditingView:editingView];
        
        // Save icon to be hidden at first, and positioned in the top-right corner.
        UIButton *textEditingSaveButton = [CKEditingViewHelper okayButtonWithTarget:self selector:@selector(saveTapped:)];
        textEditingSaveButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
        textEditingSaveButton.frame = (CGRect){
            self.bounds.size.width - textEditingSaveButton.frame.size.width + 16.0,
            -11.0,
            textEditingSaveButton.frame.size.width,
            textEditingSaveButton.frame.size.height};
        textEditingSaveButton.alpha = 0.0;
        self.textEditingSaveButton = textEditingSaveButton;
        
        // Add them all.
        [self addSubview:textEditImageView];
        [self addSubview:textEditingSaveButton];
        
        // Register tap on self.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textBoxTapped:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];

    }
    return self;
}

- (void)updateEditingView:(UIView *)editingView {
    [self updateEditingView:editingView updated:NO];
}

- (void)updateEditingView:(UIView *)editingView updated:(BOOL)updated {
    if (updated) {
        self.textEditBoxImageView.image = [CKEditingTextBoxView textEditingBoxWhite:!self.white editMode:self.editMode];
    } else {
        self.textEditBoxImageView.image = [CKEditingTextBoxView textEditingBoxWhite:self.white editMode:self.editMode];
    }
    
    // First set them to no auto-resize as we're gonna position/size them ourselves.
    self.textEditBoxImageView.autoresizingMask = UIViewAutoresizingNone;
    self.editViewFrame = editingView.frame;
    
    // Derive the current frame from the given editing frame including the contentInsets for the textbox imageview.
    self.frame = [self updatedFrameForProposedEditingViewFrame:self.editViewFrame];
    
    // Reset all the subviews.
    self.textEditBoxImageView.frame = CGRectMake(0.0,
                                                 0.0,
                                                 self.contentInsets.left + self.editViewFrame.size.width + self.contentInsets.right,
                                                 self.contentInsets.top + self.editViewFrame.size.height + self.contentInsets.bottom);
    
    // Restore intended resizing mask so that scaling works in transit.
    self.textEditBoxImageView.autoresizingMask = [self textBoxResizingMask];
}

- (CGRect)updatedFrameForProposedEditingViewFrame:(CGRect)editViewFrame {
    
    // Overall frame.
    CGRect frame = CGRectMake(editViewFrame.origin.x - self.contentInsets.left,
                              editViewFrame.origin.y - self.contentInsets.top,
                              self.contentInsets.left + editViewFrame.size.width + self.contentInsets.right,
                              self.contentInsets.top + editViewFrame.size.height + self.contentInsets.bottom);;
    return frame;
}

- (void)showSaveIcon:(BOOL)show animated:(BOOL)animated {
    [self showSaveIcon:show enabled:YES animated:animated];
}

- (void)showSaveIcon:(BOOL)show enabled:(BOOL)enabled animated:(BOOL)animated {
    if (show) {
        self.textEditingSaveButton.alpha = 0.0;
    }
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.textEditingSaveButton.alpha = show ? 1.0 : 0.0;
                             self.textEditingSaveButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeScale(kSaveButtonScaling, kSaveButtonScaling);
                         }
                         completion:^(BOOL finished) {
                             self.textEditingSaveButton.enabled = enabled;
                         }];
    } else {
        self.textEditingSaveButton.enabled = enabled;
        self.textEditingSaveButton.alpha = show ? 1.0 : 0.0;
        self.textEditingSaveButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeScale(kSaveButtonScaling, kSaveButtonScaling);
    }
}

- (CGRect)textBoxFrame {
    return self.textEditBoxImageView.frame;
}

- (void)setTextBoxViewWithEdit:(BOOL)editMode {
    self.textEditBoxImageView.image = [CKEditingTextBoxView textEditingBoxWhite:self.white editMode:editMode];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Private methods

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
