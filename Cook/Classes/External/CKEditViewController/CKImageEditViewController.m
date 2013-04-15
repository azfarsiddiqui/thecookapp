//
//  CKImageEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 15/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKImageEditViewController.h"

@interface CKImageEditViewController ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CKImageEditViewController

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white image:(UIImage *)image {
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white]) {
        self.image = image;
    }
    return self;
}

- (UIView *)createTargetEditView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.userInteractionEnabled = YES;
    imageView.frame = CGRectMake(floorf((self.view.bounds.size.width - imageView.frame.size.width) / 2.0),
                                 floorf((self.view.bounds.size.height) / 2.0),
                                 imageView.frame.size.width,
                                 imageView.frame.size.height);
    self.imageView = imageView;
    return imageView;
}

@end
