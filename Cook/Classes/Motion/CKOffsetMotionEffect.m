//
//  CKInterpoltingMotionEffect.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKOffsetMotionEffect.h"

@interface CKOffsetMotionEffect ()

@property (nonatomic, assign) UIOffset offset;

@end

@implementation CKOffsetMotionEffect

- (id)initWithOffset:(UIOffset)offset {
    if (self = [super init]) {
        self.offset = offset;
    }
    return self;
}

- (NSDictionary *)keyPathsAndRelativeValuesForViewerOffset:(UIOffset)viewerOffset {
    
    NSMutableDictionary *keyPathValues = [NSMutableDictionary dictionary];
    
    CGFloat xOffset = (viewerOffset.horizontal * self.offset.horizontal);
    CGFloat yOffset = (viewerOffset.vertical * self.offset.vertical);
    
    [keyPathValues setObject:@(xOffset) forKey:@"center.x"];
    [keyPathValues setObject:@(yOffset) forKey:@"center.y"];
    
//    DLog(@"[%@]: %@", NSStringFromUIOffset(viewerOffset), keyPathValues);
    
    return keyPathValues;
}

@end
