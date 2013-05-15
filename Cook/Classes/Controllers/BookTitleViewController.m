//
//  BookTitleViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleViewController.h"
#import "CKBook.h"
#import "Theme.h"
#import "CKMaskedLabel.h"
#import "CKUserProfilePhotoView.h"
#import "ParsePhotoStore.h"
#import "CKRecipe.h"
#import "CKUser.h"
#import "ImageHelper.h"

@interface BookTitleViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *heroRecipe;
@property (nonatomic, assign) id<BookTitleViewControllerDelegate> delegate;

@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKMaskedLabel *maskedLabel;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;

@end

@implementation BookTitleViewController

#define kTitleInsets    UIEdgeInsetsMake(40.0, 40.0, 28.0, 40.0)
#define kTitleNameGap   0.0

- (id)initWithBook:(CKBook *)book delegate:(id<BookTitleViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initBackgroundImageView];
    [self initTitleView];
    [self initShadowViews];
    //[self initActivities];
}

- (void)configureHeroRecipe:(CKRecipe *)recipe {
    
    // Only set the hero recipe once.
    if (self.heroRecipe) {
        return;
    }
    
    self.heroRecipe = recipe;
    [self.photoStore imageForParseFile:[recipe imageFile]
                                  size:self.imageView.bounds.size
                            completion:^(UIImage *image) {
                                [ImageHelper configureImageView:self.imageView image:image];
                            }];
}

#pragma mark - Private methods

- (void)initBackgroundImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.backgroundColor = [Theme categoryHeaderBackgroundColour];
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)initTitleView {
    
    // Masked label.
    NSString *bookAuthor = [self.book.user.name uppercaseString];
    NSString *bookTitle = [NSString stringWithFormat:@"%@\u2028%@",[self.book.name uppercaseString], bookAuthor];
    NSAttributedString *titleDisplay = [self attributedTextForTitle:bookTitle titleFont:[Theme bookContentsTitleFont]
                                                             author:bookAuthor authorFont:[Theme bookContentsNameFont]];

    CKMaskedLabel *maskedLabel = [[CKMaskedLabel alloc] initWithFrame:CGRectZero];
    maskedLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    maskedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    maskedLabel.numberOfLines = 2;
    maskedLabel.font = [Theme bookContentsTitleFont];
    maskedLabel.insets = kTitleInsets;
    maskedLabel.attributedText = titleDisplay;
    [self.view addSubview:maskedLabel];
    self.maskedLabel = maskedLabel;
    
    // Figure out the required size with padding.
    CGSize availableSize = CGSizeMake(self.view.bounds.size.width - kTitleInsets.left - kTitleInsets.right,
                                      self.view.bounds.size.height);
    CGSize size = [self.maskedLabel sizeThatFits:availableSize];
    size.width += kTitleInsets.left + kTitleInsets.right;
    size.height += kTitleInsets.top + kTitleInsets.bottom;
    
    // Bump down font if exceeds maximum width.
    if (size.width >= availableSize.width) {
        titleDisplay = [self attributedTextForTitle:bookTitle titleFont:[Theme bookContentsTitleFont]
                                             author:bookAuthor authorFont:[Theme bookContentsNameFont]];
        maskedLabel.attributedText = titleDisplay;
        size = [maskedLabel sizeThatFits:availableSize];
        size.width += kTitleInsets.left + kTitleInsets.right;
        size.height += kTitleInsets.top + kTitleInsets.bottom;
    }
    
    // Now position the frame.
    maskedLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                   floorf((self.view.bounds.size.height - size.height) / 2.0),
                                   size.width,
                                   size.height);
    
    // Black overlay under the label.
    UIView *overlayView = [[UIView alloc] initWithFrame:maskedLabel.frame];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.3;
    [self.view insertSubview:overlayView belowSubview:maskedLabel];
    self.overlayView = overlayView;
    
    // Profile photo view.
    CKUserProfilePhotoView *profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user
                                                                                profileSize:ProfileViewSizeMedium
                                                                                     border:YES];
    profilePhotoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    profilePhotoView.frame = CGRectMake(maskedLabel.frame.origin.x + floorf((maskedLabel.frame.size.width - profilePhotoView.frame.size.width) / 2.0),
                                        maskedLabel.frame.origin.y - floorf(profilePhotoView.frame.size.height / 2.0),
                                        profilePhotoView.frame.size.width,
                                        profilePhotoView.frame.size.height);
    [self.view addSubview:profilePhotoView];
    self.profilePhotoView = profilePhotoView;
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = -10.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

- (NSMutableAttributedString *)attributedTextForTitle:(NSString *)bookTitle titleFont:(UIFont *)titleFont
                                               author:(NSString *)author authorFont:(UIFont *)authorFont {
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:titleFont];
    NSMutableAttributedString *titleDisplay = [[NSMutableAttributedString alloc] initWithString:bookTitle attributes:paragraphAttributes];
    [titleDisplay addAttribute:NSFontAttributeName
                         value:authorFont
                         range:NSMakeRange([bookTitle length] - [author length],
                                           [author length])];
    return titleDisplay;
}

- (void)initShadowViews {
    
    // Top shadow view.
    UIImageView *headerShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_update_header_shadow.png"]];
    headerShadowImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                             self.view.bounds.origin.y,
                                             headerShadowImageView.frame.size.width,
                                             headerShadowImageView.frame.size.height);
    headerShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:headerShadowImageView];
    
    // Bottom shadow view.
    UIImageView *footerShadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_update_header_shadow_bottom.png"]];
    footerShadowImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                             self.view.bounds.size.height - footerShadowImageView.frame.size.height,
                                             footerShadowImageView.frame.size.width,
                                             footerShadowImageView.frame.size.height);
    footerShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:footerShadowImageView];
}

- (void)initActivities {
    CGFloat yOffset = 8.0;
    UIImage *tempImage = [UIImage imageNamed:@"cook_temp_featuredrecipes.png"];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:tempImage];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                              self.view.bounds.size.height - tempImageView.frame.size.height - yOffset,
                                                                              self.view.bounds.size.width,
                                                                              tempImageView.frame.size.height)];
    tempImageView.frame = CGRectMake(floorf((scrollView.bounds.size.width - tempImageView.frame.size.width) / 2.0),
                                     scrollView.bounds.origin.y,
                                     tempImageView.frame.size.width,
                                     tempImageView.frame.size.height);
    scrollView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:tempImageView];
    [self.view addSubview:scrollView];
    
    // Shift everything else up.
    CGFloat shiftOffset = scrollView.frame.size.height + yOffset;
    CGAffineTransform shiftTransform = CGAffineTransformMakeTranslation(0.0, -55.0);
    scrollView.transform = CGAffineTransformMakeTranslation(0.0, shiftOffset);;
    
    [UIView animateWithDuration:0.4
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         scrollView.transform = CGAffineTransformIdentity;
                         self.maskedLabel.transform = shiftTransform;
                         self.overlayView.transform = shiftTransform;
                         self.profilePhotoView.transform = shiftTransform;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

@end
