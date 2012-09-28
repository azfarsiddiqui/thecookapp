//
//  CKIntroViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKIntroViewController.h"

@interface CKIntroViewController ()

@property (nonatomic, assign) id<CKIntroViewControllerDelegate> delegate;

- (void)okTapped:(id)sender;

@end

@implementation CKIntroViewController

- (id)initWithDelegate:(id<CKIntroViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0.0, 0.0, 600.0, 400.0);
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIFont *font = [UIFont boldSystemFontOfSize:30.0];
    NSString *introText = @"INTRODUCTION";
    CGSize size = [introText sizeWithFont:font constrainedToSize:self.view.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                                               floorf((self.view.bounds.size.height - size.height) / 2.0),
                                                               size.width,
                                                               size.height)];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    label.backgroundColor = [UIColor clearColor];
    label.text = introText;
    label.font = font;
    [self.view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Get Started" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(okTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.frame = CGRectMake(floorf((self.view.bounds.size.width - button.frame.size.width) / 2.0),
                              label.frame.origin.y + label.frame.size.height + 20.0,
                              button.frame.size.width,
                              button.frame.size.height);
    [self.view addSubview:button];
    
}

#pragma mark - Private methods

- (void)okTapped:(id)sender {
    [self.delegate introViewDismissRequested];
}

@end
