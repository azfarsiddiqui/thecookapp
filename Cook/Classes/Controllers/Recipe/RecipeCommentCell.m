//
//  RecipeSocialCommentsCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeCommentCell.h"
#import "CKUser.h"
#import "CKUserProfilePhotoView.h"
#import "Theme.h"
#import "CKRecipeComment.h"
#import "DateHelper.h"

@interface RecipeCommentCell () <CKUserProfilePhotoViewDelegate>

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) CKUserProfilePhotoView *profileView;

@end

@implementation RecipeCommentCell

#define kWidth                  600.0
#define kProfileCommentGap      30.0
#define kNameCommentGap         1.0
#define kContentInsets          (UIEdgeInsets){ 20.0, 20.0, 10.0, 20.0 }
#define kTextBoxInsets          (UIEdgeInsets){ 30.0, 28.0, 22.0, 40.0 }
#define kCommentTimeGap         3.0

+ (CGSize)sizeForComment:(CKRecipeComment *)comment {
    CGSize size = (CGSize){ kWidth, 0.0 };
    size.height += kContentInsets.top;
    
    CKUser *user = comment.user;
    
    // Name.
    CGRect nameFrame = [user.name boundingRectWithSize:(CGSize){ kWidth, MAXFLOAT }
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName : [Theme recipeCommenterFont] }
                                               context:nil];
    size.height += nameFrame.size.height;
    
    // Name/Comment Gap.
    size.height += kNameCommentGap;
    
    // Comment.
    CGRect commentFrame = [comment.text boundingRectWithSize:(CGSize){ kWidth, MAXFLOAT }
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{ NSFontAttributeName : [Theme recipeCommentFont] }
                                                     context:nil];
    size.height += commentFrame.size.height;
    
    // Time.
    NSDate *createdDateTime = comment.createdDateTime ? comment.createdDateTime : [NSDate date];
    NSString *timeDisplay = [[[DateHelper sharedInstance] relativeDateTimeDisplayForDate:createdDateTime] uppercaseString];
    CGRect timeFrame = [timeDisplay boundingRectWithSize:(CGSize){ kWidth, MAXFLOAT }
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{ NSFontAttributeName : [Theme overlayTimeFont] }
                                                 context:nil];
    size.height += timeFrame.size.height;
    
    size.height += kContentInsets.bottom;
    return size;
}

+ (CGSize)unitSize {
    return (CGSize){ kWidth, 100.0 };
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.profileView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.commentLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.dividerView];
    }
    return self;
}

- (void)configureWithComment:(CKRecipeComment *)comment commentIndex:(NSUInteger)commentIndex
                 numComments:(NSUInteger)numComments {
    
    CGSize availableSize = [self availableCommentSize];
    
    // Load profile photo.
    CKUser *user = comment.user;
    [self.profileView loadProfilePhotoForUser:user];
    
    // Name label.
    self.nameLabel.hidden = NO;
    self.nameLabel.text = user.name;
    
    // Cached or calculate frame.
    NSValue *nameFrameValue = [self.delegate recipeSocialCommentCellNameFrameValueForCommentIndex:commentIndex];
    CGRect nameFrame;
    if (!nameFrameValue) {
        nameFrame = [user.name boundingRectWithSize:(CGSize){ kWidth, MAXFLOAT }
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{ NSFontAttributeName : [Theme recipeCommenterFont] }
                                            context:nil];
        [self.delegate recipeSocialCommentCellCacheNameFrame:nameFrame commentIndex:commentIndex];
    } else {
        nameFrame = [nameFrameValue CGRectValue];
    }
    
    CGSize size = nameFrame.size;
    self.nameLabel.frame = (CGRect){
        self.profileView.frame.origin.x + self.profileView.frame.size.width + kProfileCommentGap,
        kContentInsets.top,
        size.width,
        size.height
    };
    
    // Comment.
    self.commentLabel.text = comment.text;
    
    // Cached or calculate frame.
    NSValue *commentFrameValue = [self.delegate recipeSocialCommentCellCommentFrameValueForCommentIndex:commentIndex];
    CGRect commentFrame;
    if (!commentFrameValue) {
        commentFrame = [comment.text boundingRectWithSize:(CGSize){ kWidth, MAXFLOAT }
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{ NSFontAttributeName : [Theme recipeCommentFont] }
                                                  context:nil];
        [self.delegate recipeSocialCommentCellCacheCommentFrame:commentFrame commentIndex:commentIndex];
    } else {
        commentFrame = [commentFrameValue CGRectValue];
    }
    
    size = commentFrame.size;
    self.commentLabel.frame = (CGRect){
        self.profileView.frame.origin.x + self.profileView.frame.size.width + kProfileCommentGap,
        self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + kNameCommentGap,
        availableSize.width,
        size.height
    };
    
    // Time.
    NSString *timeDisplay = [self.delegate recipeSocialCommentCellTimeDisplayForCommentIndex:commentIndex];
    self.timeLabel.text = timeDisplay;
    
    // Cached or calculate frame.
    NSValue *timeFrameValue = [self.delegate recipeSocialCommentCellTimeFrameValueForCommentIndex:commentIndex];
    CGRect timeFrame;
    if (!timeFrameValue) {
        timeFrame = [timeDisplay boundingRectWithSize:(CGSize){ kWidth, MAXFLOAT }
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{ NSFontAttributeName : [Theme overlayTimeFont] }
                                              context:nil];
        [self.delegate recipeSocialCommentCellCacheTimeFrame:timeFrame commentIndex:commentIndex];
    } else {
        timeFrame = [timeFrameValue CGRectValue];
    }

    size = timeFrame.size;
    self.timeLabel.frame = (CGRect){
        self.contentView.bounds.size.width - size.width,
        self.nameLabel.frame.origin.y + 5.0,
        size.width,
        size.height
    };
    
    // Divider.
    if (commentIndex == numComments - 1) {
        self.dividerView.hidden = YES;
    } else {
        self.dividerView.hidden = NO;
        self.dividerView.frame = (CGRect){
            self.contentView.bounds.origin.x,
            self.contentView.bounds.size.height - self.dividerView.frame.size.height,
            self.contentView.bounds.size.width,
            self.dividerView.frame.size.height
        };
    }
    
}

- (NSString *)currentComment {
    return self.commentLabel.text;
}

#pragma mark - CKUserProfilePhotoViewDelegate methods

- (void)userProfilePhotoViewTappedForUser:(CKUser *)user {
    if ([self.delegate respondsToSelector:@selector(recipeSocialCommentCellProfileRequestedForUser:)]) {
        [self.delegate recipeSocialCommentCellProfileRequestedForUser:user];
    }
}

#pragma mark - Properties

- (CKUserProfilePhotoView *)profileView {
    if (!_profileView) {
        _profileView = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeMedium];
        _profileView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        _profileView.delegate = self;
        _profileView.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top,
            _profileView.frame.size.width,
            _profileView.frame.size.height
        };
    }
    return _profileView;
}

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

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [Theme overlayTimeFont];
        _timeLabel.textColor = [Theme overlayTimeColour];
        _timeLabel.shadowOffset = (CGSize){ 0.0, 1.0 };
        _timeLabel.shadowColor = [UIColor blackColor];
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    }
    return _timeLabel;
}

- (UIView *)dividerView {
    if (!_dividerView) {
        _dividerView = [[UIView alloc] initWithFrame:(CGRect){ 0.0, 0.0, 1.0, 1.0 }];
        _dividerView.backgroundColor = [UIColor darkGrayColor];
        _dividerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    }
    return _dividerView;
}

#pragma mark - Privaet methods

- (CGSize)availableCommentSize {
    return (CGSize){
        self.contentView.bounds.size.width - kContentInsets.left - self.profileView.frame.size.width - kProfileCommentGap - kContentInsets.right,
        self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom
    };
}

@end
