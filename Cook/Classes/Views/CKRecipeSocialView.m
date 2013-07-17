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

@interface CKRecipeSocialView ()

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, assign) id<CKRecipeSocialViewDelegate> delegate;
@property (nonatomic, assign) NSInteger numComments;
@property (nonatomic, assign) NSInteger numLikes;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *messageIconView;
@property (nonatomic, strong) UIImageView *likeIconView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likeLabel;
@property (nonatomic, assign) NSNumber *likedBoolNumber;

@end

@implementation CKRecipeSocialView

#define kContentInsets  UIEdgeInsetsMake(12.0, 22.0, 12.0, 24.0)
#define kInterItemGap   15.0
#define kIconStatGap    5.0
#define kFont           [UIFont boldSystemFontOfSize:15]

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<CKRecipeSocialViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.recipe = recipe;
        self.delegate = delegate;
        
        [self updateNumComments:0 numLikes:0];
        
        // Register tap.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapGesture];
        
        // Load data.
        [self loadData];

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

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_dash_notitifcations_bg.png"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 19.0, 0.0, 19.0)];
        _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.frame = CGRectMake(0.0, 0.0, backgroundImage.size.width, backgroundImage.size.height);
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (UIImageView *)messageIconView {
    if (!_messageIconView) {
        _messageIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_notitifcations_comment.png"]];
        [self.backgroundView addSubview:_messageIconView];
    }
    return _messageIconView;
}

- (UILabel *)commentsLabel {
    if (!_commentsLabel) {
        _commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentsLabel.backgroundColor = [UIColor clearColor];
        _commentsLabel.font = kFont;
        _commentsLabel.textColor = [UIColor whiteColor];
        _commentsLabel.shadowColor = [UIColor blackColor];
        _commentsLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.backgroundView addSubview:_commentsLabel];
    }
    return _commentsLabel;
}

- (UIImageView *)likeIconView {
    if (!_likeIconView) {
        _likeIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_notitifcations_like.png"]];
        [self.backgroundView addSubview:_likeIconView];
    }
    return _likeIconView;
}

- (UILabel *)likeLabel {
    if (!_likeLabel) {
        _likeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _likeLabel.backgroundColor = [UIColor clearColor];
        _likeLabel.font = kFont;
        _likeLabel.textColor = [UIColor whiteColor];
        _likeLabel.shadowColor = [UIColor blackColor];
        _likeLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.backgroundView addSubview:_likeLabel];
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
    
    // Comments icon.
    self.messageIconView.frame = (CGRect){
        kContentInsets.left,
        floorf((self.backgroundView.frame.size.height - self.messageIconView.frame.size.height) / 2.0) + 1.0,
        self.messageIconView.frame.size.width,
        self.messageIconView.frame.size.height
    };
    requiredWidth += self.messageIconView.frame.size.width + kIconStatGap;
    
    // Update comments label.
    self.commentsLabel.text = [NSString stringWithFormat:@"%d", numComments];
    [self.commentsLabel sizeToFit];
    self.commentsLabel.frame = (CGRect){
        self.messageIconView.frame.origin.x + self.messageIconView.frame.size.width + kIconStatGap,
        floorf((self.backgroundView.frame.size.height - self.commentsLabel.frame.size.height) / 2.0) - 1.0,
        self.commentsLabel.frame.size.width,
        self.commentsLabel.frame.size.height
    };
    requiredWidth += self.commentsLabel.frame.size.width;
    requiredWidth += kInterItemGap;
    
    // Update like icon.
    self.likeIconView.frame = (CGRect){
        self.commentsLabel.frame.origin.x + self.commentsLabel.frame.size.width + kInterItemGap,
        floorf((self.backgroundView.frame.size.height - self.likeIconView.frame.size.height) / 2.0) + 1.0,
        self.likeIconView.frame.size.width,
        self.likeIconView.frame.size.height
    };
    requiredWidth += self.likeIconView.frame.size.width;
    requiredWidth += kIconStatGap;
    
    // Update likes label.
    self.likeLabel.text = [NSString stringWithFormat:@"%d", numLikes];
    [self.likeLabel sizeToFit];
    self.likeLabel.frame = (CGRect){
        self.likeIconView.frame.origin.x + self.likeIconView.frame.size.width + kIconStatGap,
        floorf((self.backgroundView.frame.size.height - self.commentsLabel.frame.size.height) / 2.0) - 1.0,
        self.likeLabel.frame.size.width,
        self.likeLabel.frame.size.height
    };
    requiredWidth += self.likeLabel.frame.size.width;
    requiredWidth += kContentInsets.right;
    
    // Update frame.
    self.backgroundView.frame = CGRectMake(0.0, 0.0, requiredWidth, self.backgroundView.frame.size.height);
    self.frame = self.backgroundView.frame;
    
    [self.delegate recipeSocialViewUpdated:self];
}

- (void)loadData {
    DLog();
    
    // Load the number of likes.
    [self.recipe numLikesWithCompletion:^(int numLikes) {
        [self updateNumComments:self.numComments numLikes:numLikes];
    } failure:^(NSError *error) {
    }];
    
    // Load the numner of comments.
    [self.recipe numCommentsWithCompletion:^(int numComments) {
        [self updateNumComments:numComments numLikes:self.numLikes];
    } failure:^(NSError *error) {
    }];
    
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    [self.delegate recipeSocialViewTapped];
}

@end
