//
//  CKBookCoverView.h
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKBookCoverViewDelegate

- (void)bookCoverViewEditRequested;

@end

@interface CKBookCoverView : UIView

@property (nonatomic, copy) NSString *nameValue;
@property (nonatomic, copy) NSString *authorValue;
@property (nonatomic, copy) NSString *captionValue;

+ (CGSize)coverImageSize;
+ (CGSize)coverShadowSize;
+ (CGSize)smallCoverImageSize;
+ (CGSize)smallCoverShadowSize;

- (id)initWithFrame:(CGRect)frame delegate:(id<CKBookCoverViewDelegate>)delegate;
- (id)initWithFrame:(CGRect)frame storeMode:(BOOL)storeMode delegate:(id<CKBookCoverViewDelegate>)delegate;
- (void)setCover:(NSString *)cover illustration:(NSString *)illustration;
- (void)setName:(NSString *)name author:(NSString *)author editable:(BOOL)editable;
- (void)enableEditMode:(BOOL)enable;

@end
