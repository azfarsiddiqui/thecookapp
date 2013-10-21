//
//  CKBookCoverView.h
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@protocol CKBookCoverViewDelegate <NSObject>

- (void)bookCoverViewEditRequested;

@optional
- (void)bookCoverViewEditWillAppear:(BOOL)appear;
- (void)bookCoverViewEditDidAppear:(BOOL)appear;

@end

@interface CKBookCoverView : UIView

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, copy) NSString *nameValue;
@property (nonatomic, copy) NSString *authorValue;
@property (nonatomic, copy) NSString *captionValue;

- (id)initWithDelegate:(id<CKBookCoverViewDelegate>)delegate;
- (id)initWithStoreMode:(BOOL)storeMode delegate:(id<CKBookCoverViewDelegate>)delegate;
- (void)loadBook:(CKBook *)book;
- (void)loadBook:(CKBook *)book update:(NSInteger)updates;
- (void)loadBook:(CKBook *)book editable:(BOOL)editable;
- (void)loadBook:(CKBook *)book editable:(BOOL)editable loadRemoteIllustration:(BOOL)loadRemoteIllustration;
- (void)loadBook:(CKBook *)book editable:(BOOL)editable loadRemoteIllustration:(BOOL)loadRemoteIllustration
         updates:(NSInteger)updates;
- (void)loadRemoteIllustrationImage:(UIImage *)illustrationImage;
- (void)setCover:(NSString *)cover illustration:(NSString *)illustration;
- (void)setName:(NSString *)name author:(NSString *)author editable:(BOOL)editable;
- (void)enableEditMode:(BOOL)enable animated:(BOOL)animated;
- (void)clearUpdates;

@end
