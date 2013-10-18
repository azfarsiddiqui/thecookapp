//
//  BenchtopCell.h
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"
#import "CKBookCoverView.h"

@protocol BenchtopBookCoverViewCellDelegate <NSObject>

@optional
- (void)benchtopBookEditTappedForCell:(UICollectionViewCell *)cell;
- (void)benchtopBookEditWillAppear:(BOOL)appear forCell:(UICollectionViewCell *)cell;
- (void)benchtopBookEditDidAppear:(BOOL)appear forCell:(UICollectionViewCell *)cell;

@end


@interface BenchtopBookCoverViewCell : UICollectionViewCell

@property (nonatomic, strong) CKBookCoverView *bookCoverView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, weak) id<BenchtopBookCoverViewCellDelegate> delegate;

+ (CGSize)cellSize;
+ (CGSize)illustrationPickerCellSize;
+ (CGSize)storeCellSize;
+ (CGFloat)storeScale;

- (CKBookCoverView *)createBookCoverViewWithDelegate:(id<CKBookCoverViewDelegate>)delegate;
- (UIImage *)shadowImage;
- (UIOffset)shadowOffset;
- (void)loadBook:(CKBook *)book;
- (void)loadBook:(CKBook *)book updates:(NSInteger)updates;
- (void)enableDeleteMode:(BOOL)enable;
- (void)enableEditMode:(BOOL)enable;

@end
