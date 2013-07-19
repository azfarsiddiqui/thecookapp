//
//  BookCoverViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@protocol BookCoverViewControllerDelegate

- (void)bookCoverViewWillOpen:(BOOL)open;
- (void)bookCoverViewDidOpen:(BOOL)open;
- (CGPoint)bookCoverCenterPoint;

@end

@interface BookCoverViewController : UIViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookCoverViewControllerDelegate>)delegate;
- (id)initWithBook:(CKBook *)book mine:(BOOL)mine delegate:(id<BookCoverViewControllerDelegate>)delegate;
- (void)openBook:(BOOL)open;
- (void)openBook:(BOOL)open centerPoint:(CGPoint)centerPoint;
- (void)cleanUpLayers;

@end
