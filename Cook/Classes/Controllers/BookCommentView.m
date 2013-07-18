//
//  BookCommentView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCommentView.h"
#import "CKUserProfilePhotoView.h"
#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"
#import "CKUser.h"
#import "Theme.h"

@interface BookCommentView () <CKEditingTextBoxViewDelegate>

@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *textBoxImageView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;

@end

@implementation BookCommentView

#define kContentInsets      (UIEdgeInsets){ 5.0, 5.0, 5.0, 5.0 }
#define kTextBoxWidth       450.0
#define kPhotoTextBoxGap    30.0

- (id)initWithUser:(CKUser *)user {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.user = user;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        
        CGSize profileSize = [CKUserProfilePhotoView sizeForProfileSize:ProfileViewSizeMedium];
        self.frame = (CGRect){
            0.0,
            0.0,
            kContentInsets.left + profileSize.width + kPhotoTextBoxGap + kTextBoxWidth + kContentInsets.right,
            kContentInsets.top + profileSize.height + kContentInsets.bottom
        };
        
        [self initProfilePhoto];
        [self initTextBox];
        
    }
    return self;
}

#pragma mark CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    DLog();
}

- (void)editingTextBoxViewSaveTappedForEditingView:(UIView *)editingView {
    
}


#pragma mark - Properties

- (UIImageView *)textBoxImageView {
    if (!_textBoxImageView) {
        _textBoxImageView = [[UIImageView alloc] initWithImage:[CKEditingTextBoxView textEditingBoxWhite:NO]];
    }
    return _textBoxImageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [Theme bookSocialCommentBoxFont];
        _label.textColor = [Theme bookSocialCommentBoxColour];
        _label.text = @"Your Comment";
        [_label sizeToFit];
    }
    return _label;
}

#pragma mark - Private methods

- (void)initProfilePhoto {
    self.profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.user profileSize:ProfileViewSizeMedium];
    self.profilePhotoView.frame = (CGRect) {
        kContentInsets.left + floorf((self.bounds.size.width - self.profilePhotoView.frame.size.width - kPhotoTextBoxGap - kTextBoxWidth) / 2.0),
        floorf((self.bounds.size.height - self.profilePhotoView.frame.size.height) / 2.0),
        self.profilePhotoView.frame.size.width,
        self.profilePhotoView.frame.size.height
    };
    [self addSubview:self.profilePhotoView];
}

- (void)initTextBox {
    self.label.frame = (CGRect){
        self.profilePhotoView.frame.origin.x + self.profilePhotoView.frame.size.width + kPhotoTextBoxGap,
        floorf((self.bounds.size.height - self.label.frame.size.height) / 2.0),
        kTextBoxWidth,
        self.label.frame.size.height
    };
    [self addSubview:self.label];
    
    [self.editingHelper wrapEditingView:self.label
                          contentInsets:(UIEdgeInsets) { 20.0, 20.0, 20.0, 20.0 }
                               delegate:self white:NO animated:NO];
}

@end
