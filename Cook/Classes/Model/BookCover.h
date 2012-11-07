//
//  BookCover.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	BookCoverLayout1,
	BookCoverLayout2,
	BookCoverLayout3,
	BookCoverLayout4,
	BookCoverLayout5,
} BookCoverLayout;

@interface BookCover : NSObject

+ (NSString *)initialCover;
+ (NSString *)initialIllustration;
+ (NSString *)defaultCover;
+ (NSString *)defaultIllustration;
+ (NSString *)randomCover;
+ (NSString *)randomIllustration;
+ (UIImage *)imageForCover:(NSString *)cover;
+ (UIImage *)customiseImageForCover:(NSString *)cover;
+ (UIImage *)imageForIllustration:(NSString *)illustration;
+ (NSArray *)covers;
+ (NSArray *)illustrations;
+ (NSString *)grayCoverName;

+ (BookCoverLayout)layoutForIllustration:(NSString *)illustration;

@end
