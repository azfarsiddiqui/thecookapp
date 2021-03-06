//
//  CKRecipeSocialView.m
//  CKRecipeSocialViewDemo
//
//  Created by Jeff Tan-Ang on 10/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipeSocialView.h"
#import "CKRecipe.h"
#import "ViewHelper.h"
#import "CKUser.h"
#import "EventHelper.h"
#import "CKSocialManager.h"
#import "DataHelper.h"

@interface CKRecipeSocialView ()

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, weak) id<CKRecipeSocialViewDelegate> delegate;
@property (nonatomic, assign) NSInteger numComments;
@property (nonatomic, assign) NSInteger numLikes;
@property (nonatomic, strong) UIImageView *messageIconView;
@property (nonatomic, strong) UIImageView *likeIconView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likeLabel;
@property (nonatomic, assign) NSNumber *likedBoolNumber;

@end

@implementation CKRecipeSocialView

#define kContentInsets  UIEdgeInsetsMake(0.0, 0.0, 0.0, 15.0)
#define kContentHeight  44.0
#define kInterItemGap   5.0
#define kIconStatGap    0.0
#define kFont           [UIFont fontWithName:@"BrandonGrotesque-Regular" size:22.0];

- (void)dealloc {
    [EventHelper unregisterSocialUpdates:self];
}

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<CKRecipeSocialViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.recipe = recipe;
        self.delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
        
        [self updateNumComments:[[CKSocialManager sharedInstance] numCommentsForRecipe:recipe]
                       numLikes:[[CKSocialManager sharedInstance] numLikesForRecipe:recipe]];
        
        // Register tap.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapGesture];
        
        // Listen for like events.
        [EventHelper registerSocialUpdates:self selector:@selector(socialUpdates:)];
        
    }
    return self;
}

- (void)incrementLike:(BOOL)increment {
    [self updateNumComments:self.numComments
                   numLikes:(increment ? self.numLikes + 1 : self.numLikes - 1)];
}

- (void)incrementComments:(BOOL)increment {
    [self updateNumComments:(increment ? self.numComments + 1 : self.numComments - 1)
                   numLikes:self.numLikes];
}

#pragma mark - Properties

- (UIImageView *)messageIconView {
    if (!_messageIconView) {
        _messageIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_icon_comment_light.png"]];
        [self addSubview:_messageIconView];
    }
    return _messageIconView;
}

- (UILabel *)commentsLabel {
    if (!_commentsLabel) {
        _commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentsLabel.backgroundColor = [UIColor clearColor];
        _commentsLabel.font = kFont;
        _commentsLabel.textColor = [UIColor whiteColor];
        _commentsLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _commentsLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        
        // TODO Shadow blur radius 3.0
        
        [self addSubview:_commentsLabel];
    }
    return _commentsLabel;
}

- (UIImageView *)likeIconView {
    if (!_likeIconView) {
        _likeIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_icon_like_light.png"]];
        [self addSubview:_likeIconView];
    }
    return _likeIconView;
}

- (UILabel *)likeLabel {
    if (!_likeLabel) {
        _likeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _likeLabel.backgroundColor = [UIColor clearColor];
        _likeLabel.font = kFont;
        _likeLabel.textColor = [UIColor whiteColor];
        _likeLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _likeLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self addSubview:_likeLabel];
    }
    return _likeLabel;
}

#pragma mark - Private methods

- (void)updateNumComments:(NSInteger)numComments numLikes:(NSInteger)numLikes {
    DLog("Update with comments[%d] likes[%d]", numComments, numLikes);
    
    self.numComments = numComments;
    self.numLikes = numLikes;
    
    // Keeps track of the required width.
    CGFloat requiredWidth = kContentInsets.left;
    
    // Update like icon.
    self.likeIconView.frame = (CGRect){
        kContentInsets.left,// self.commentsLabel.frame.origin.x + self.commentsLabel.frame.size.width + kInterItemGap,
        floorf((kContentHeight - self.likeIconView.frame.size.height) / 2.0),
        self.likeIconView.frame.size.width,
        self.likeIconView.frame.size.height
    };
    requiredWidth += self.likeIconView.frame.size.width;
    requiredWidth += kIconStatGap;
    
    // Update likes label.
    self.likeLabel.text = [DataHelper friendlyDisplayForCount:numLikes];
    [self.likeLabel sizeToFit];
    self.likeLabel.frame = (CGRect){
        self.likeIconView.frame.origin.x + self.likeIconView.frame.size.width + kIconStatGap,
        floorf((kContentHeight - self.likeLabel.frame.size.height) / 2.0) - 1.0,
        self.likeLabel.frame.size.width,
        self.likeLabel.frame.size.height
    };
    requiredWidth += self.likeLabel.frame.size.width;
    requiredWidth += kContentInsets.right;
    
    // Comments icon.
    self.messageIconView.frame = (CGRect){
        self.likeLabel.frame.origin.x + self.likeLabel.frame.size.width + kInterItemGap,
        floorf((kContentHeight - self.messageIconView.frame.size.height) / 2.0),
        self.messageIconView.frame.size.width,
        self.messageIconView.frame.size.height
    };
    requiredWidth += self.messageIconView.frame.size.width + kIconStatGap;
    
    // Update comments label.
    self.commentsLabel.text = [DataHelper friendlyDisplayForCount:numComments];
    [self.commentsLabel sizeToFit];
    self.commentsLabel.frame = (CGRect){
        self.messageIconView.frame.origin.x + self.messageIconView.frame.size.width + kIconStatGap,
        floorf((kContentHeight - self.commentsLabel.frame.size.height) / 2.0) - 1.0,
        self.commentsLabel.frame.size.width,
        self.commentsLabel.frame.size.height
    };
    requiredWidth += self.commentsLabel.frame.size.width;
    requiredWidth += kInterItemGap;
    
    // Update frame.
    self.frame = (CGRect){0.0, 0.0, requiredWidth, kContentHeight};
    
    [self.delegate recipeSocialViewUpdated:self];
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    [self.delegate recipeSocialViewTapped];
}

- (void)socialUpdates:(NSNotification *)notification {
    CKRecipe *recipe = [EventHelper socialUpdatesRecipeForNotification:notification];
    
    // Ignore unrelated recipe.
    if (![recipe.objectId isEqualToString:recipe.objectId]) {
        return;
    }
    
    // Likes updated?
    if ([EventHelper socialUpdatesHasNumLikes:notification]) {
        NSInteger numLikes = [EventHelper numLikesForNotification:notification];
        [self updateNumComments:self.numComments numLikes:numLikes];
    }
    
    // Comments updated?
    if ([EventHelper socialUpdatesHasNumComments:notification]) {
        NSInteger numComments = [EventHelper numCommentsForNotification:notification];
        [self updateNumComments:numComments numLikes:self.numLikes];
    }
}

@end
