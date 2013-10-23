//
//  RecipeCommentBoxFooterView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 24/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeCommentBoxFooterView.h"
#import "CKUser.h"
#import "CKUserProfilePhotoView.h"
#import "Theme.h"
#import "CKEditingViewHelper.h"

@interface RecipeCommentBoxFooterView () <CKEditingTextBoxViewDelegate>

@property (nonatomic, strong) CKUserProfilePhotoView *profileView;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;

@end

@implementation RecipeCommentBoxFooterView

#define kContentInsets          (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define kTextBoxInsets          (UIEdgeInsets){ 30.0, 28.0, 22.0, 40.0 }
#define kProfileCommentGap      40.0

+ (CGSize)unitSize {
    return (CGSize){ 600.0, 100.0 };
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.profileView];
        [self addSubview:self.commentLabel];
        
        // Wrap it in editing wrapper.
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        [self.editingHelper wrapEditingView:self.commentLabel contentInsets:kTextBoxInsets delegate:self white:YES editMode:NO];
        
    }
    return self;
}

- (void)configureUser:(CKUser *)user {
    [self.profileView loadProfilePhotoForUser:user];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    [self.delegate recipeCommentBoxFooterViewCommentRequested];
}

#pragma mark - Properties

- (CKUserProfilePhotoView *)profileView {
    if (!_profileView) {
        _profileView = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeSmall];
        _profileView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        _profileView.frame = (CGRect){
            floorf((self.bounds.size.width - [RecipeCommentBoxFooterView unitSize].width) / 2.0) + kContentInsets.left,
            floorf((self.bounds.size.height - _profileView.frame.size.height) / 2.0),
            _profileView.frame.size.width,
            _profileView.frame.size.height
        };
    }
    return _profileView;
}

- (UILabel *)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.font = [Theme recipeCommentFont];
        _commentLabel.textColor = [UIColor blackColor];
        _commentLabel.text = @"Comment";
        _commentLabel.shadowOffset = (CGSize){ 0.0, -1.0 };
        _commentLabel.shadowColor = [UIColor whiteColor];
        _commentLabel.userInteractionEnabled = NO;
        _commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _commentLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        [_commentLabel sizeToFit];
        
        CGFloat availableWidth = [RecipeCommentBoxFooterView unitSize].width - kContentInsets.left - self.profileView.frame.size.width - kProfileCommentGap - kContentInsets.right;
        _commentLabel.frame = (CGRect){
            self.profileView.frame.origin.x + self.profileView.frame.size.width + kProfileCommentGap,
            floorf((self.bounds.size.height - _commentLabel.frame.size.height) / 2.0),
            availableWidth,
            _commentLabel.frame.size.height
        };
    }
    return _commentLabel;
}

#pragma mark - Private methods

@end
