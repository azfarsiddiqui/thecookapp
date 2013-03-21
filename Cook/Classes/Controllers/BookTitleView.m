//
//  BookTitleView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleView.h"
#import "Theme.h"
#import "CKBook.h"
#import "ImageHelper.h"

@interface BookTitleView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;

@end

@implementation BookTitleView

#define kTitleInsets    UIEdgeInsetsMake(100.0, 50.0, 70.0, 50.0)
#define kTitleNameGap   0.0

+ (CGSize)headerSize {
    // Only height is used for a vertically scrolling collection view.
    return CGSizeMake(964.0, 520.0);
}

+ (CGSize)heroImageSize {
    CGSize headerSize = [BookTitleView headerSize];
    return CGSizeMake(headerSize.width, headerSize.height);
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        CGSize headerSize = [BookTitleView headerSize];
        
        // Pre-create the background image view to have exactly 964.0 width.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.frame = CGRectMake(floorf((self.bounds.size.width - headerSize.width) / 2.0),
                                     self.bounds.origin.y,
                                     headerSize.width,
                                     self.bounds.size.height);
        imageView.backgroundColor = [Theme categoryHeaderBackgroundColour];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        // Title view.
        UIView *titleView = [[UIView alloc] initWithFrame:imageView.bounds];
        titleView.backgroundColor = [UIColor whiteColor];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [imageView addSubview:titleView];
        self.titleView = titleView;
        titleView.hidden = YES;
        
        // Labels.
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 2;
        titleLabel.font = [Theme bookContentsTitleFont];
        titleLabel.textColor = [Theme bookContentsTitleColour];
        [titleView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        titleLabel.hidden = YES;
        
        UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        authorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        authorLabel.font = [Theme bookContentsNameFont];
        authorLabel.textColor = [Theme bookContentsNameColour];
        [titleView addSubview:authorLabel];
        self.authorLabel = authorLabel;
        authorLabel.hidden = YES;
        
    }
    return self;
}

- (void)configureBook:(CKBook *)book {
    
    // Book title.
    NSString *bookTitle = [book.name uppercaseString];
    CGSize availableSize = CGSizeMake(self.titleView.bounds.size.width - kTitleInsets.left - kTitleInsets.right,
                                      self.titleView.bounds.size.height - kTitleInsets.top - kTitleInsets.bottom);
    CGSize size = [bookTitle sizeWithFont:[Theme bookContentsTitleFont] constrainedToSize:availableSize
                            lineBreakMode:NSLineBreakByWordWrapping];
    self.titleLabel.frame = CGRectMake(kTitleInsets.left + floorf((availableSize.width - size.width) / 2.0),
                                       0.0,
                                       size.width,
                                       size.height);
    self.titleLabel.text = bookTitle;
    
    // Book author.
    NSString *bookAuthor = [[book userName] uppercaseString];
    CGSize authorSize = [bookAuthor sizeWithFont:[Theme bookContentsNameFont] constrainedToSize:availableSize
                                   lineBreakMode:NSLineBreakByWordWrapping];
    self.authorLabel.frame = CGRectMake(kTitleInsets.left + floorf((availableSize.width - authorSize.width) / 2.0),
                                        0.0,
                                        authorSize.width,
                                        authorSize.height);
    self.authorLabel.text = bookAuthor;
    
    // Combined height of title and name, to use for centering.
    CGRect titleFrame = self.titleLabel.frame;
    CGRect authorFrame = self.authorLabel.frame;
    CGSize combinedSize = CGSizeMake(MAX(titleFrame.size.width, authorFrame.size.width),
                                     titleFrame.size.height + kTitleNameGap + authorFrame.size.height);
    
    titleFrame.origin.y = kTitleInsets.top + floorf((availableSize.height - combinedSize.height) / 2.0);
    authorFrame.origin.y = titleFrame.origin.y + titleFrame.size.height + kTitleNameGap;
    self.titleLabel.frame = titleFrame;
    self.authorLabel.frame = authorFrame;
    
    // Adjust titleView frame.
    self.titleView.frame = CGRectMake(floorf((self.imageView.bounds.size.width - (combinedSize.width + kTitleInsets.left + kTitleInsets.right)) / 2.0),
                                      floorf((self.imageView.bounds.size.height - (combinedSize.height + kTitleInsets.top + kTitleInsets.bottom)) / 2.0),
                                      combinedSize.width + kTitleInsets.left + kTitleInsets.right,
                                      combinedSize.height + kTitleInsets.top + kTitleInsets.bottom);
    self.titleView.hidden = NO;
    self.titleLabel.hidden = NO;
    self.authorLabel.hidden = NO;
}

- (void)configureImage:(UIImage *)image {
    [ImageHelper configureImageView:self.imageView image:image];
}

@end
