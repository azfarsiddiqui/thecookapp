//
//  CKBookCoverViewCell.h
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 27/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBookCoverView.h"

@protocol CKBookCoverViewCellDelegate

- (void)bookCoverViewEditRequestedForIndexPath:(NSIndexPath *)indexPath;

@end

@interface CKBookCoverViewCell : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) id<CKBookCoverViewCellDelegate> delegate;
@property (nonatomic, strong) CKBookCoverView *bookCoverView;
@property (nonatomic, assign) BOOL editMode;

+ (CGSize)cellSize;

- (void)setCover:(NSString *)cover illustration:(NSString *)illustration author:(NSString *)author
           title:(NSString *)title editable:(BOOL)editable;
- (void)enableEditMode:(BOOL)enable;

@end
