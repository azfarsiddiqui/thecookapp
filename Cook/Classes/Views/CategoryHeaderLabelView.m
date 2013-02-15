//
//  CategoryHeaderLabelView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryHeaderLabelView.h"
#import "Theme.h"

@interface CategoryHeaderLabelView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) CGSize availableBounds;

@end

@implementation CategoryHeaderLabelView

#define kFont   [Theme defaultFontWithSize:100.0]
#define kInsets UIEdgeInsetsMake(20.0, 20.0, 12.0, 20.0)

- (id)initWithBounds:(CGSize)bounds {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.availableBounds = bounds;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.minimumScaleFactor = 0.7;
        label.adjustsFontSizeToFitWidth = YES;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.opaque = NO;
        label.numberOfLines = 1;
        [self addSubview:label];
        self.label = label;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [super drawRect:rect];
    
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, CGRectGetHeight(rect)));
    
    // create a mask from the normally rendered text
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(image),
                                        CGImageGetHeight(image),
                                        CGImageGetBitsPerComponent(image),
                                        CGImageGetBitsPerPixel(image),
                                        CGImageGetBytesPerRow(image),
                                        CGImageGetDataProvider(image),
                                        CGImageGetDecode(image),
                                        CGImageGetShouldInterpolate(image));
    CFRelease(image);
    image = NULL;
    
    // wipe the slate clean
    CGContextClearRect(context, rect);
    CGContextSaveGState(context);
    CGContextClipToMask(context, rect, mask);
    CFRelease(mask);
    mask = NULL;
    
    [self drawBackgroundInRect:rect];
    
    CGContextRestoreGState(context);
}

- (void)drawBackgroundInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextFillRect(context, rect);
}

- (void)setText:(NSString *)text {
    
    NSString *textToDisplay = [text uppercaseString];
    
    // Paragraph style.
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    // String attributes
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       kFont, NSFontAttributeName,
                                       [UIColor blackColor], NSForegroundColorAttributeName,
//                                       paragraphStyle, NSParagraphStyleAttributeName,
                                       nil];
    
    NSAttributedString *titleDisplay = [[NSAttributedString alloc] initWithString:textToDisplay attributes:attributes];
    self.label.attributedText = titleDisplay;
    CGSize labelSize = [self.label sizeThatFits:self.availableBounds];
    
    // Update own frame.
    self.label.frame = CGRectMake(kInsets.left, kInsets.top, labelSize.width, labelSize.height);
    self.frame = CGRectMake(0.0,
                            0.0,
                            kInsets.left + labelSize.width + kInsets.right,
                            kInsets.top + labelSize.height + kInsets.bottom);
    
    // Redraw.
    [self setNeedsDisplay];
}

@end
