//
//  CKLikeView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 16/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKLikeView.h"
#import "ViewHelper.h"
#import "CKRecipe.h"
#import "CKUser.h"
#import "EventHelper.h"

@interface CKLikeView ()

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, assign) BOOL dark;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, strong) UIButton *likeButton;

@end

@implementation CKLikeView

+ (CGSize)likeSize {
    return [self buttonImageForOn:NO dark:NO].size;
}

- (void)dealloc {
    [EventHelper unregisterLiked:self];
}

- (id)initWithRecipe:(CKRecipe *)recipe {
    return [self initWithRecipe:recipe darkMode:NO];
}

- (id)initWithRecipe:(CKRecipe *)recipe darkMode:(BOOL)dark {
    if (self = [super initWithFrame:CGRectZero]) {
        self.recipe = recipe;
        self.dark = dark;
        self.backgroundColor = [UIColor clearColor];
        
        self.likeButton = [ViewHelper buttonWithImage:[CKLikeView buttonImageForOn:NO dark:dark] target:self selector:@selector(tapped:)];
        self.likeButton.userInteractionEnabled = NO;
        self.frame = self.likeButton.frame;
        [self addSubview:self.likeButton];
        
        [EventHelper registerLiked:self selector:@selector(likedNotification:)];
        
        [self loadData];
    }
    return self;
}

#pragma mark - Private methods

- (void)loadData {
    
    // Load if the current user has liked it.
    [self.recipe likedByUser:[CKUser currentUser]
                  completion:^(BOOL liked) {
                      self.liked = liked;
                      self.likeButton.userInteractionEnabled = YES;
                      [self updateButtonWithLiked:liked];
                  } failure:^(NSError *error) {
                      self.likeButton.userInteractionEnabled = NO;
                  }];
    
}


- (void)tapped:(id)sender {
    [self like:!self.liked];
}

- (void)like:(BOOL)like {
    
    // Tentative liked state and disable interaction.
    [self updateButtonWithLiked:like];
    self.likeButton.userInteractionEnabled = NO;
    [EventHelper postLiked:like];
    
    // Like via the server.
    [self.recipe like:like
                 user:[CKUser currentUser]
           completion:^{
               self.liked = like;
               self.likeButton.userInteractionEnabled = YES;
               
           } failure:^(NSError *error) {
               
               // Revert the liked state.
               self.liked = !like;
               self.likeButton.userInteractionEnabled = YES;
               [self updateButtonWithLiked:self.liked];
               [EventHelper postLiked:like];
           }];
}

+ (UIImage *)buttonImageForOn:(BOOL)on dark:(BOOL)dark {
    NSMutableString *imageName = [NSMutableString stringWithFormat:@"cook_book_inner_icon_like_%@", dark ? @"dark" : @"light"];
    if (on) {
        [imageName appendString:@"_on"];
    }
    [imageName appendString:@".png"];
    return [UIImage imageNamed:imageName];
}

- (void)updateButtonWithLiked:(BOOL)liked {
    [self.likeButton setBackgroundImage:[CKLikeView buttonImageForOn:liked dark:self.dark] forState:UIControlStateNormal];
}

- (void)likedNotification:(NSNotification *)notification {
    if ([notification object] != self) {
        BOOL liked = [EventHelper likedForNotification:notification];
        self.liked = liked;
        [self updateButtonWithLiked:self.liked];
    }
}

@end
