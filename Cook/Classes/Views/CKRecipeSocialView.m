//
//  CKRecipeSocialView.m
//  CKRecipeSocialViewDemo
//
//  Created by Jeff Tan-Ang on 10/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipeSocialView.h"

@interface CKRecipeSocialView ()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *messageIconView;
@property (nonatomic, strong) UIImageView *likeIconView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *likeLabel;

@end

@implementation CKRecipeSocialView

#define kContentInsets  UIEdgeInsetsMake(12.0, 22.0, 12.0, 24.0)
#define kInterItemGap   15.0
#define kIconStatGap    5.0
#define kFont           [UIFont boldSystemFontOfSize:15]

- (id)initWithNumComments:(NSInteger)numComments numLikes:(NSInteger)numLikes {
    if (self = [super initWithFrame:CGRectZero]) {
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_dash_notitifcations_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 19.0, 0.0, 19.0)];
        
        // Keeps track of the required width.
        CGFloat requiredWidth = kContentInsets.left;
        
        // Comments icon.
        UIImageView *messageIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_notitifcations_comment.png"]];
        messageIconView.frame = CGRectMake(kContentInsets.left,
                                           floorf((backgroundImage.size.height - messageIconView.frame.size.height) / 2.0) + 1.0,
                                           messageIconView.frame.size.width,
                                           messageIconView.frame.size.height);
        self.messageIconView = messageIconView;
        requiredWidth += messageIconView.frame.size.width;
        
        // Comments label.
        NSString *comments = [NSString stringWithFormat:@"%d", numComments];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.font = kFont;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.shadowColor = [UIColor blackColor];
        messageLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        messageLabel.text = comments;
        [messageLabel sizeToFit];
        messageLabel.frame = CGRectMake(messageIconView.frame.origin.x + messageIconView.frame.size.width + kIconStatGap,
                                        floorf((backgroundImage.size.height - messageLabel.frame.size.height) / 2.0) - 1.0,
                                        messageLabel.frame.size.width,
                                        messageLabel.frame.size.height);
        self.messageLabel = messageLabel;
        requiredWidth += kIconStatGap + messageLabel.frame.size.width;
        
        // Like icon.
        UIImageView *likeIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_notitifcations_like.png"]];
        likeIconView.frame = CGRectMake(messageLabel.frame.origin.x + messageLabel.frame.size.width + kInterItemGap,
                                        floorf((backgroundImage.size.height - likeIconView.frame.size.height) / 2.0) + 1.0,
                                        likeIconView.frame.size.width,
                                        likeIconView.frame.size.height);
        self.likeIconView = likeIconView;
        requiredWidth += kInterItemGap + likeIconView.frame.size.width;
        
        // Likes label.
        NSString *likes = [NSString stringWithFormat:@"%d", numLikes];
        UILabel *likeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        likeLabel.backgroundColor = [UIColor clearColor];
        likeLabel.font = kFont;
        likeLabel.textColor = [UIColor whiteColor];
        likeLabel.shadowColor = [UIColor blackColor];
        likeLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        likeLabel.text = likes;
        [likeLabel sizeToFit];
        likeLabel.frame = CGRectMake(likeIconView.frame.origin.x + likeIconView.frame.size.width + kIconStatGap,
                                     floorf((backgroundImage.size.height - likeLabel.frame.size.height) / 2.0) - 1.0,
                                     likeLabel.frame.size.width,
                                     likeLabel.frame.size.height);
        self.likeLabel = likeLabel;
        requiredWidth += kIconStatGap + likeLabel.frame.size.width;
        requiredWidth += kContentInsets.right;
        
        // Background view.
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundView.userInteractionEnabled = YES;
        backgroundView.frame = CGRectMake(0.0, 0.0, requiredWidth, backgroundView.frame.size.height);
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [backgroundView addSubview:messageIconView];
        [backgroundView addSubview:messageLabel];
        [backgroundView addSubview:likeIconView];
        [backgroundView addSubview:likeLabel];
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
        
        // BackgroundView is self frame.
        self.frame = backgroundView.frame;;
    }
    return self;
}

@end
