//
//  RecipeSocialCommentsCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSocialCommentCell.h"
#import "CKUser.h"
#import "CKUserProfilePhotoView.h"
#import "Theme.h"
#import "CKEditingViewHelper.h"
#import "CKRecipeComment.h"

@interface RecipeSocialCommentCell () <CKEditingTextBoxViewDelegate>

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) CKUserProfilePhotoView *profileView;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;

@end

@implementation RecipeSocialCommentCell

#define kWidth              600.0
#define kProfileCommentGap  30.0
#define kNameCommentGap     5.0
#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define kTextBoxInsets      (UIEdgeInsets){ 30.0, 28.0, 22.0, 40.0 }

+ (CGSize)sizeForComment:(CKRecipeComment *)comment {
    return CGSizeZero;
}

+ (CGSize)unitSize {
    return (CGSize){ kWidth, 100.0 };
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.currentUser = [CKUser currentUser];
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        
        [self.contentView addSubview:self.profileView];
        [self.contentView addSubview:self.commentLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [self.editingHelper unwrapEditingView:self.commentLabel];
}

- (void)configureWithComment:(CKRecipeComment *)comment {
    
    CGSize availableSize = [self availableCommentSize];
    
    // Load profile photo.
    CKUser *user = comment.user;
    [self.profileView loadProfilePhotoForUser:user];
    
    // Name label.
    self.nameLabel.hidden = NO;
    self.nameLabel.text = user.name;
    CGSize size = [self.nameLabel sizeThatFits:availableSize];
    self.commentLabel.frame = (CGRect){
        self.profileView.frame.origin.x + self.profileView.frame.size.width + kProfileCommentGap,
        kContentInsets.top,
        size.width,
        size.height
    };
    
    // Comment.
    availableSize = (CGSize) {
        availableSize.width,
        availableSize.height - self.nameLabel.frame.size.height - kNameCommentGap
    };
    self.commentLabel.text = comment.text;
    size = [self.commentLabel sizeThatFits:availableSize];
    self.commentLabel.frame = (CGRect){
        self.profileView.frame.origin.x + self.profileView.frame.size.width + kProfileCommentGap,
        self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + kNameCommentGap,
        availableSize.width,
        size.height
    };
}

- (void)configureAsPostCommentCell {
    
    // Load current user's profile.
    [self.profileView loadProfilePhotoForUser:self.currentUser];
    
    // Placeholder for commenting.
    self.commentLabel.text = @"Your Comment";
    
    // Hide the name.
    self.nameLabel.hidden = YES;
    
    //  Reposition the box to be centered.
    CGSize availableSize = [self availableCommentSize];
    CGSize size = [self.commentLabel sizeThatFits:availableSize];
    self.commentLabel.frame = (CGRect){
        self.profileView.frame.origin.x + self.profileView.frame.size.width + kProfileCommentGap,
        kContentInsets.top + floorf((availableSize.height - size.height) / 2.0),
        availableSize.width,
        size.height
    };
    
    // Wrap it in a box.
    [self.editingHelper wrapEditingView:self.commentLabel contentInsets:kTextBoxInsets delegate:self white:NO editMode:NO];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    DLog();
}

- (void)editingTextBoxViewSaveTappedForEditingView:(UIView *)editingView {
    DLog();
}

#pragma mark - Properties

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [Theme recipeCommenterFont];
        _nameLabel.textColor = [Theme recipeCommenterColour];
        _nameLabel.shadowOffset = (CGSize){ 0.0, 1.0 };
        _nameLabel.shadowColor = [UIColor blackColor];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    }
    return _nameLabel;
}

- (UILabel *)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.font = [Theme recipeCommentFont];
        _commentLabel.textColor = [Theme recipeCommentColour];
        _commentLabel.shadowOffset = (CGSize){ 0.0, 1.0 };
        _commentLabel.shadowColor = [UIColor blackColor];
        _commentLabel.numberOfLines = 0;
        _commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _commentLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    }
    return _commentLabel;
}

- (CKUserProfilePhotoView *)profileView {
    if (!_profileView) {
        _profileView = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeMedium];
        _profileView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        _profileView.frame = (CGRect){
            kContentInsets.left,
            floorf((self.contentView.bounds.size.height - _profileView.frame.size.height) / 2.0),
            _profileView.frame.size.width,
            _profileView.frame.size.height
        };
    }
    return _profileView;
}

#pragma mark - Privaet methods

- (CGSize)availableCommentSize {
    return (CGSize){
        self.contentView.bounds.size.width - kContentInsets.left - self.profileView.frame.size.width - kProfileCommentGap - kContentInsets.right,
        self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom
    };
}

@end
