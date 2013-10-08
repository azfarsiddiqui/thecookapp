//
//  OverlayViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "OverlayViewController.h"
#import "ModalOverlayHelper.h"
#import "AppHelper.h"
#import "RecipeDetailsViewController.h"
#import "BookModalViewController.h"

@interface OverlayViewController ()

@property (nonatomic, strong) UIView *overlayView;

@end

@implementation OverlayViewController

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    self.view.clipsToBounds = YES;
}

- (void)clearStatusMessage {
    [self.statusMessageLabel removeFromSuperview];
}

- (void)displayStatusMessage:(NSString *)statusMessage {
    self.statusMessageLabel.text = statusMessage;
    [self.statusMessageLabel sizeToFit];
    self.statusMessageLabel.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.statusMessageLabel.frame.size.width) / 2.0),
        floorf((self.view.bounds.size.height - self.statusMessageLabel.frame.size.height) / 2.0),
        self.statusMessageLabel.frame.size.width,
        self.statusMessageLabel.frame.size.height
    };
    
    if (!self.statusMessageLabel.superview) {
        [self.view addSubview:self.statusMessageLabel];
    }
}

- (void)showContextWithRecipe:(CKRecipe *)recipe {
    
    // Recipe Details.
    RecipeDetailsViewController *recipeDetailsViewController = [[RecipeDetailsViewController alloc] initWithRecipe:recipe];
    recipeDetailsViewController.hideNavigation = YES;
    [self showContextModalViewController:recipeDetailsViewController];
}

- (void)showContextModalViewController:(UIViewController *)modalViewController {
    
    // Add overlay view so we can splice in under an overlay.
    self.view.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:self.overlayView atIndex:0];
    
    // Modal view controller has to be a UIViewController and confirms to BookModalViewControllerDelegate
    if (![modalViewController conformsToProtocol:@protocol(BookModalViewController)]) {
        DLog(@"Must conform to BookModalViewController protocol.");
        return;
    }
    
    // Prepare the modalVC to be transitioned.
    modalViewController.view.frame = self.view.bounds;
    modalViewController.view.transform = CGAffineTransformMakeTranslation(0.0, self.view.bounds.size.height);
    [self.view insertSubview:modalViewController.view belowSubview:self.overlayView];
    
    // Sets the modal view delegate for close callbacks.
    [modalViewController performSelector:@selector(setModalViewControllerDelegate:) withObject:self];
    
    // Inform will appear.
    [modalViewController performSelector:@selector(bookModalViewControllerWillAppear:)
                              withObject:[NSNumber numberWithBool:YES]];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Slide up the modal.
                         modalViewController.view.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished)  {
                         
                         [modalViewController performSelector:@selector(bookModalViewControllerDidAppear:)
                                                   withObject:[NSNumber numberWithBool:YES]];
                     }];
}

#pragma mark - Properties

- (UILabel *)statusMessageLabel {
    if (!_statusMessageLabel) {
        _statusMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusMessageLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        _statusMessageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        _statusMessageLabel.textColor = [UIColor whiteColor];
    }
    return _statusMessageLabel;
}

- (UIView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    }
    return _overlayView;
}

@end
