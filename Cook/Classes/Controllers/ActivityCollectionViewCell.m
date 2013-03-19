//
//  ActivityCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ActivityCollectionViewCell.h"
#import "ImageHelper.h"
#import "Theme.h"
#import "TTTTimeIntervalFormatter.h"
#import "CKActivity.h"
#import "CKUser.h"
#import "CKRecipe.h"
#import "ActivityRecipeStatsView.h"

@interface ActivityCollectionViewCell ()

@property (nonatomic, strong) CKActivity *activity;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UILabel *activityActionLabel;
@property (nonatomic, strong) UILabel *activityTimeLabel;
@property (nonatomic, strong) UILabel *activityTitleLabel;
@property (nonatomic, strong) UILabel *activityNameLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (nonatomic, strong) ActivityRecipeStatsView *gridStatsView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation ActivityCollectionViewCell

#define kInfoContentInsets  UIEdgeInsetsMake(10.0, 15.0, 5.0, 15.0)

+ (CGSize)cellSize {
    return CGSizeMake(276.0, 256.0);
}

+ (CGSize)imageSize {
    return [self cellSize];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // Background image.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.frame = self.bounds;
        imageView.backgroundColor = [Theme activityInfoViewColour];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        // Activity view.
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(floorf((imageView.bounds.size.width - activityView.frame.size.width) / 2.0),
                                        floorf((imageView.bounds.size.height / 2.0 - activityView.frame.size.height) / 2.0),
                                        activityView.frame.size.width,
                                        activityView.frame.size.height);
        activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [activityView startAnimating];
        [imageView addSubview:activityView];
        self.activityView = activityView;
        
        // Info view.
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                    floorf(frame.size.height / 2.0),
                                                                    frame.size.width,
                                                                    floorf(frame.size.height / 2.0))];
        infoView.backgroundColor = [Theme activityInfoViewColour];
        [self.contentView addSubview:infoView];
        self.infoView = infoView;
        
        // Left activity action.
        UILabel *activityActionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        activityActionLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        activityActionLabel.backgroundColor = [UIColor clearColor];
        activityActionLabel.font = [Theme activityActionFont];
        activityActionLabel.textColor = [Theme activityActionColour];
        activityActionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.infoView addSubview:activityActionLabel];
        self.activityActionLabel = activityActionLabel;

        // Right activity time.
        UILabel *activityTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        activityTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        activityTimeLabel.backgroundColor = [UIColor clearColor];
        activityTimeLabel.font = [Theme activityTimeFont];
        activityTimeLabel.textColor = [Theme activityTimeColour];
        activityTimeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.infoView addSubview:activityTimeLabel];
        self.activityTimeLabel = activityTimeLabel;
        
        // Center activity title.
        UILabel *activityTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        activityTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        activityTitleLabel.backgroundColor = [UIColor clearColor];
        activityTitleLabel.font = [Theme activityTitleFont];
        activityTitleLabel.textColor = [Theme activityTitleColour];
        activityTitleLabel.numberOfLines = 2;
        activityTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        activityTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.infoView addSubview:activityTitleLabel];
        self.activityTitleLabel = activityTitleLabel;
        
        // Bottom activity name.
        UILabel *activityNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        activityNameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        activityNameLabel.backgroundColor = [UIColor clearColor];
        activityNameLabel.font = [Theme activityNameFont];
        activityNameLabel.textColor = [Theme activityNameColour];
        activityNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.infoView addSubview:activityNameLabel];
        self.activityNameLabel = activityNameLabel;
        
        // Bottom stats view.
        CGFloat statsBarHeight = 32.0;
        ActivityRecipeStatsView *gridStatsView = [[ActivityRecipeStatsView alloc] initWithFrame:CGRectMake(kInfoContentInsets.left,
                                                                                                   self.infoView.bounds.size.height - kInfoContentInsets.bottom - statsBarHeight,
                                                                                                   self.infoView.bounds.size.width - kInfoContentInsets.left - kInfoContentInsets.right,
                                                                                                   statsBarHeight)];
        gridStatsView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.infoView addSubview:gridStatsView];
        self.gridStatsView = gridStatsView;
        
        // Past dates formatting.
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        [self.timeIntervalFormatter setUsesIdiomaticDeicticExpressions:NO];
    }
    return self;
}

- (void)configureActivity:(CKActivity *)activity {
    self.activity = activity;
    
    [self configureTime];
    [self configureAction];
    [self configureTitle];
    [self configureName];
    [self configureStats];
    
    // Start spinner on imageView if there was a recipe/photo
    self.imageView.image = nil;
    CKRecipe *recipe = activity.recipe;
    if ([recipe hasPhotos]) {
        [self.activityView startAnimating];
        self.infoView.frame = CGRectMake(0.0,
                                         floorf(self.contentView.bounds.size.height / 2.0),
                                         self.contentView.bounds.size.width,
                                         floorf(self.contentView.bounds.size.height / 2.0));
    } else {
        [self.activityView stopAnimating];
        self.infoView.frame = self.contentView.bounds;
    }
}

- (void)configureImage:(UIImage *)image {
    
    // Stop spinner no matter what.
    if (image) {
        [self.activityView stopAnimating];
    }
    
    [ImageHelper configureImageView:self.imageView image:image];
}

#pragma mark - Private methods

- (void)configureTime {
    NSString *timeDisplay = [[self.timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date]
                                                                                toDate:self.activity.createdDateTime] uppercaseString];
    self.activityTimeLabel.text = timeDisplay;
    [self.activityTimeLabel sizeToFit];
    self.activityTimeLabel.frame = CGRectMake(self.infoView.bounds.size.width - self.activityTimeLabel.frame.size.width - kInfoContentInsets.left,
                                              kInfoContentInsets.top,
                                              self.activityTimeLabel.frame.size.width,
                                              self.activityTimeLabel.frame.size.height);
}

- (void)configureAction {
    CGSize availableSize = CGSizeMake(self.infoView.bounds.size.width - kInfoContentInsets.left - kInfoContentInsets.right - self.activityTimeLabel.frame.size.width,
                                       self.infoView.bounds.size.height);
    NSString *actionDisplay = [self actionDisplay];
    CGSize size = [actionDisplay sizeWithFont:[Theme activityActionFont] constrainedToSize:availableSize lineBreakMode:NSLineBreakByTruncatingTail];
    self.activityActionLabel.text = actionDisplay;
    self.activityActionLabel.frame = CGRectMake(kInfoContentInsets.left, kInfoContentInsets.top, size.width, size.height);
}

- (void)configureTitle {
    NSString *title = [self.activity.recipe.name uppercaseString];
    CGSize availableSize = CGSizeMake(self.infoView.bounds.size.width - kInfoContentInsets.left - kInfoContentInsets.right,
                                      self.infoView.bounds.size.height - kInfoContentInsets.top - kInfoContentInsets.bottom);
    CGSize size = [title sizeWithFont:[Theme activityTitleFont] constrainedToSize:availableSize lineBreakMode:NSLineBreakByTruncatingTail];
    self.activityTitleLabel.text = title;
    self.activityTitleLabel.frame = CGRectMake(floorf((self.infoView.bounds.size.width - size.width) / 2.0),
                                               floorf((self.infoView.bounds.size.height - size.height) / 2.0),
                                               size.width,
                                               size.height);
}

- (void)configureName {
    NSString *name = nil;
    if ([self.activity.name isEqualToString:kActivityNameLikeRecipe]) {
        name = self.activity.recipe.user.name;
    }
    
    if (name) {
        self.activityNameLabel.hidden = YES;
        self.activityNameLabel.text = [[NSString stringWithFormat:@"By %@", name] uppercaseString];
        [self.activityNameLabel sizeToFit];
        self.activityNameLabel.frame = CGRectMake(floorf((self.infoView.bounds.size.width - self.activityNameLabel.frame.size.width) / 2.0),
                                                  self.activityTitleLabel.frame.origin.y + self.activityTitleLabel.frame.size.height,
                                                  self.activityNameLabel.frame.size.width,
                                                  self.activityNameLabel.frame.size.height);
    } else {
        self.activityNameLabel.hidden = YES;
    }
}

- (void)configureStats {
    if (self.activity.recipe) {
        self.gridStatsView.hidden = NO;
        [self.gridStatsView configureRecipe:self.activity.recipe];
    } else {
        self.gridStatsView.hidden = YES;
    }
}

- (NSString *)nameDisplay {
    return [NSString stringWithFormat:@"By %@", self.activity.recipe.user.name];
}

- (NSString *)actionDisplay {
    NSString *userName = self.activity.user.firstName;
    if ([userName length] == 0) {
        userName = self.activity.user.name;
    }
    return [[NSString stringWithFormat:@"%@ %@", userName, [self.activity actionName]] uppercaseString];
}

@end
