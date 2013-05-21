//
//  BookCover.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookCover.h"
#import "MRCEnumerable.h"

@interface CKBookCover ()

+ (NSDictionary *)settings;

@end

@implementation CKBookCover

#define kInitialCover           @"kCookInitialCover"
#define kInitialIllustration    @"kCookInitialIllustration"

+ (NSString *)initialCover {
    NSString *initialCover = [[NSUserDefaults standardUserDefaults] objectForKey:kInitialCover];
    if (!initialCover) {
        initialCover = [CKBookCover randomCover];
        [[NSUserDefaults standardUserDefaults] setObject:initialCover forKey:kInitialCover];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return initialCover;
}

+ (NSString *)initialIllustration {
    NSString *initialIllustration = [[NSUserDefaults standardUserDefaults] objectForKey:kInitialIllustration];
    if (!initialIllustration) {
        initialIllustration = [CKBookCover randomIllustration];
        [[NSUserDefaults standardUserDefaults] setObject:initialIllustration forKey:kInitialIllustration];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return initialIllustration;
}

+ (NSString *)defaultCover {
    return [[CKBookCover settings] valueForKeyPath:@"Covers.Red.Image"];
}

+ (NSString *)defaultIllustration {
    return [[CKBookCover settings] valueForKeyPath:@"Illustrations.Cutlery.Image"];
}

+ (NSString *)randomCover {
    NSArray *covers = [CKBookCover covers];
    return [covers objectAtIndex:arc4random() % ([covers count] - 1)];
}

+ (NSString *)randomIllustration {
    NSArray *illustrations = [CKBookCover illustrations];
    return [illustrations objectAtIndex:arc4random() % ([illustrations count] - 1)];
}

+ (UIImage *)imageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Image", cover]];
    if (!imageName) {
        imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Image",
                                                             [CKBookCover randomCover]]];
    }
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)outlineImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Outline", cover]];
    if (!imageName) {
        imageName = [[CKBookCover settings] valueForKeyPath:@"Covers.Gray.Image"];
    }
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)thumbImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Thumb", cover]];
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)thumbSliderContentImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Slider", cover]];
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)imageForIllustration:(NSString *)illustration {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Illustrations.%@.Image", illustration]];
    if (!imageName) {
        
        // Direct image loading.
        imageName = illustration;
//        imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Illustrations.%@.Image",
//                                                           [CKBookCover randomIllustration]]];
        
    }
    return [UIImage imageNamed:imageName];
}

+ (NSArray *)covers {
    NSDictionary *settings = [CKBookCover settings];
    NSArray *enabledCovers = [[[settings valueForKey:@"Covers"] allKeys] select:^BOOL(NSString *cover) {
        return ([settings valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Index", cover]] != nil);
    }];
    return [enabledCovers sortedArrayUsingComparator:^NSComparisonResult(NSString *cover, NSString *cover2) {
        NSNumber *index = [settings valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Index", cover]];
        NSNumber *index2 = [settings valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Index", cover2]];
        return [index compare:index2];
    }];
}

+ (NSArray *)illustrations {
    return [[[CKBookCover settings] valueForKey:@"Illustrations"] allKeys];
}

+ (BookCoverLayout)layoutForIllustration:(NSString *)illustration {
    return [self layoutForKey:[[CKBookCover settings] valueForKeyPath:
                               [NSString stringWithFormat:@"Illustrations.%@.Layout", illustration]]];
}

+ (NSString *)grayCoverName {
    return @"Gray";
}

+ (UIImage *)overlayImage {
    return [UIImage imageNamed:@"cook_book_overlay.png"];
}

+ (UIImage *)placeholderCoverImage {
    return [UIImage imageNamed:[[CKBookCover settings] valueForKeyPath:@"Covers.Gray.Image"]];
}

#pragma mark - Private

+ (NSDictionary *)settings {
    static dispatch_once_t pred;
    static NSDictionary *settings = nil;
    dispatch_once(&pred, ^{
        settings = [NSDictionary dictionaryWithContentsOfFile:
                    [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"covers.plist"]];
    });
    return settings;
}

+ (BookCoverLayout)layoutForKey:(NSString *)key {
    BookCoverLayout layout = BookCoverLayoutTop;
    if ([key isEqualToString:@"Layout1"]) {
        layout = BookCoverLayoutTop;
    } else if ([key isEqualToString:@"Layout2"]) {
        layout = BookCoverLayoutBottom;
    }
    return layout;
}

@end
