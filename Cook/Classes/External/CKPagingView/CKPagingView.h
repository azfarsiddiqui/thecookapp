//
//  CKPagingView.h
//  CKPagingView
//
//  Created by Jeff Tan-Ang on 27/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CKPagingViewTypeHorizontal,
    CKPagingViewTypeVertical,
} CKPagingViewType;

@interface CKPagingView : UIView

@property (nonatomic, assign) CKPagingViewType pagingType;
@property (nonatomic, assign) NSInteger numPages;
@property (nonatomic, assign) NSInteger currentPage;

- (id)initWithNumPages:(NSInteger)numPages type:(CKPagingViewType)type;
- (id)initWithNumPages:(NSInteger)numPages startPage:(NSInteger)startPage type:(CKPagingViewType)type;
- (id)initWithNumPages:(NSInteger)numPages type:(CKPagingViewType)type contentInsets:(UIEdgeInsets)contentInsets;
- (id)initWithNumPages:(NSInteger)numPages type:(CKPagingViewType)type slideAnimated:(BOOL)slideAnimated
         contentInsets:(UIEdgeInsets)contentInsets;
- (id)initWithNumPages:(NSInteger)numPages startPage:(NSInteger)startPage type:(CKPagingViewType)type
         slideAnimated:(BOOL)slideAnimated contentInsets:(UIEdgeInsets)contentInsets;
- (void)setPage:(NSInteger)page;
- (void)setPage:(NSInteger)page animated:(BOOL)animated;

@end
