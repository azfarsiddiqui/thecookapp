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

@interface CKLikeView ()

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, weak) id<CKLikeViewDelegate> delegate;
@property (nonatomic, assign) BOOL dark;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, strong) UIButton *likeButton;

@end

@implementation CKLikeView

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<CKLikeViewDelegate>)delegate {
    return [self initWithRecipe:recipe darkMode:NO delegate:delegate];
}

- (id)initWithRecipe:(CKRecipe *)recipe darkMode:(BOOL)dark delegate:(id<CKLikeViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.recipe = recipe;
        self.delegate = delegate;
        self.dark = dark;
        self.backgroundColor = [UIColor clearColor];
        
        self.likeButton = [ViewHelper buttonWithImage:[self buttonImageForOn:NO] target:self selector:@selector(tapped:)];
        self.likeButton.enabled = NO;
        self.frame = self.likeButton.frame;
        [self addSubview:self.likeButton];
        
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
                      self.likeButton.enabled = YES;
                      [self updateButtonWithLiked:liked];
                  } failure:^(NSError *error) {
                      self.likeButton.enabled = NO;
                  }];
    
}


- (void)tapped:(id)sender {
    [self like:!self.liked];
}

- (void)like:(BOOL)like {
    
    // Tentative liked state and disable interaction.
    [self updateButtonWithLiked:like];
    self.likeButton.enabled = NO;
    [self.delegate likeViewLiked:like];
    
    // Like via the server.
    [self.recipe like:like
                 user:[CKUser currentUser]
           completion:^{
               self.liked = like;
               self.likeButton.enabled = YES;
           } failure:^(NSError *error) {
               
               // Revert the liked state.
               self.liked = !like;
               self.likeButton.enabled = YES;
               [self updateButtonWithLiked:self.liked];
               [self.delegate likeViewLiked:self.liked];
           }];
}

- (UIImage *)buttonImageForOn:(BOOL)on {
    NSMutableString *imageName = [NSMutableString stringWithFormat:@"cook_book_inner_icon_like_%@", self.dark ? @"dark" : @"light"];
    if (on) {
        [imageName appendString:@"_on"];
    }
    [imageName appendString:@".png"];
    return [UIImage imageNamed:imageName];
}

- (void)updateButtonWithLiked:(BOOL)liked {
    [self.likeButton setBackgroundImage:[self buttonImageForOn:liked] forState:UIControlStateNormal];
}

@end
