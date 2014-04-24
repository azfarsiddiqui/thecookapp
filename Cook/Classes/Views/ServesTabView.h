//
//  ServesTabView.h
//  Cook
//
//  Created by Gerald on 23/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTabView.h"
#import "CKRecipe.h"

@protocol ServesTabViewDelegate <NSObject>

- (void)didSelectQuantityType:(CKQuantityType)quantityType;

@end

@interface ServesTabView : CKTabView

@property (nonatomic, assign) CKQuantityType selectedType;
@property (nonatomic, strong) NSString *quantity;

- (instancetype)initWithDelegate:(id<ServesTabViewDelegate>)delegate selectedType:(CKQuantityType)selectedType quantityString:(NSString *)quantity;
- (void)updateQuantity:(NSString *)quantity;

@end
