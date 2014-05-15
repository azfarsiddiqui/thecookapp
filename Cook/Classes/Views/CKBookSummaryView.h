//
//  CKBookUserSummaryView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 3/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKSaveableContent.h"

@class CKBook;

@protocol CKBookSummaryViewDelegate <NSObject>

@optional
- (void)bookSummaryViewEditing:(BOOL)editing;
- (void)bookSummaryViewUserFriendActioned;
- (void)bookSummaryViewBookFollowed;
- (void)bookSummaryViewBookIsFollowed;
- (void)bookSummaryViewBookIsPrivate;
- (void)bookSummaryViewBookIsDownloadable;

@end

@interface CKBookSummaryView : UIView <CKSaveableContent>

@property (nonatomic, weak) id<CKBookSummaryViewDelegate> delegate;
@property (nonatomic, strong) UIImage *updatedProfileImage;
@property (nonatomic, strong) NSString *updatedName;
@property (nonatomic, strong) NSString *updatedStory;
@property (nonatomic, assign) BOOL isDeleteCoverPhoto;

- (id)initWithBook:(CKBook *)book;
- (id)initWithBook:(CKBook *)book storeMode:(BOOL)storeMode;
- (id)initWithBook:(CKBook *)book storeMode:(BOOL)storeMode withinBook:(BOOL)withinBook;
- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated;

@end
