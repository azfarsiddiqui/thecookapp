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
#import "EventHelper.h"
#import "CKEditingViewHelper.h"
#import "CKEditViewController.h"
#import "CKTextFieldEditViewController.h"
#import "CKTextViewEditViewController.h"
#import "CKButtonView.h"
#import "AnalyticsHelper.h"

@interface CKBookSummaryView () <CKPhotoPickerViewControllerDelegate, CKUserProfilePhotoViewDelegate,
    CKEditingTextBoxViewDelegate, CKEditViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UIImageView *profileOverlay;
@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *dividerView;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) UILabel *actionButtonCaptionLabel;
@property (nonatomic, strong) UILabel *signInLabel;
@property (nonatomic, strong) CKButtonView *actionButtonView;
@property (nonatomic, strong) CKStatView *followersStatView;
@property (nonatomic, strong) CKStatView *numRecipesStatView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKEditViewController *editViewController;
@property (nonatomic, assign) BOOL storeMode;
@property (nonatomic, assign) BOOL withinBook;
@property (nonatomic, assign) BOOL pendingAcceptance;

@property (nonatomic, strong) UIAlertView *friendRequestAlert;
@property (nonatomic, strong) UIAlertView *unfriendAlert;

// Data loaded from the server.
@property (nonatomic, assign) BOOL areFriends;
@property (nonatomic, assign) BOOL followed;
@property (nonatomic, assign) NSUInteger followCount;
@property (nonatomic, assign) NSUInteger recipeCount;
@property (nonatomic, assign) NSUInteger privateRecipesCount;
@property (nonatomic, assign) NSUInteger friendsRecipesCount;
@property (nonatomic, assign) NSUInteger publicRecipesCount;

@end

@implementation CKBookSummaryView

#define kSummaryStoreSize       (CGSize) { 320.0, 445.0 }
#define kSummarySize            (CGSize) { 320.0, 460.0 }
#define kContentInsets          (UIEdgeInsets) { 0.0, 20.0, 0.0, 20.0 }
#define kProfileNameGap         8.0
#define kInterStatsGap          10.0
#define kNameStatsGap           8.0
#define kStatsStoryGap          34.0
#define kActionCaptionFont      [UIFont fontWithName:@"BrandonGrotesque-Medium" size:14.0]
#define kActionSubCaptionFont  [UIFont fontWithName:@"BrandonGrotesque-Regular" size:12.0]

+ (CGSize)sizeForStoreMode:(BOOL)storeMode {
    return storeMode ? kSummaryStoreSize : kSummarySize;
}

- (id)initWithBook:(CKBook *)book {
    return [self initWithBook:book storeMode:NO];
}

- (id)initWithBook:(CKBook *)book storeMode:(BOOL)storeMode {
    return [self initWithBook:book storeMode:storeMode withinBook:YES];
}

- (id)initWithBook:(CKBook *)book storeMode:(BOOL)storeMode withinBook:(BOOL)withinBook {
    if (self = [super initWithFrame:(CGRect){ 0.0, 0.0, [CKBookSummaryView sizeForStoreMode:storeMode].width, [CKBookSummaryView sizeForStoreMode:storeMode].height }]) {
        self.book = book;
        self.storeMode = storeMode;
        self.withinBook = withinBook;
        self.backgroundColor = [UIColor clearColor];
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.currentUser = [CKUser currentUser];
        self.isDeleteCoverPhoto = NO;
        
        [self initViews];
        [self loadData];
    }
    return self;
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated {
    
    self.dividerView.alpha = editMode ? 0.0 : 1.0;
    self.profilePhotoView.delegate = editMode ? self : nil;
    
    if (editMode) {
        
        // If no data, then display placeholder text.
        if (![self.book.story CK_containsText]) {
            [self updateStory:[self defaultEditPlaceholderText]];
        }
        
        [self updateStoryEditMode:editMode];
        [self updateNameEditMode:editMode];
        
        UIEdgeInsets defaultInsets = [CKEditingViewHelper contentInsetsForEditMode:YES];
        
        // Wrap story up if it's not localised.
        if (![self.book summaryLocalised]) {
            [self.editingHelper wrapEditingView:self.storyLabel
                                  contentInsets:(UIEdgeInsets){
                                      defaultInsets.top + 5.0,
                                      defaultInsets.left,
                                      defaultInsets.bottom + 5.0,
                                      defaultInsets.right + 5.0
                                  } delegate:self white:YES];
        }
        
        // Wrap name up.
        if (![self.book titleLocalised]) {
            [self.editingHelper wrapEditingView:self.nameLabel
                                  contentInsets:(UIEdgeInsets){
                                      defaultInsets.top,
                                      defaultInsets.left,
                                      defaultInsets.bottom - 2.0,
                                      defaultInsets.right + 5.0
                                  } delegate:self white:YES];
        }
        
    } else {
        [self updateStoryEditMode:editMode];
        [self updateNameEditMode:editMode];
        [self.editingHelper unwrapEditingView:self.nameLabel];
        [self.editingHelper unwrapEditingView:self.storyLabel];
    }
    
    self.profileOverlay.alpha = editMode ? 0.0 : 1.0;
    [self.profilePhotoView enableEditMode:editMode animated:animated];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.nameLabel) {
        
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:YES
                                                                                                              title:nil
                                                                                                     characterLimit:20];
        editViewController.forceUppercase = YES;
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.storyLabel) {
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:self.storyLabel
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:nil
                                                                                                   characterLimit:500];
        editViewController.clearOnFocus = (![self.book.story CK_containsText] && ![self.updatedStory CK_containsText]);
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
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
    
    if (editingView == self.nameLabel) {
    
        NSString *name = (NSString *)value;
        if ([name CK_containsText]) {
            self.updatedName = name;
            [self updateName:name];
            [self updateNameEditMode:YES];
            [self.editingHelper updateEditingView:editingView];
        }

    } else if (editingView == self.storyLabel) {
        
        NSString *story = (NSString *)value;
        self.updatedStory = story;
        [self updateStory:[story CK_containsText] ? story : [self defaultEditPlaceholderText]];
        [self updateStoryEditMode:YES];
        [self.editingHelper updateEditingView:editingView];
    }
}

#pragma mark - CKPhotoPickerViewControllerDelegate methods

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image {
    [self showPhotoPicker:NO];
    
    UIImage *resizedImage = [ImageHelper scaledImage:image size:[ImageHelper profileSize]];
    
    [self.profilePhotoView loadProfileImage:resizedImage];
    
    // Save photo to be uploaded.
    self.updatedProfileImage = resizedImage;
}

- (void)photoPickerViewControllerCloseRequested {
    self.updatedProfileImage = nil;
    [self.profilePhotoView reloadProfilePhoto];
    [self showPhotoPicker:NO];
}

- (void)photoPickerViewControllerDeleteRequested {
    //Delete not enabled
}

#pragma mark - CKUserProfilePhotoViewDelegate methods

- (void)userProfilePhotoViewEditRequested {
    [self showPhotoPicker:YES];
}

#pragma mark - CKSaveableContent methods

- (BOOL)contentSaveRequired {
    return ((self.updatedProfileImage != nil) || ![self.updatedStory CK_equals:self.book.story]  || ![self.updatedName CK_equals:self.book.user.name]);
}

- (void)contentPerformSave:(BOOL)save {
    if (save) {
        
        // Save image if given.
        if (self.updatedProfileImage) {
            [[CKPhotoManager sharedInstance] addImage:self.updatedProfileImage user:self.book.user];
        }
        
        // Save story regardless user can choose to clear it.
        if (self.updatedStory) {
            
            [self updateStory:self.updatedStory];
            
            self.book.story = self.updatedStory;
        }
        
        if (self.isDeleteCoverPhoto)
        {
            self.book.coverPhotoFile = nil;
            self.book.coverPhotoThumbFile = nil;
        }
        
        if (self.updatedStory || self.isDeleteCoverPhoto)
        {
            [self.book saveInBackground:^{
                // Ignore success.
            } failure:^(NSError *error) {
                DLog(@"Unable to save story");
            }];
        }
        
        // Save name.
        if (self.updatedName) {
            
            [self updateName:self.updatedName];
            self.book.user.name = self.updatedName;
            [self.book.user saveInBackground:^{
                // Ignore success.
            } failure:^(NSError *error) {
                DLog(@"Unable to save name");
            }];
            
        }
        
        
    } else {
        
        // Clear any updated covers.
        self.updatedStory = nil;
        self.updatedName = nil;
        
        // Restore user profile.
        if (self.updatedProfileImage) {
            [self.profilePhotoView reloadProfilePhoto];
            self.updatedProfileImage = nil;
        }
        
        // Restore name.
        if (![self.updatedName CK_equals:self.book.user.name]) {
            [self updateName:self.book.user.name];
        }
        
        // Restore story.
        if (![self.updatedStory CK_equals:self.book.story]) {
            [self updateStory:self.book.story];
        }
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.friendRequestAlert && buttonIndex == 1) {
        
        // Send Button tapped on send.
        [self sendFriendRequest];
        
    } else if (alertView == self.unfriendAlert && buttonIndex == 1) {
        
        // Send button tapped on unfriend.
        [self sendUnfriendRequest];
    }
    
    // Clear alerts.
    self.friendRequestAlert = nil;
    self.unfriendAlert = nil;
}


#pragma mark - Private methods

- (void)initViews {
    
    // Top profile photo.
    UIImage *placeholderImage = self.book.featured ? [UIImage imageNamed:@"cook_featured_profileimage.png"] : nil;
    self.profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user
                                                             placeholder:placeholderImage
                                                             profileSize:ProfileViewSizeLarge border:NO overlay:YES];
    self.profilePhotoView.frame = CGRectMake(floorf((self.bounds.size.width - self.profilePhotoView.frame.size.width) / 2.0),
                                             kContentInsets.top,
                                             self.profilePhotoView.frame.size.width,
                                             self.profilePhotoView.frame.size.height);
    [self addSubview:self.profilePhotoView];
    
    // User name
    NSString *name = self.book.user.name;
    if ([self.book titleLocalised]) {
        name = [self.book userName];
    }
    [self updateName:name];
    
    // Downloads
    NSString *unitDisplay = self.book.featured ? NSLocalizedString(@"DOWNLOAD", nil) : NSLocalizedString(@"FOLLOWER", nil);
    NSString *pluralDisplay = self.book.featured ? NSLocalizedString(@"DOWNLOADS", nil) : NSLocalizedString(@"FOLLOWERS", nil);
    CKStatView *pagesStatView = [[CKStatView alloc] initWithUnitDisplay:unitDisplay pluralDisplay:pluralDisplay];
    [self addSubview:pagesStatView];
    self.followersStatView = pagesStatView;
    
    // Recipes
    CKStatView *recipesStatView = [[CKStatView alloc] initWithUnitDisplay:NSLocalizedString(@"RECIPE", nil)
                                                            pluralDisplay:NSLocalizedString(@"RECIPES", nil)];
    [self addSubview:recipesStatView];
    self.numRecipesStatView = recipesStatView;
    
    // Update positioning of the stat views.
    [self updateStatViews];
    
    // Divider.
    CGFloat hrWidth = self.nameLabel.frame.size.width * 0.8;
    UIImageView *dividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_library_selected_divider.png"]];
    dividerView.frame = (CGRect) {
        floorf((self.bounds.size.width - hrWidth) / 2.0),
        self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + (kNameStatsGap / 2.0) - 1.0,
        hrWidth,
        1.0
    };
    [self addSubview:dividerView];
    self.dividerView = dividerView;
    
    // Book story.
    [self updateStory:self.book.story];
    
    // Action button.
    if (self.storeMode && !self.book.featured && ![self.book.user isEqual:self.currentUser]) {
        [self initFriendsButton];
    }
    
    //Show Sign In label if Guest user
    if (self.currentUser == nil && self.storeMode && self.book.featured && self.book.status != kBookStatusFollowed
        && !self.withinBook) {
        [self addSubview:self.signInLabel];
    }
}

- (void)updateName:(NSString *)name {
    if (!self.nameLabel) {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.font = [Theme storeBookSummaryNameFont];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [Theme storeBookSummaryNameColour];
        self.nameLabel.shadowColor = [UIColor blackColor];
        self.nameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.nameLabel.numberOfLines = 1;
        self.nameLabel.minimumScaleFactor = 0.8;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.nameLabel];
    }
    
    UIEdgeInsets nameInsets = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    
    CGSize availableSize = [self availableSize];
    availableSize.width -= (nameInsets.left + nameInsets.right);
    self.nameLabel.text = [name uppercaseString];
    [self.nameLabel sizeToFit];
    
    CGFloat requiredWidth = (self.nameLabel.frame.size.width > availableSize.width) ? availableSize.width : self.nameLabel.frame.size.width;
    
    self.nameLabel.frame = (CGRect){
        floorf((self.bounds.size.width - requiredWidth) / 2.0),
        self.profilePhotoView.frame.origin.y + self.profilePhotoView.frame.size.height + kProfileNameGap,
        requiredWidth,
        self.nameLabel.frame.size.height
    };
}

- (void)updateStory:(NSString *)story {
    if (!self.storyLabel) {
        self.storyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.storyLabel.numberOfLines = 0;
        [self addSubview:self.storyLabel];
    }
    
    if ([story length] > 0) {
        self.storyLabel.hidden = NO;
        NSDictionary *paragraphAttributes = [self storyParagraphAttributes];
        UIEdgeInsets storyInsets = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
        NSAttributedString *storyDisplay = [[NSAttributedString alloc] initWithString:story attributes:paragraphAttributes];
        self.storyLabel.attributedText = storyDisplay;
        
        CGSize availableSize = [self availableSize];
        availableSize.height -= self.storeMode ? 54.0 : 0.0;    // Minus the button height in store mode.
        availableSize.width = availableSize.width - storyInsets.left - storyInsets.right;
        availableSize.height = availableSize.height - self.numRecipesStatView.frame.origin.y - self.numRecipesStatView.frame.size.height - kStatsStoryGap;
        
        CGRect storyFrame = [story boundingRectWithSize:availableSize
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:paragraphAttributes
                                                context:nil];
        self.storyLabel.frame = CGRectIntegral((CGRect) {
            kContentInsets.left + storyInsets.left + floorf((availableSize.width - storyFrame.size.width) / 2.0),
            self.numRecipesStatView.frame.origin.y + kStatsStoryGap,
            storyFrame.size.width,
            storyFrame.size.height
        });
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateStatViews {
    CGSize availableSize = [self availableSize];
    CGFloat totalWidth = self.followersStatView.frame.size.width + kInterStatsGap + self.numRecipesStatView.frame.size.width;
    CGRect pagesFrame = self.followersStatView.frame;
    CGRect recipesFrame = self.numRecipesStatView.frame;
    
    pagesFrame.origin = (CGPoint){
        kContentInsets.left + floorf((availableSize.width - totalWidth) / 2.0),
        self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + kNameStatsGap
    };
    recipesFrame.origin = (CGPoint){
        pagesFrame.origin.x + pagesFrame.size.width + kInterStatsGap,
        pagesFrame.origin.y
    };
    
    self.followersStatView.frame = pagesFrame;
    self.numRecipesStatView.frame = recipesFrame;
}

- (CGSize)availableSize {
    return CGSizeMake(self.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

- (void)loadData {
    
    // Load the book info stats.
    [self.book bookInfoCompletion:^(NSUInteger followCount, BOOL areFriends, BOOL followed, NSUInteger recipeCount,
                                    NSUInteger privateRecipesCount, NSUInteger friendsRecipesCount,
                                    NSUInteger publicRecipesCount) {
        
        self.followCount = followCount;
        self.areFriends = areFriends;
        self.followed = followed;
        self.recipeCount = recipeCount;
        self.privateRecipesCount = privateRecipesCount;
        self.friendsRecipesCount = friendsRecipesCount;
        self.publicRecipesCount = publicRecipesCount;
        
        [self updateViews];
        
    } failure:^(NSError *error) {
        
        // Inform delegate of book is locked for non-signed in users.
        if ([self.delegate respondsToSelector:@selector(bookSummaryViewBookIsPrivate)]) {
            [self.delegate bookSummaryViewBookIsPrivate];
        }

    }];
    
}

- (void)showPhotoPicker:(BOOL)show {
    if (show) {
        // Present photo picker fullscreen.
        UIView *rootView = [[AppHelper sharedInstance] rootView];
        CKPhotoPickerViewController *photoPickerViewController = [[CKPhotoPickerViewController alloc] initWithDelegate:self type:CKPhotoPickerImageTypeSquare editImage:nil];
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

- (NSString *)defaultEditPlaceholderText {
    return NSLocalizedString(@"YOUR BIO", nil);
}

- (NSDictionary *)storyParagraphAttributes {
    return [self storyParagraphAttributesEditMode:NO];
}

- (NSDictionary *)storyParagraphAttributesEditMode:(BOOL)editMode {
    
    // No edit mode for localised titles.
    if ([self.book summaryLocalised]) {
        editMode = NO;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = -10.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = editMode ? [UIColor clearColor] : [UIColor blackColor];
    shadow.shadowOffset = editMode ? CGSizeZero : CGSizeMake(0.0, 1.0);
    
    UIColor *textColour = editMode ? [Theme editPhotoColour] : [Theme storeBookSummaryStoryColour];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [Theme storeBookSummaryStoryFont], NSFontAttributeName,
            textColour, NSForegroundColorAttributeName,
            shadow, NSShadowAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

- (void)updateStoryEditMode:(BOOL)editMode {
    if ([self.storyLabel.text length] > 0) {
        NSAttributedString *storyDisplay = [[NSAttributedString alloc] initWithString:self.storyLabel.text
                                                                           attributes:[self storyParagraphAttributesEditMode:editMode]];
        self.storyLabel.attributedText = storyDisplay;
    }
}

- (void)updateNameEditMode:(BOOL)editMode {
    
    // No edit mode for localised titles.
    if ([self.book titleLocalised]) {
        editMode = NO;
    }
    self.nameLabel.textColor = editMode ? [Theme editPhotoColour] : [Theme storeBookSummaryNameColour];
    self.nameLabel.shadowColor = editMode ? [UIColor clearColor] : [UIColor blackColor];
    self.nameLabel.shadowOffset = editMode ? CGSizeZero : CGSizeMake(0.0, 1.0);
}

- (void)initFriendsButton {
    NSString *friendRequestText = NSLocalizedString(@"ADD FRIEND", nil);
    
    [self initActionButtonWithSelector:@selector(requestTapped:)];
    [self updateRequestButtonText:friendRequestText activity:YES enabled:NO];
    
    if (self.currentUser) {
        [self.currentUser checkIsFriendsWithUser:self.book.user
                                      completion:^(BOOL alreadySent, BOOL alreadyConnected, BOOL pendingAcceptance) {
                                          
                                          if (alreadyConnected) {
                                              
                                              [self updateButtonText:NSLocalizedString(@"FRIENDS", nil) activity:NO
                                                                icon:nil
                                                             enabled:YES target:self selector:@selector(unfriendTapped:)];
                                              
                                          } else if (pendingAcceptance) {
                                              self.pendingAcceptance = pendingAcceptance;
                                              [self updateButtonText:NSLocalizedString(@"ADD FRIEND", nil) activity:NO
                                                                icon:nil
                                                             enabled:YES target:nil selector:nil];
                                              
                                              self.actionButtonCaptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                                              self.actionButtonCaptionLabel.font = kActionSubCaptionFont;
                                              self.actionButtonCaptionLabel.textColor = [UIColor whiteColor];
                                              self.actionButtonCaptionLabel.text = [[NSString stringWithFormat:NSLocalizedString(@"%@ WANTS TO BE FRIENDS", nil), [self.book.user friendlyName]] uppercaseString];
                                              [self.actionButtonCaptionLabel sizeToFit];
                                              self.actionButtonCaptionLabel.frame = (CGRect){
                                                  floorf((self.bounds.size.width - self.actionButtonCaptionLabel.frame.size.width) / 2.0),
                                                  self.actionButtonView.frame.origin.y + self.actionButtonView.frame.size.height,
                                                  self.actionButtonCaptionLabel.frame.size.width,
                                                  self.actionButtonCaptionLabel.frame.size.height
                                              };
                                              [self addSubview:self.actionButtonCaptionLabel];
                                              
                                          } else if (alreadySent) {
                                              [self updateButtonText:NSLocalizedString(@"REQUESTED", nil) activity:NO
                                                                icon:nil
                                                             enabled:NO target:nil selector:nil];
                                          } else {
                                              [self updateRequestButtonText:friendRequestText activity:NO enabled:YES];
                                          }
                                      } failure:^(NSError *error) {
                                          [self updateRequestButtonText:friendRequestText activity:NO enabled:NO];
                                      }];
    } else {
        self.actionButtonView.hidden = YES;
    }
}

- (UILabel *)signInLabel {
    if (!_signInLabel) {
        _signInLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _signInLabel.font = kActionCaptionFont;
        _signInLabel.textColor = [UIColor whiteColor];
        _signInLabel.text = [NSLocalizedString(@"SIGN IN TO VIEW THIS BOOK", nil) uppercaseString];
        [_signInLabel sizeToFit];
        _signInLabel.frame = (CGRect){
            floorf((self.bounds.size.width - _signInLabel.frame.size.width) / 2.0),
            self.frame.size.height - _signInLabel.frame.size.height - 20,
            _signInLabel.frame.size.width,
            _signInLabel.frame.size.height
        };
    }
    return _signInLabel;
}

- (void)initActionButtonWithSelector:(SEL)selector {
    CKButtonView *actionButtonView = [[CKButtonView alloc] initWithTarget:self action:selector];
    actionButtonView.frame = CGRectMake(floorf((self.bounds.size.width - actionButtonView.frame.size.width) / 2.0),
                                        self.bounds.size.height - actionButtonView.frame.size.height,
                                        actionButtonView.frame.size.width,
                                        actionButtonView.frame.size.height);
    [self addSubview:actionButtonView];
    self.actionButtonView = actionButtonView;
}

- (void)updateAddButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled {
    
    [self updateAddButtonText:text activity:activity enabled:enabled target:nil selector:nil];
}

- (void)updateAddButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled target:(id)target selector:(SEL)selector {
    UIImage *iconImage = [UIImage imageNamed:@"cook_dash_library_selected_icon_addtodash.png"];
    [self updateButtonText:text activity:activity icon:iconImage enabled:enabled target:target selector:selector];
}

- (void)updateRequestButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled {
    [self updateButtonText:text activity:activity icon:nil enabled:enabled target:nil selector:nil];
}

- (void)updateButtonText:(NSString *)text activity:(BOOL)activity icon:(UIImage *)iconImage enabled:(BOOL)enabled
                  target:(id)target selector:(SEL)selector {
    
    [self.actionButtonView setText:[text uppercaseString] activity:activity icon:iconImage enabled:enabled
                            target:target selector:selector];
}

- (void)requestTapped:(id)sender {
    [self.actionButtonCaptionLabel removeFromSuperview];
    
    if (self.pendingAcceptance) {
        [self sendFriendRequest];
    } else {
        self.friendRequestAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Send Friend Request?", nil)
                                                             message:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   otherButtonTitles:[NSLocalizedString(@"SEND", nil) capitalizedString], nil];
        [self.friendRequestAlert show];
    }
}

- (void)unfriendTapped:(id)sender {
    [self.actionButtonCaptionLabel removeFromSuperview];
    self.unfriendAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove Friend?", nil)
                                                    message:nil delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Remove", nil), nil];
    [self.unfriendAlert show];
}

- (void)addTapped:(id)sender {
    [self updateAddButtonText:NSLocalizedString(@"ADD TO BENCH", nil) activity:YES enabled:NO];
    
    // Weak reference so we don't have retain cycles.
    __weak typeof(self) weakSelf = self;
    [self.book addFollower:self.currentUser
                   success:^{
                       [AnalyticsHelper trackEventName:kEventBookAdd params:nil];
                       
                       [weakSelf updateButtonText:NSLocalizedString(@"BOOK ON BENCH", nil) activity:NO
                                             icon:[UIImage imageNamed:@"cook_dash_library_selected_icon_added.png"]
                                          enabled:NO target:nil selector:nil];
                       
                       [EventHelper postFollow:YES book:weakSelf.book];
                       
                       // Inform delegate that book has been followed/updated.
                       if ([weakSelf.delegate respondsToSelector:@selector(bookSummaryViewBookFollowed)]) {
                           [weakSelf.delegate bookSummaryViewBookFollowed];
                       }
                       
                   }
                   failure:^(NSError *error) {
                       [weakSelf updateAddButtonText:NSLocalizedString(@"UNABLE TO ADD", nil) activity:NO enabled:NO];
                   }];
}

- (void)sendFriendRequest {
    if (self.pendingAcceptance) {
        [self updateRequestButtonText:NSLocalizedString(@"ACCEPTING", nil) activity:YES enabled:NO];
    } else {
        [self updateRequestButtonText:NSLocalizedString(@"SENDING", nil) activity:YES enabled:NO];
    }
    
    [self.currentUser requestFriend:self.book.user
                         completion:^{
                             if (self.pendingAcceptance) {
                                 
                                 // Mark as friends now.
                                 self.areFriends = YES;
                                 [self updateViews];
                                 
                                 [self updateButtonText:NSLocalizedString(@"FRIENDS", nil) activity:NO
                                                   icon:nil
                                                enabled:NO target:nil selector:nil];
                             } else {
                                 [self updateButtonText:NSLocalizedString(@"REQUESTED", nil) activity:NO
                                                   icon:nil
                                                enabled:NO target:nil selector:nil];
                             }
                             
                             // Inform delegate that book has been followed/updated.
                             if ([self.delegate respondsToSelector:@selector(bookSummaryViewUserFriendActioned)]) {
                                 [self.delegate bookSummaryViewUserFriendActioned];
                             }
                             
                         }
                            failure:^(NSError *error) {
                                [self updateButtonText:NSLocalizedString(@"UNABLE TO SEND", nil)
                                              activity:NO icon:nil enabled:NO target:nil selector:nil];
                            }];
}

- (void)sendUnfriendRequest {
    [self updateRequestButtonText:@"REMOVING" activity:YES enabled:NO];
    
    [self.currentUser ignoreRemoveFriendRequestFrom:self.book.user
                                         completion:^{
                                             
                                             // Mark as not friends anymore.
                                             self.areFriends = NO;
                                             [self updateViews];
                                             
                                             [self updateButtonText:NSLocalizedString(@"ADD FRIEND", nil) activity:NO
                                                               icon:nil
                                                            enabled:YES target:self selector:@selector(requestTapped:)];
                                             
                                             // Inform delegate that book has been followed/updated.
                                             if ([self.delegate respondsToSelector:@selector(bookSummaryViewUserFriendActioned)]) {
                                                 [self.delegate bookSummaryViewUserFriendActioned];
                                             }
                                             
                                         } failure:^(NSError *error) {
                                             
                                             [self updateButtonText:NSLocalizedString(@"UNABLE TO REMOVE", nil)
                                                           activity:NO icon:nil enabled:NO target:nil selector:nil];
                                         }];
}

- (void)updateViews {
    
    [self.followersStatView updateNumber:self.followCount];
    [self.numRecipesStatView updateNumber:[self currentRecipeCount]];
    
    [self updateStatViews];
    
    if (![self.currentUser isSignedIn] || self.book.disabled) {
        
        // Inform delegate of book is locked for non-signed in users.
        if ([self.delegate respondsToSelector:@selector(bookSummaryViewBookIsPrivate)]) {
            [self.delegate bookSummaryViewBookIsPrivate];
        }
        
    } else if (self.followed) {
        
        // Book is followed.
        if ([self.delegate respondsToSelector:@selector(bookSummaryViewBookIsFollowed)]) {
            [self.delegate bookSummaryViewBookIsFollowed];
        }
        
    } else if (self.book.featured || self.areFriends || self.publicRecipesCount > 0) {
        
        // Feature and friends' books are always available to download. So are books that have more than zero public
        // recipes.
        if ([self.delegate respondsToSelector:@selector(bookSummaryViewBookIsDownloadable)]) {
            [self.delegate bookSummaryViewBookIsDownloadable];
        }
        
    } else {
        
        // Inform delegate of book is private
        if ([self.delegate respondsToSelector:@selector(bookSummaryViewBookIsPrivate)]) {
            
            // Private if not friends and no public recipes.
            [self.delegate bookSummaryViewBookIsPrivate];
        }
        
    }
}

- (NSUInteger)currentRecipeCount {
    return self.recipeCount;
}

@end
