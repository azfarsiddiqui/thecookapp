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
#import "CKTextFieldEditViewController.h"
#import "CKTextViewEditViewController.h"

@interface CKBookSummaryView () <CKPhotoPickerViewControllerDelegate, CKUserProfilePhotoViewDelegate,
    CKEditingTextBoxViewDelegate, CKEditViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UIImageView *profileOverlay;
@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *dividerView;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) CKStatView *pagesStatView;
@property (nonatomic, strong) CKStatView *recipesStatView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKEditViewController *editViewController;
@property (nonatomic, assign) BOOL storeMode;

@end

@implementation CKBookSummaryView

#define kSummaryStoreSize   (CGSize) { 320.0, 445.0 }
#define kSummarySize        (CGSize) { 320.0, 460.0 }
#define kContentInsets      (UIEdgeInsets) { 0.0, 20.0, 0.0, 20.0 }
#define kProfileNameGap     8.0
#define kInterStatsGap      10.0
#define kNameStatsGap       8.0
#define kStatsStoryGap      34.0

+ (CGSize)sizeForStoreMode:(BOOL)storeMode {
    return storeMode ? kSummaryStoreSize : kSummarySize;
}

- (id)initWithBook:(CKBook *)book {
    return [self initWithBook:book storeMode:NO];
}

- (id)initWithBook:(CKBook *)book storeMode:(BOOL)storeMode {
    if (self = [super initWithFrame:(CGRect){ 0.0, 0.0, [CKBookSummaryView sizeForStoreMode:storeMode].width, [CKBookSummaryView sizeForStoreMode:storeMode].height }]) {
        self.book = book;
        self.storeMode = storeMode;
        self.backgroundColor = [UIColor clearColor];
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        
        [self initViews];
        [self loadData];
    }
    return self;
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated {
    
    self.dividerView.alpha = editMode ? 0.0 : 1.0;
    
    if (editMode) {
        
        // If no data, then display placeholder text.
        if (![self.book.story CK_containsText]) {
            [self updateStory:[self defaultEditPlaceholderText]];
        }
        
        [self updateStoryEditMode:editMode];
        [self updateNameEditMode:editMode];
        
        UIEdgeInsets defaultInsets = [CKEditingViewHelper contentInsetsForEditMode:YES];
        // Wrap story up.
        [self.editingHelper wrapEditingView:self.storyLabel
                              contentInsets:(UIEdgeInsets){
                                  defaultInsets.top + 5.0,
                                  defaultInsets.left,
                                  defaultInsets.bottom + 5.0,
                                  defaultInsets.right + 5.0
                              } delegate:self white:YES];
        
        // Wrap name up.
        [self.editingHelper wrapEditingView:self.nameLabel
                              contentInsets:(UIEdgeInsets){
                                  defaultInsets.top,
                                  defaultInsets.left,
                                  defaultInsets.bottom - 2.0,
                                  defaultInsets.right + 5.0
                              } delegate:self white:YES];
        
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
                                                                                                              title:@"Name"
                                                                                                     characterLimit:20];
        editViewController.forceUppercase = YES;
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.storyLabel) {
        
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:editingView
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:@"Story"
                                                                                                   characterLimit:500];
        editViewController.clearOnFocus = ![self.book.story CK_containsText];
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
    if ([self.book isOwner]) {
        self.profilePhotoView.delegate = self;
    }
    [self addSubview:self.profilePhotoView];
    
    // User name
    NSString *name = [self.book.user.name uppercaseString];
    [self updateName:name];
    
    // Pages
    CKStatView *pagesStatView = [[CKStatView alloc] initWithNumber:[self.book.pages count] unit:@"PAGE"];
    [self addSubview:pagesStatView];
    self.pagesStatView = pagesStatView;
    
    // Recipes
    CKStatView *recipesStatView = [[CKStatView alloc] initWithNumber:0 unit:@"RECIPE"];
    [self addSubview:recipesStatView];
    self.recipesStatView = recipesStatView;
    
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
        availableSize.height = availableSize.height - self.recipesStatView.frame.origin.y - self.recipesStatView.frame.size.height - kStatsStoryGap;
        
        CGRect storyFrame = [story boundingRectWithSize:availableSize
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:paragraphAttributes
                                                context:nil];
        self.storyLabel.frame = (CGRect) {
            kContentInsets.left + storyInsets.left + floorf((availableSize.width - storyFrame.size.width) / 2.0),
            self.recipesStatView.frame.origin.y + kStatsStoryGap,
            storyFrame.size.width,
            storyFrame.size.height
        };
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateStatViews {
    CGSize availableSize = [self availableSize];
    CGFloat totalWidth = self.pagesStatView.frame.size.width + kInterStatsGap + self.recipesStatView.frame.size.width;
    CGRect pagesFrame = self.pagesStatView.frame;
    CGRect recipesFrame = self.recipesStatView.frame;
    
    pagesFrame.origin = (CGPoint){
        kContentInsets.left + floorf((availableSize.width - totalWidth) / 2.0),
        self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + kNameStatsGap
    };
    recipesFrame.origin = (CGPoint){
        pagesFrame.origin.x + pagesFrame.size.width + kInterStatsGap,
        pagesFrame.origin.y
    };
    
    self.pagesStatView.frame = pagesFrame;
    self.recipesStatView.frame = recipesFrame;
}

- (CGSize)availableSize {
    return CGSizeMake(self.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

- (void)loadData {
    
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
        CKPhotoPickerViewController *photoPickerViewController = [[CKPhotoPickerViewController alloc] initWithDelegate:self type:CKPhotoPickerImageTypeSquare];
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
    return @"YOUR BIO";
}

- (NSDictionary *)storyParagraphAttributes {
    return [self storyParagraphAttributesEditMode:NO];
}

- (NSDictionary *)storyParagraphAttributesEditMode:(BOOL)editMode {
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
    self.nameLabel.textColor = editMode ? [Theme editPhotoColour] : [Theme storeBookSummaryNameColour];
    self.nameLabel.shadowColor = editMode ? [UIColor clearColor] : [UIColor blackColor];
    self.nameLabel.shadowOffset = editMode ? CGSizeZero : CGSizeMake(0.0, 1.0);
}

@end
