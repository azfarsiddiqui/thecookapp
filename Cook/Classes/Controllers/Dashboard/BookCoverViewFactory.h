//
//  BookCoverViewFactory.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookView.h"

@interface BookCoverViewFactory : NSObject

+ (BookView *)bookCoverViewWithFrame:(CGRect)frame;
+ (BookView *)bookCoverViewWithType:(NSString *)type frame:(CGRect)frame;

@end
