//
//  PageViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 8/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"

typedef enum {
	NavigationButtonStyleWhite,
	NavigationButtonStyleGray
} NavigationButtonStyle;

@protocol PageViewDelegate
-(void)showPageNumber;
-(void)hidePageNumber;
@end
@interface PageViewController : UIViewController<PageViewDelegate>

@property (nonatomic, assign) id<BookViewDelegate> delegate;
@property (nonatomic, assign) id<BookViewDataSource> dataSource;

- (id)initWithBookViewDelegate:(id<BookViewDelegate>)delegate dataSource:(id<BookViewDataSource>)dataSource withButtonStyle:(NavigationButtonStyle)navigationButtonStyle;
- (void)initPageView;
- (void)showContentsButton;
- (void)loadingIndicator:(BOOL)loading;
@end
