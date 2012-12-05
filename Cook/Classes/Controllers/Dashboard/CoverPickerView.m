//
//  ColourPickerView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 4/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CoverPickerView.h"
#import "CKBookCover.h"
#import "ViewHelper.h"

@interface CoverPickerView ()

@property (nonatomic, assign) id<CoverPickerViewDelegate> delegate;
@property (nonatomic, strong) NSArray *availableCovers;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *shadows;
@property (nonatomic, assign) BOOL animating;

@end

@implementation CoverPickerView

#define kMinSize        CGSizeMake(67.0, 59.0)
#define kMaxSize        CGSizeMake(67.0, 101.0)

- (id)initWithCover:(NSString *)cover delegate:(id<CoverPickerViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.cover = cover;
        self.availableCovers = [CKBookCover covers];
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0.0, 0.0, [self.availableCovers count] * kMinSize.width, kMaxSize.height);
        [self initCovers];
    }
    return self;
}

#pragma mark - Private methods

- (void)initCovers {
    
    self.buttons = [NSMutableArray arrayWithCapacity:[self.availableCovers count]];
    self.shadows = [NSMutableArray arrayWithCapacity:[self.availableCovers count]];
    CGFloat offset = 0.0;
    
    // Button shadow.
    UIImage *shadowImage = [UIImage imageNamed:@"cook_customise_colours_bg.png"];
    
    for (NSString *cover in self.availableCovers) {
        
        // Button
        UIImage *coverImage = [CKBookCover thumbImageForCover:cover];
        UIButton *coverButton = [ViewHelper buttonWithImage:coverImage target:self selector:@selector(coverTapped:)];
        coverButton.frame = CGRectMake(offset, 0.0, kMinSize.width, kMinSize.height);
        [self addSubview:coverButton];
        [self.buttons addObject:coverButton];
        
        // Button shadow.
        UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadowImage];
        shadowView.frame = CGRectMake(offset + floorf((coverButton.frame.size.width - shadowView.frame.size.width) / 2.0),
                                      0.0,
                                      shadowView.frame.size.width,
                                      shadowView.frame.size.height);
        [self addSubview:shadowView];
        [self.shadows addObject:shadowView];
        DLog(@"SHADOW FRAME: %@", NSStringFromCGRect(shadowView.frame));
        
        offset += coverButton.frame.size.width;
    }
    
    // Send all shadows to the back.
    for (UIView *shadowView in self.shadows) {
        [self sendSubviewToBack:shadowView];
    }
    
    // Select the given cover.
    NSUInteger selectedIndex = [self.availableCovers indexOfObject:self.cover];
    [self selectCoverAtIndex:selectedIndex];
}

- (void)coverTapped:(id)sender {
    if (self.animating) {
        return;
    }
    
    NSUInteger coverIndex = [self.buttons indexOfObject:sender];
    [self selectCoverAtIndex:coverIndex];
}

- (void)selectCoverAtIndex:(NSUInteger)coverIndex {
    self.animating = YES;
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Unselect all buttons except the current one.
                         for (NSInteger buttonIndex = 0; buttonIndex < [self.buttons count]; buttonIndex++) {
                             UIButton *button = [self.buttons objectAtIndex:buttonIndex];
//                             button.alpha = 0.5;
                             UIView *shadowView = [self.shadows objectAtIndex:buttonIndex];
                             CGRect buttonFrame = button.frame;
                             CGRect shadowFrame = shadowView.frame;
                             if (buttonIndex == coverIndex) {
                                 buttonFrame.size.height = kMaxSize.height;
                                 shadowFrame.size.height = buttonFrame.size.height + 31.0;
                             } else {
                                 buttonFrame.size.height = kMinSize.height;
                                 shadowFrame.size.height = buttonFrame.size.height + 17.0;
                             }
                             
                             button.frame = buttonFrame;
                             shadowView.frame = shadowFrame;
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                         NSString *selectedCover = [self.availableCovers objectAtIndex:coverIndex];
                         [self.delegate coverPickerSelected:selectedCover];
                     }];
    
}

- (UIImage *)imageForCover:(NSString *)cover {
    return [[CKBookCover thumbImageForCover:cover] stretchableImageWithLeftCapWidth:0 topCapHeight:29];
}

@end
