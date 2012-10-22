//
//  CKLoginBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopBookCell.h"
#import "CKLoginView.h"

@interface LoginBookCell : BenchtopBookCell <CKLoginViewDelegate>

- (void)revealWithCompletion:(void (^)())completion;

@end
