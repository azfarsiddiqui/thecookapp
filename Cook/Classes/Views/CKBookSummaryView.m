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
#import "CKPhotoPickerViewController.h"
#import "AppHelper.h"
#import "ImageHelper.h"
#import "NSString+Utilities.h"
#import "CKPhotoManager.h"
#import "CKEditingViewHelper.h"
#import "CKEditViewController.h"
#import "CKTextViewEditViewController.h"

@interface CKBookSummaryView () <CKPhotoPickerViewControllerDelegate, CKUserProfilePhotoViewDelegate,
    CKEditingTextBoxViewDelegate, CKEditViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) CKStatView *friendsStatView;
@property (nonatomic, strong) CKStatView *recipesStatView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKEditViewController *editViewController;

@end

@implementation CKBookSummaryView

#define kSummarySize        CGSizeMake(320.0, 460.0)
#define kContentInsets      UIEdgeInsetsMake(70.0, 20.0, 20.0, 20.0)
#define kProfileNameGap     20.0
#define kInterStatsGap      30.0
#define kNameStatsGap       0.0
#define kStatsStoryGap      50.0

- (id)initWithBook:(CKBook *)book {
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, kSummarySize.width, kSummarySize.height)]) {
        self.book = book;
        self.backgroundColor = [UIColor clearColor];
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        [self initViews];
        [self loadData];
    }
    return self;
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated {
    if (editMode) {
        [self.editingHelper wrapEditingView:self.storyLabel delegate:self white:NO];
    } else {
        [self.editingHelper unwrapEditingView:self.storyLabel];
    }
    [self.profilePhotoView enableEditMode:editMode animated:animated];
}

#pragma mark CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.storyLabel) {
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:editingView
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:@"Story"
                                                                                                   characterLimit:500];
//        editViewController.clearOnFocus = ![self.recipeDetails hasStory];
        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
    }
}

- (void)editingTextBoxViewSaveTappedForEditingView:(UIView *)editingView {
    DLog();
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
    if ([self.delegate respondsToSelector:@selector(bookSummaryViewEditing:)]) {
        [self.delegate bookSummaryViewEditing:appear];
    }
}

- (void)editViewControllerDidAppear:(BOOL)appear {
}

- (void)editViewControllerDismissRequested {
    [self.editViewController performEditing:NO];
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
    DLog();
}

#pragma mark - CKPhotoPickerViewControllerDelegate methods

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image {
    [self showPhotoPicker:NO];
    
    // Present the image.
    UIImage *scaledImage = [ImageHelper scaledImage:image size:[ImageHelper thumbSize]];
    [self.profilePhotoView loadProfileImage:scaledImage];
    
    // Save photo to be uploaded.
    self.updatedProfileImage = scaledImage;
}

- (void)photoPickerViewControllerCloseRequested {
    self.updatedProfileImage = nil;
    [self.profilePhotoView reloadProfilePhoto];
    [self showPhotoPicker:NO];
}

#pragma mark - CKUserProfilePhotoViewDelegate methods

- (void)userProfilePhotoViewEditRequested {
    [self showPhotoPicker:YES];
}

#pragma mark - CKSaveableContent methods

- (BOOL)contentSaveRequired {
    return ((self.updatedProfileImage != nil) && (![self.updatedStory CK_equals:self.book.story]));
}

- (void)contentPerformSave:(BOOL)save {
    if (save) {
        
        // Save image if given.
        if (self.updatedProfileImage) {
            [[CKPhotoManager sharedInstance] addImage:self.updatedProfileImage user:self.book.user];
        }
        
        // Save story regardless user can choose to clear it.
        self.book.story = self.updatedStory;
        [self.book saveInBackground];
        
    } else {
        
        // Restore user profile.
        if (self.updatedProfileImage) {
            [self.profilePhotoView reloadProfilePhoto];
        }
        
        // Restore story.
        if (![self.updatedStory CK_equals:self.book.story]) {
            [self updateStory:self.book.story];
        }
    }
}

#pragma mark - Private methods

- (void)initViews {
    
    // Top profile photo.
    UIImage *placeholderImage = self.book.featured ? [UIImage imageNamed:@"cook_featured_profileimage.png"] : nil;
    self.profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user
                                                             placeholder:placeholderImage
                                                             profileSize:ProfileViewSizeLarge];
    self.profilePhotoView.frame = CGRectMake(floorf((self.bounds.size.width - self.profilePhotoView.frame.size.width) / 2.0),
                                             kContentInsets.top,
                                             self.profilePhotoView.frame.size.width,
                                             self.profilePhotoView.frame.size.height);
    if ([self.book isOwner]) {
        self.profilePhotoView.delegate = self;
    }
    [self addSubview:self.profilePhotoView];
    
    // Can edit?
    
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
                                 self.profilePhotoView.frame.origin.y + self.profilePhotoView.frame.size.height + kProfileNameGap,
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
    [self updateStory:self.book.story];
}

- (void)updateStory:(NSString *)story {
    if (!self.storyLabel) {
        self.storyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.storyLabel.font = [Theme storeBookSummaryStoryFont];
        self.storyLabel.backgroundColor = [UIColor clearColor];
        self.storyLabel.textColor = [Theme storeBookSummaryStoryColour];
        self.storyLabel.shadowColor = [UIColor blackColor];
        self.storyLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        self.storyLabel.textAlignment = NSTextAlignmentCenter;
        self.storyLabel.numberOfLines = 0;
        self.storyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.storyLabel];
    }
    
    UIEdgeInsets storyInsets = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    self.storyLabel.text = story;
    
    CGSize availableSize = [self availableSize];
    availableSize.width = availableSize.width - storyInsets.left - storyInsets.right;
    availableSize.height = availableSize.height - self.recipesStatView.frame.origin.y - self.recipesStatView.frame.size.height - kStatsStoryGap;
    CGSize storySize = [self.storyLabel sizeThatFits:availableSize];
    self.storyLabel.frame = (CGRect) {
        kContentInsets.left + storyInsets.left + floorf((availableSize.width - storySize.width) / 2.0),
        self.recipesStatView.frame.origin.y + kStatsStoryGap,
        storySize.width,
        storySize.height
    };
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

- (void)showPhotoPicker:(BOOL)show {
    if (show) {
        // Present photo picker fullscreen.
        UIView *rootView = [[AppHelper sharedInstance] rootView];
        CKPhotoPickerViewController *photoPickerViewController = [[CKPhotoPickerViewController alloc] initWithDelegate:self];
        self.photoPickerViewController = photoPickerViewController;
        self.photoPickerViewController.view.alpha = 0.0;
        [rootView addSubview:self.photoPickerViewController.view];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.photoPickerViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [self cleanupPhotoPicker];
                         }
                     }];
}

- (void)cleanupPhotoPicker {
    [self.photoPickerViewController.view removeFromSuperview];
    self.photoPickerViewController = nil;
}

@end
