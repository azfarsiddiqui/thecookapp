//
//  BookCategoryImageView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;
@class CKRecipe;

@protocol BookContentImageViewDelegate <NSObject>

- (BOOL)shouldRunFullLoadForIndex:(NSInteger)pageIndex;
@optional
- (void)retrievedThumb:(UIImage *)savedImage forRecipe:(CKRecipe *)recipe;
- (void)retrievedBlurredImage:(UIImage *)savedImage forRecipe:(CKRecipe *)recipe;

@end

@interface BookContentImageView : UICollectionReusableView

@property (nonatomic, weak) id<BookContentImageViewDelegate> delegate;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) CKRecipe *recipe;

- (void)configureFeaturedRecipe:(CKRecipe *)recipe book:(CKBook *)book cachedImage:(UIImage *)cachedImage;
- (void)configureBlurredImage:(UIImage *)blurredImage;
- (void)applyOffset:(CGFloat)offset;
- (CGSize)imageSizeWithMotionOffset;
- (void)reloadWithBook:(CKBook *)book;
- (void)deactivateImage;
- (void)cleanImage;
- (BOOL)hasImage;

@end
