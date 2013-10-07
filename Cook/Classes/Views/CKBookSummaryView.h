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
- (void)bookSummaryViewBookFollowed;

@end

@interface CKBookSummaryView : UIView <CKSaveableContent>

@property (nonatomic, weak) id<CKBookSummaryViewDelegate> delegate;
@property (nonatomic, strong) UIImage *updatedProfileImage;
@property (nonatomic, strong) NSString *updatedName;
@property (nonatomic, strong) NSString *updatedStory;

- (id)initWithBook:(CKBook *)book;
- (id)initWithBook:(CKBook *)book storeMode:(BOOL)storeMode;
- (id)initWithBook:(CKBook *)book storeMode:(BOOL)storeMode addMode:(BOOL)addMode;
- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated;

@end
