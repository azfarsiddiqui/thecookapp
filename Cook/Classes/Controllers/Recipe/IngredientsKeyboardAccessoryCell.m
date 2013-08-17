//
//  IngredientsKeyboardAccessoryCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsKeyboardAccessoryCell.h"

@interface IngredientsKeyboardAccessoryCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation IngredientsKeyboardAccessoryCell

#define kLabelOffset    (UIOffset) { 1.0, -2.0 }

+ (CGSize)cellSize {
    return (CGSize){ 80.0, 40.0 };
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_keyboard_autosuggest_btn.png"]
                                    resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 11.0, 0.0, 11.0 }];
        self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        
        self.label = [[UILabel alloc] initWithFrame:(CGRect){
            self.bounds.origin.x + kLabelOffset.horizontal,
            self.bounds.origin.y + kLabelOffset.vertical,
            self.bounds.size.width,
            self.bounds.size.height
        }];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor blackColor];
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];

        self.label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.label];
        
    }
    return self;
}

- (void)configureText:(NSString *)text {
    self.label.text = text;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundView.alpha = highlighted ? 0.5 : 1.0;
}

@end
