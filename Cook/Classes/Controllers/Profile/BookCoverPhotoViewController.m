//
//  BookCoverPhotoViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCoverPhotoViewController.h"
#import "CKBook.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "EventHelper.h"
#import "CKPhotoManager.h"

@interface BookCoverPhotoViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL fullImageLoaded;
@property (nonatomic, weak) id<AppModalViewControllerDelegate> modalDelegate;

@end

@implementation BookCoverPhotoViewController

- (void)dealloc {
    [EventHelper unregisterPhotoLoading:self];
}

- (id)initWithBook:(CKBook *)book {
    if (self = [super init]) {
        self.book = book;
        self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
        [self initBackground];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
}

#pragma mark - AppModalViewController methods

- (void)setModalViewControllerDelegate:(id<AppModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}

- (void)appModalViewControllerWillAppear:(NSNumber *)appearNumber {
}

- (void)appModalViewControllerDidAppear:(NSNumber *)appearNumber {
    if ([appearNumber boolValue]) {
        [self loadData];
    }
}

#pragma mark - Private methods.

- (void)initBackground {
    
    // Background container view.
    UIView *backgroundContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundContainerView];
    
    // Background imageView.
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = (CGRect) {
        backgroundContainerView.bounds.origin.x - motionOffset.horizontal,
        backgroundContainerView.bounds.origin.y - motionOffset.vertical,
        backgroundContainerView.bounds.size.width + (motionOffset.horizontal * 2.0),
        backgroundContainerView.bounds.size.height + (motionOffset.vertical * 2.0)
    };
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [backgroundContainerView addSubview:imageView];
    imageView.alpha = 0.0;
    self.imageView = imageView;
    
    // Motion effects.
    [ViewHelper applyDraggyMotionEffectsToView:self.imageView];
}

- (void)loadData {
    if ([self.book hasCoverPhoto]) {
        [[CKPhotoManager sharedInstance] imageForBook:self.book size:self.imageView.bounds.size];
    }
}

- (void)photoLoadingReceived:(NSNotification *)notification {
    NSString *photoName = [[CKPhotoManager sharedInstance] photoNameForBook:self.book];
    NSString *name = [EventHelper nameForPhotoLoading:notification];
    BOOL thumb = [EventHelper thumbForPhotoLoading:notification];
    if ([photoName isEqualToString:name]) {
        
        // If full image is not loaded yet, then set and keep waiting for it.
        if (!self.fullImageLoaded) {
            if ([EventHelper hasImageForPhotoLoading:notification]) {
                UIImage *image = [EventHelper imageForPhotoLoading:notification];
                [self loadImage:image];
                self.fullImageLoaded = !thumb;
            }
        }
    }
}

- (void)loadImage:(UIImage *)image {
    self.imageView.image = image;
    if (self.imageView.alpha == 0.0) {
        
        // Fade it in.
        [UIView animateWithDuration:0.6
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.imageView.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}


@end
