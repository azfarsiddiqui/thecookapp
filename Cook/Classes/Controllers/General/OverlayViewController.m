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
}

@end
