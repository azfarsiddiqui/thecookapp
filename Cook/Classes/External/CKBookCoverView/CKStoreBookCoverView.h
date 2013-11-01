//
//  CKStoreBookCoverView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookCoverView.h"

@protocol CKStoreBookCoverViewDelegate <NSObject>

@optional
- (void)storeBookCoverViewAddRequested;

@end

@interface CKStoreBookCoverView : CKBookCoverView

@property (nonatomic, weak) id<CKStoreBookCoverViewDelegate> storeDelegate;

- (void)showActionButton:(BOOL)show animated:(BOOL)animated;
- (void)showLoading:(BOOL)loading;
- (void)showAdd;
- (void)showFollowed;
- (void)showLocked;
- (void)showDownloadable;
- (void)enable:(BOOL)enable interactable:(BOOL)interactable;

@end
