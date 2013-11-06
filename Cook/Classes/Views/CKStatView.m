//
//  CKStatView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 3/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKStatView.h"
#import "Theme.h"
#import "DataHelper.h"

@interface CKStatView ()

@property (nonatomic, strong) NSString *unit;
@property (nonatomic, assign) NSNumber *number;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *unitLabel;

@end

@implementation CKStatView

#define kNumberFont     [UIFont fontWithName:@"BrandonGrotesque-Regular" size:14.0]
#define kUnitFont       [UIFont fontWithName:@"BrandonGrotesque-Regular" size:14.0]
#define kContentInsets  UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
#define kNumberUnitGap  5.0



- (id)initWithUnit:(NSString *)unit {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.unit = unit;
        
        // Number.
        NSString *numberString = @"-";
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
        unitLabel.text = [self numberAdjustedUnitForNumber:self.number];
        unitLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [unitLabel sizeToFit];
        unitLabel.frame = CGRectMake(numberLabel.frame.origin.x + numberLabel.frame.size.width + kNumberUnitGap,
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
    self.number = [NSNumber numberWithInteger:number];
    self.numberLabel.text = [DataHelper friendlyDisplayForCount:number];
    [self.numberLabel sizeToFit];
    self.numberLabel.frame = CGRectMake(kContentInsets.left,
                                        self.numberLabel.frame.origin.y,
                                        self.numberLabel.frame.size.width,
                                        self.numberLabel.frame.size.height);
    self.unitLabel.text = [self numberAdjustedUnitForNumber:[NSNumber numberWithInteger:number]];
    [self.unitLabel sizeToFit];
    self.unitLabel.frame = CGRectMake(self.numberLabel.frame.origin.x + self.numberLabel.frame.size.width + kNumberUnitGap,
                                      self.unitLabel.frame.origin.y,
                                      self.unitLabel.frame.size.width,
                                      self.unitLabel.frame.size.height);
    
    [self updateFrame];
}

#pragma mark - Private methods

- (NSString *)numberAdjustedUnitForNumber:(NSNumber *)num {
    NSMutableString *display = [NSMutableString stringWithString:self.unit];
    if ([num unsignedIntegerValue] != 1) {
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
