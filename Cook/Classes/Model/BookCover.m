//
//  BookCover.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCover.h"

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
    return [[BookCover settings] valueForKeyPath:@"Covers.Red"];
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
    NSString *imageName = [[BookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@", cover]];
    if (!imageName) {
        imageName = [[BookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@",
                                                           [BookCover randomCover]]];
    }
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
    return [[[BookCover settings] valueForKey:@"Covers"] allKeys];
}

+ (NSArray *)illustrations {
    return [[[BookCover settings] valueForKey:@"Illustrations"] allKeys];
}

+ (BookCoverTitleAlignment)titleAlignmentForIllustration:(NSString *)illustration {
    return [self textAlignmentForKey:[[BookCover settings] valueForKeyPath:
                                      [NSString stringWithFormat:@"Illustrations.%@.TitleAlignment", illustration]]];
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

+ (BookCoverTitleAlignment)textAlignmentForKey:(NSString *)key {
    BookCoverTitleAlignment textAlignment = BookCoverTitleAlignmentMidCentered;
    if ([key isEqualToString:@"TopLeft"]) {
        textAlignment = BookCoverTitleAlignmentTopLeft;
    } else if ([key isEqualToString:@"TopCenter"]) {
        textAlignment = BookCoverTitleAlignmentTopCentered;
    } else if ([key isEqualToString:@"BottomCenter"]) {
        textAlignment = BookCoverTitleAlignmentBottomCentered;
    }
    return textAlignment;
}

@end
