//
//  CKBookTitleIndexView.m
//  CKBookTitleIndexView
//
//  Created by Jeff Tan-Ang on 3/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookTitleIndexView.h"
#import "CKBook.h"
#import "CKUser.h"
#import "CKUserProfilePhotoView.h"

@interface CKBookTitleIndexView ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UIImageView *boxImageView;
@property (nonatomic, strong) UIView *labelContainerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CKBookTitleIndexView

#define kMaxSize        CGSizeMake(480.0, 208.0)
#define kLabelGap       -15.0
#define kLabelInsets    UIEdgeInsetsMake(-5.0, 20.0, 20.0, 20.0)
#define kContentInsets  UIEdgeInsetsMake(18.0, 18.0, 19.0, 16.0)

- (id)initWithBook:(CKBook *)book {
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, kMaxSize.width, kMaxSize.height)]) {
        self.book = book;
        self.name = [book.user.name uppercaseString];
        self.title = [book.name uppercaseString];
        
        [self initLabels];
        [self insertSubview:self.boxImageView belowSubview:self.labelContainerView];
        
        // Profile photo view.
        self.profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user profileSize:ProfileViewSizeLarge];
        self.profilePhotoView.frame = (CGRect){
            floorf((self.bounds.size.width - self.profilePhotoView.frame.size.width) / 2.0),
            -40.0,
            self.profilePhotoView.frame.size.width,
            self.profilePhotoView.frame.size.height
        };
        [self addSubview:self.profilePhotoView];
        
        // Profile photo frame.
        UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_title_profile_overlay.png"]];
        frameImageView.frame = (CGRect){
            floorf((self.profilePhotoView.bounds.size.width - frameImageView.frame.size.width) / 2.0),
            -5.0,
            frameImageView.frame.size.width,
            frameImageView.frame.size.height
        };
        [self.profilePhotoView addSubview:frameImageView];
        
    }
    return self;
}

- (void)setWidthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio labelRatio:(CGFloat)labelRatio {
    
    // Don't do scale up.
    if (widthRatio > 1.0 || heightRatio > 1.0 || labelRatio > 1.0) {
        return;
    }
    
    // Figure out min size to fit everything in.
    CGSize minSize = (CGSize){
        kContentInsets.left + self.labelContainerView.frame.size.width * labelRatio + kContentInsets.right,
        kContentInsets.top + self.labelContainerView.frame.size.height * labelRatio + kContentInsets.bottom
    };
    
    CGSize proposedSize = (CGSize){
        minSize.width < kMaxSize.width ? kMaxSize.width : minSize.width,
        minSize.height < kMaxSize.height ? kMaxSize.height : minSize.height
    };
    
    // Update self
    self.frame = (CGRect){
        0.0,
        0.0,
        proposedSize.width,
        proposedSize.height
    };
    
//    // Adjust the frame.
//    CGRect frame = self.frame;
//    CGFloat proposedWidth = widthRatio * kMaxSize.width;
//    CGFloat proposedHeight = heightRatio * kMaxSize.height;
//    proposedWidth = proposedWidth < minSize.width ? minSize.width : proposedWidth;
//    proposedHeight = proposedHeight < minSize.height ? minSize.height : proposedHeight;
//    frame.size.width = proposedWidth;
//    frame.size.height = proposedHeight;
//    self.frame = frame;
    
    // Scale the label container.
    self.labelContainerView.transform = (labelRatio == 1.0) ? CGAffineTransformIdentity : CGAffineTransformMakeScale(labelRatio, labelRatio);
}

#pragma mark - Property overrides

- (UIImageView *)boxImageView {
    if (!_boxImageView) {
        UIImage *boxImage = [[UIImage imageNamed:@"cook_book_titlebox.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(24.0, 29.0, 24.0, 29.0)];
        _boxImageView = [[UIImageView alloc] initWithImage:boxImage];
        _boxImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _boxImageView.frame = self.bounds;
    }
    return _boxImageView;
}

#pragma mark - Private methods

- (void)initLabels {
    
    // Name label.
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:46.0];
    nameLabel.numberOfLines = 1;
    nameLabel.text = self.name;
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [nameLabel sizeToFit];
    
    // Title label.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Light" size:30.0];
    titleLabel.numberOfLines = 1;
    titleLabel.text = self.title;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [titleLabel sizeToFit];
    titleLabel.frame = (CGRect){
        0.0, nameLabel.frame.origin.y + nameLabel.frame.size.height + kLabelGap,
        titleLabel.frame.size.width, titleLabel.frame.size.height};
    
    // Figure out required frame and adjust self bounds accordingly.
    CGRect combinedFrame = CGRectUnion(nameLabel.frame, titleLabel.frame);
    combinedFrame.size.width += kLabelInsets.left + kLabelInsets.right;
    combinedFrame.size.height += kLabelInsets.top + kLabelInsets.bottom;
    
    // Figure out min size to fit everything in.
    CGSize minSize = (CGSize){
        kContentInsets.left + combinedFrame.size.width + kContentInsets.right,
        kContentInsets.top + combinedFrame.size.height + kContentInsets.bottom
    };
    CGSize proposedSize = (CGSize){
        minSize.width < kMaxSize.width ? kMaxSize.width : minSize.width,
        minSize.height < kMaxSize.height ? kMaxSize.height : minSize.height
    };
    
    // Update self
    self.frame = (CGRect){
        0.0,
        0.0,
        proposedSize.width,
        proposedSize.height
    };
    
    // Container view.
    UIView *labelContainerView = [[UIView alloc] initWithFrame:combinedFrame];
    labelContainerView.backgroundColor = [UIColor clearColor];
    labelContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    labelContainerView.frame = (CGRect){
        floorf((self.bounds.size.width - labelContainerView.frame.size.width) / 2.0),
        floorf((self.bounds.size.height - labelContainerView.frame.size.height) / 2.0),
        labelContainerView.frame.size.width,
        labelContainerView.frame.size.height
    };
    
    // Update positioning of labels.
    nameLabel.frame = (CGRect){
        kLabelInsets.left + floorf((labelContainerView.bounds.size.width - nameLabel.frame.size.width - kLabelInsets.left - kLabelInsets.right) / 2.0),
        kLabelInsets.top + floorf((labelContainerView.bounds.size.height - nameLabel.frame.size.height - kLabelInsets.top - kLabelInsets.bottom) / 2.0),
        nameLabel.frame.size.width,
        nameLabel.frame.size.height
    };
    titleLabel.frame = (CGRect){
        kLabelInsets.left + floorf((labelContainerView.bounds.size.width - titleLabel.frame.size.width - kLabelInsets.left - kLabelInsets.right) / 2.0),
        nameLabel.frame.origin.y + nameLabel.frame.size.height + kLabelGap,
        titleLabel.frame.size.width,
        titleLabel.frame.size.height
    };
    [labelContainerView addSubview:titleLabel];
    [labelContainerView addSubview:nameLabel];
    [self addSubview:labelContainerView];
    self.labelContainerView = labelContainerView;
    
}

@end
