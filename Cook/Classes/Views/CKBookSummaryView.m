//
//  CKBookUserSummaryView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 3/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookSummaryView.h"
#import "CKBook.h"
#import "CKUser.h"
#import "CKUserProfilePhotoView.h"
#import "Theme.h"
#import "CKStatView.h"

@interface CKBookSummaryView ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) CKStatView *friendsStatView;
@property (nonatomic, strong) CKStatView *recipesStatView;

@end

@implementation CKBookSummaryView

#define kSummarySize        CGSizeMake(320.0, 460.0)
#define kContentInsets      UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
#define kProfileNameGap     20.0
#define kInterStatsGap      30.0
#define kNameStatsGap       0.0
#define kStatsStoryGap      50.0

- (id)initWithBook:(CKBook *)book {
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, kSummarySize.width, kSummarySize.height)]) {
        self.book = book;
        self.backgroundColor = [UIColor clearColor];
        [self initViews];
        [self loadData];
    }
    return self;
}

#pragma mark - Private methods

- (void)initViews {
    
    CGSize availableSize = [self availableSize];
    
    // Top profile photo.
    UIImage *placeholderImage = self.book.featured ? [UIImage imageNamed:@"cook_featured_profileimage.png"] : nil;
    CKUserProfilePhotoView *profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user
                                                                                placeholder:placeholderImage
                                                                                profileSize:ProfileViewSizeLarge];
    profilePhotoView.frame = CGRectMake(floorf((self.bounds.size.width - profilePhotoView.frame.size.width) / 2.0),
                                        kContentInsets.top,
                                        profilePhotoView.frame.size.width,
                                        profilePhotoView.frame.size.height);
    [self addSubview:profilePhotoView];
    
    // User name
    NSString *name = [self.book.user.name uppercaseString];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.font = [Theme storeBookSummaryNameFont];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [Theme storeBookSummaryNameColour];
    nameLabel.shadowColor = [UIColor blackColor];
    nameLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    nameLabel.text = name;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [nameLabel sizeToFit];
    nameLabel.frame = CGRectMake(floorf((self.bounds.size.width - nameLabel.frame.size.width) / 2.0),
                                 profilePhotoView.frame.origin.y + profilePhotoView.frame.size.height + kProfileNameGap,
                                 nameLabel.frame.size.width,
                                 nameLabel.frame.size.height);
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    // Friends
    if (!self.book.featured) {
        CKStatView *friendsStatView = [[CKStatView alloc] initWithNumber:0 unit:@"FRIEND"];
        [self addSubview:friendsStatView];
        self.friendsStatView = friendsStatView;
    }
    
    // Recipes
    CKStatView *recipesStatView = [[CKStatView alloc] initWithNumber:0 unit:@"RECIPE"];
    [self addSubview:recipesStatView];
    self.recipesStatView = recipesStatView;
    
    // Update positioning of the stat views.
    [self updateStatViews];
    
    // Book story.
    UIEdgeInsets storyInsets = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    NSString *story = self.book.story;
    CGSize storySize = [story sizeWithFont:[Theme storeBookSummaryStoryFont]
                         constrainedToSize:CGSizeMake(availableSize.width - storyInsets.left - storyInsets.right,
                                                      availableSize.height - self.recipesStatView.frame.origin.y - self.recipesStatView.frame.size.height)
                             lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentInsets.left + storyInsets.left + floorf((availableSize.width - storyInsets.left - storyInsets.right - storySize.width) / 2.0),
                                                                    self.recipesStatView.frame.origin.y + kStatsStoryGap,
                                                                    storySize.width,
                                                                    storySize.height)];
    storyLabel.font = [Theme storeBookSummaryStoryFont];
    storyLabel.backgroundColor = [UIColor clearColor];
    storyLabel.textColor = [Theme storeBookSummaryStoryColour];
    storyLabel.shadowColor = [UIColor blackColor];
    storyLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    storyLabel.textAlignment = NSTextAlignmentCenter;
    storyLabel.text = story;
    storyLabel.numberOfLines = 0;
    storyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:storyLabel];
}

- (void)updateStatViews {
    CGFloat xOffset = self.friendsStatView ? kContentInsets.left : 0.0;
    CGSize availableSize = [self availableSize];
    CGFloat totalWidth = self.friendsStatView.frame.size.width + kInterStatsGap + self.recipesStatView.frame.size.width;
    CGRect friendsFrame = self.friendsStatView.frame;
    CGRect recipesFrame = self.recipesStatView.frame;
    friendsFrame.origin = CGPointMake(xOffset + floorf((availableSize.width - totalWidth) / 2.0),
                                      self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + kNameStatsGap);
    recipesFrame.origin = CGPointMake(friendsFrame.origin.x + friendsFrame.size.width + kInterStatsGap,
                                      self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + kNameStatsGap);
    self.friendsStatView.frame = friendsFrame;
    self.recipesStatView.frame = recipesFrame;
}

- (CGSize)availableSize {
    return CGSizeMake(self.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

- (void)loadData {
    
    // Load the number of friends.
    [self.book.user numFriendsCompletion:^(int numFriends) {
        [self.friendsStatView updateNumber:numFriends];
        [self updateStatViews];
    } failure:^(NSError *error) {
        // Ignore failure.
    }];
    
    // Load the number of recipes.
    [self.book numRecipesSuccess:^(int numRecipes) {
        [self.recipesStatView updateNumber:numRecipes];
        [self updateStatViews];
    } failure:^(NSError *error) {
        // Ignore failure.
    }];
}

@end
