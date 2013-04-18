//
//  CKLabelEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 18/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKLabelEditViewController.h"

@interface CKLabelEditViewController ()

@end

@implementation CKLabelEditViewController

- (UIView *)createTargetEditView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:50.0];
    label.textColor = [UIColor blackColor];
    label.text = [self.editTitle uppercaseString];
    [label sizeToFit];
    label.frame = CGRectMake(floorf((self.view.bounds.size.width - label.frame.size.width) / 2.0),
                             160.0,
                             label.frame.size.width,
                             label.frame.size.height);
    return label;
}

- (NSString *)updatedTextValue {
    NSString *textValue = nil;
    if ([self.sourceEditView isKindOfClass:[UILabel class]]) {
        textValue = ((UILabel *)self.sourceEditView).text;
    }
    return textValue;
}

@end
