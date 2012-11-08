//
//  BookCover.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCover.h"
#import "MRCEnumerable.h"

@interface BookCover ()

+ (NSDictionary *)settings;

@end

@implementation BookCover

#define kInitialCover           @"kCookInitialCover"
#define kInitialIllustration    @"kCookInitialIllustration"

+ (NSString *)initialCover {
    NSString *initialCover = [[NSUserDefaults standardUserDefaults] objectForKey:kInitialCover];
    if (!initialCover) {
        initialCover = [BookCover randomCover];
        [[NSUserDefaults standardUserDefaults] setObject:initialCover forKey:kInitialCover];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return initialCover;
}

+ (NSString *)initialIllustration {
    NSString *initialIllustration = [[NSUserDefaults standardUserDefaults] objectForKey:kInitialIllustration];
    if (!initialIllustration) {
        initialIllustration = [BookCover randomIllustration];
        [[NSUserDefaults standardUserDefaults] setObject:initialIllustration forKey:kInitialIllustration];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return initialIllustration;
}

+ (NSString *)defaultCover {
    return [[BookCover settings] valueForKeyPath:@"Covers.Red.Image"];
}

+ (NSString *)defaultIllustration {
    return [[BookCover settings] valueForKeyPath:@"Illustrations.Cutlery.Image"];
}

+ (NSString *)randomCover {
    NSArray *covers = [BookCover covers];
    return [covers objectAtIndex:arc4random() % ([covers count] - 1)];
}

+ (NSString *)randomIllustration {
    NSArray *illustrations = [BookCover illustrations];
    return [illustrations objectAtIndex:arc4random() % ([illustrations count] - 1)];
}

+ (UIImage *)imageForCover:(NSString *)cover {
    NSString *imageName = [[BookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Image", cover]];
    if (!imageName) {
        imageName = [[BookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Image",
                                                           [BookCover randomCover]]];
    }
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)thumbImageForCover:(NSString *)cover {
    NSString *imageName = [[BookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Thumb", cover]];
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)imageForIllustration:(NSString *)illustration {
    NSString *imageName = [[BookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Illustrations.%@.Image", illustration]];
    if (!imageName) {
        imageName = [[BookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Illustrations.%@.Image",
                                                           [BookCover randomIllustration]]];
    }
    return [UIImage imageNamed:imageName];
}

+ (NSArray *)covers {
    NSDictionary *settings = [BookCover settings];
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
    return [[[BookCover settings] valueForKey:@"Illustrations"] allKeys];
}

+ (BookCoverLayout)layoutForIllustration:(NSString *)illustration {
    return [self layoutForKey:[[BookCover settings] valueForKeyPath:
                               [NSString stringWithFormat:@"Illustrations.%@.Layout", illustration]]];
}

+ (NSString *)grayCoverName {
    return @"Gray";
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
    BookCoverLayout layout = BookCoverLayout1;
    if ([key isEqualToString:@"Layout1"]) {
        layout = BookCoverLayout1;
    } else if ([key isEqualToString:@"Layout2"]) {
        layout = BookCoverLayout2;
    } else if ([key isEqualToString:@"Layout3"]) {
        layout = BookCoverLayout3;
    } else if ([key isEqualToString:@"Layout4"]) {
        layout = BookCoverLayout4;
    } else if ([key isEqualToString:@"Layout5"]) {
        layout = BookCoverLayout5;
    }
    return layout;
}

@end
