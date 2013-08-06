//
//  BookCoverViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@protocol BookCoverViewControllerDelegate <NSObject>

- (void)bookCoverViewWillOpen:(BOOL)open;
- (void)bookCoverViewDidOpen:(BOOL)open;
- (CGPoint)bookCoverCenterPoint;

@optional
- (UIView *)bookCoverViewInsideSnapshotView;

@end

@interface BookCoverViewController : UIViewController

@property (nonatomic, assign) BOOL showInsideCover;

- (id)initWithBook:(CKBook *)book delegate:(id<BookCoverViewControllerDelegate>)delegate;
- (id)initWithBook:(CKBook *)book mine:(BOOL)mine delegate:(id<BookCoverViewControllerDelegate>)delegate;
- (void)openBook:(BOOL)open;
- (void)openBook:(BOOL)open centerPoint:(CGPoint)centerPoint;
- (void)cleanUpLayers;
- (void)loadSnapshotView:(UIView *)snapshotView;

@end
