//
//  MeasureListEditViewController.m
//  Cook
//
//  Created by Gerald on 22/01/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "MeasureListEditViewController.h"
#import "PageListCell.h"
#import "CKUser.h"
#import "CKMeasureConverter.h"

@interface MeasureListEditViewController ()

@end

@implementation MeasureListEditViewController

- (id)initWithEditView:(UIView *)editView
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate items:@[@"US Imperial", @"Metric", @"AU Metric", @"UK Metric"] editingHelper:editingHelper
                                 white:white title:nil]) {
        if ([CKUser currentUser].measurementType == CKMeasureTypeImperial) {
            self.selectedIndexNumber = @0;
        } else if ([CKUser currentUser].measurementType == CKMeasureTypeMetric) {
            self.selectedIndexNumber = @1;
        } else if ([CKUser currentUser].measurementType == CKMeasureTypeAUMetric) {
            self.selectedIndexNumber = @2;
        } else if ([CKUser currentUser].measurementType == CKMeasureTypeUKMetric) {
            self.selectedIndexNumber = @3;
        }
    }
    return self;
}

- (Class)classForListCell {
    return [PageListCell class];
}

@end
