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

@end
