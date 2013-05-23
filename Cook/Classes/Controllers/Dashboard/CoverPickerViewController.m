//
//  CoverPickerViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CoverPickerViewController.h"
#import "CoverPickerView.h"
#import "ViewHelper.h"

@interface CoverPickerViewController () <CoverPickerViewDelegate>

@property (nonatomic, assign) id<CoverPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) CoverPickerView *coverPickerView;

@end

@implementation CoverPickerViewController

#define kSideGap        20.0
#define kHeight         93.0

- (id)initWithCover:(NSString *)cover delegate:(id<CoverPickerViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.cover = cover;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, kHeight);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    
    CoverPickerView *coverPickerView = [[CoverPickerView alloc] initWithCover:self.cover delegate:self];
    coverPickerView.frame = CGRectMake(floorf((self.view.bounds.size.width - coverPickerView.frame.size.width) / 2.0),
                                       floorf((self.view.bounds.size.height - coverPickerView.frame.size.height) / 2.0) + 10.0,
                                       coverPickerView.frame.size.width,
                                       coverPickerView.frame.size.height);
    coverPickerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:coverPickerView];
    self.coverPickerView = coverPickerView;
    
    // Cancel button.
    UIButton *cancelButton = [ViewHelper cancelButtonWithTarget:self selector:@selector(cancelTapped:)];
    cancelButton.frame = CGRectMake(kSideGap,
                                    floorf((self.view.bounds.size.height - cancelButton.frame.size.height) / 2.0) + 10.0,
                                    cancelButton.frame.size.width,
                                    cancelButton.frame.size.height);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:cancelButton];
    
    // Done button.
    UIButton *doneButton = [ViewHelper okButtonWithTarget:self selector:@selector(doneTapped:)];
    doneButton.frame = CGRectMake(self.view.bounds.size.width - doneButton.frame.size.width - kSideGap,
                                  cancelButton.frame.origin.y,
                                  doneButton.frame.size.width,
                                  doneButton.frame.size.height);
    doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:doneButton];
}

#pragma mark - CoverPickerViewDelegate methods

- (void)coverPickerSelected:(NSString *)cover {
    [self.delegate coverPickerSelected:cover];
}

#pragma mark - Private

- (void)cancelTapped:(id)sender {
    [self.delegate coverPickerCancelRequested];
}

- (void)doneTapped:(id)sender {
    [self.delegate coverPickerDoneRequested];
}

@end
