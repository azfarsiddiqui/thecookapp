//
//  CKStatView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 3/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKStatView.h"
#import "Theme.h"

@interface CKStatView ()

@property (nonatomic, strong) NSString *unit;
@property (nonatomic, assign) NSUInteger number;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *unitLabel;

@end

@implementation CKStatView

#define kNumberFont     [UIFont fontWithName:@"Neutraface2Display-Medium" size:14.0]
#define kUnitFont       [UIFont fontWithName:@"Neutraface2Display-Medium" size:14.0]
#define kContentInsets  UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
#define kNumberUnitGap  15.0

- (id)initWithNumber:(NSUInteger)number unit:(NSString *)unit {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.number = number;
        self.unit = unit;
        
        // Number.
        NSString *numberString = [NSString stringWithFormat:@"%d", number];
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        numberLabel.font = kNumberFont;
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.shadowColor = [UIColor blackColor];
        numberLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        numberLabel.text = numberString;
        numberLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [numberLabel sizeToFit];
        numberLabel.frame = CGRectMake(kContentInsets.left,
                                       kContentInsets.top,
                                       numberLabel.frame.size.width,
                                       numberLabel.frame.size.height);
        [self addSubview:numberLabel];
        self.numberLabel = numberLabel;
        
        // Unit.
        UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        unitLabel.font = kUnitFont;
        unitLabel.backgroundColor = [UIColor clearColor];
        unitLabel.textColor = [UIColor whiteColor];
        unitLabel.shadowColor = [UIColor blackColor];
        unitLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        unitLabel.text = [self numberAdjustedUnit];
        unitLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [unitLabel sizeToFit];
        unitLabel.frame = CGRectMake(numberLabel.frame.origin.x + kNumberUnitGap,
                                     kContentInsets.top,
                                     unitLabel.frame.size.width,
                                     unitLabel.frame.size.height);
        [self addSubview:unitLabel];
        self.unitLabel = unitLabel;
        
        [self updateFrame];
        
    }
    return self;
}

- (void)updateNumber:(NSUInteger)number {
    self.number = number;
    CGRect numberFrame = self.numberLabel.frame;
    CGRect unitFrame = self.unitLabel.frame;
    self.numberLabel.text = [NSString stringWithFormat:@"%d", number];
    [self.numberLabel sizeToFit];
    numberFrame.origin.x = kContentInsets.left;
    self.unitLabel.text = [self numberAdjustedUnit];
    [self.unitLabel sizeToFit];
    unitFrame.origin.x = numberFrame.origin.x + kNumberUnitGap;
    self.numberLabel.frame = numberFrame;
    self.unitLabel.frame = unitFrame;
    
    [self updateFrame];
}

#pragma mark - Private methods

- (NSString *)numberAdjustedUnit {
    NSMutableString *display = [NSMutableString stringWithString:self.unit];
    if (self.number != 1) {
        [display appendString:@"S"];
    }
    return display;
}

- (void)updateFrame {
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            kContentInsets.left + self.numberLabel.frame.size.width + kNumberUnitGap + self.unitLabel.frame.size.width + kContentInsets.right,
                            kContentInsets.top + self.unitLabel.frame.size.height + kContentInsets.bottom);
}

@end
