//
//  BookNavigationDataSource.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BookNavigationDataSource <NSObject>

- (NSUInteger)bookNavigationContentStartSection;
- (NSUInteger)bookNavigationLayoutNumColumns;
- (NSUInteger)bookNavigationLayoutColumnWidthForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
