//
//  BenchtopViewControllerDelegate.h
//  Cook
//
//  Created by Jeff Tan-Ang on 30/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBook.h"

@protocol BenchtopViewControllerDelegate <NSObject>

- (void)benchtopLoaded;
- (void)openBookRequestedForBook:(CKBook *)book centerPoint:(CGPoint)centerPoint;
- (void)editBookRequested:(BOOL)editMode;
- (void)panEnabledRequested:(BOOL)enable;
- (void)panToBenchtopForSelf:(UIViewController *)viewController;
- (NSInteger)currentBenchtopLevel;
- (void)deleteModeToggled:(BOOL)deleteMode;
- (BOOL)benchtopInLibrary;
- (BOOL)benchtopInSettings;

@optional
- (void)benchtopFirstTimeLaunched;
- (void)benchtopPeekRequestedForStore;
- (void)benchtopPeekRequestedForSettings;

@end
