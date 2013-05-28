//
//  WelcomeCollectionViewLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 28/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WelcomeCollectionViewLayoutDataSource <NSObject>

- (NSInteger)numberOfPagesForWelcomeLayout;
- (NSInteger)numberOfAdornmentsForPage:(NSInteger)page;
- (CGSize)sizeOfPageHeaderForPage:(NSInteger)page;
- (CGSize)sizeOfAdornmentForIndexPath:(NSIndexPath *)indexPath;

@end

@interface WelcomeCollectionViewLayout : UICollectionViewLayout

- (id)initWithDataSource:(id<WelcomeCollectionViewLayoutDataSource>)dataSource;

@end
