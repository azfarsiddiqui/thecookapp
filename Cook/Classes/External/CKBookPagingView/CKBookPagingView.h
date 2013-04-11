//
//  CKBookPagingView.h
//  CKBookPagingView
//
//  Created by Jeff Tan-Ang on 11/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBookPagingView : UIView

@property (nonatomic, assign) NSUInteger numPages;
@property (nonatomic, assign) NSInteger currentPage;

- (id)initWithNumPages:(NSUInteger)numPages;
- (void)setPage:(NSInteger)page;

@end
