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

#define kMinSize    CGSizeMake(115.0, 97.0)
#define kMaxSize    CGSizeMake(115.0, 137.0)

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
        shadowView.frame = coverButton.frame;
        [self addSubview:shadowView];
        [self.shadows addObject:shadowView];
        
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
                             UIView *shadowView = [self.shadows objectAtIndex:buttonIndex];
                             CGRect frame = button.frame;
                             
                             if (buttonIndex == coverIndex) {
                                 frame.size.height = kMaxSize.height;
                             } else {
                                 frame.size.height = kMinSize.height;
                             }
                             
                             button.frame = frame;
                             shadowView.frame = frame;
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                         NSString *selectedCover = [self.availableCovers objectAtIndex:coverIndex];
                         [self.delegate coverPickerSelected:selectedCover];
                     }];
    
}

@end
