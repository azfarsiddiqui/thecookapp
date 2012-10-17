//
//  CKLoginBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBenchtopBookCell.h"
#import "CKLoginView.h"

@interface CKLoginBookCell : CKBenchtopBookCell <CKLoginViewDelegate>

- (void)revealWithCompletion:(void (^)())completion;

@end
