//
//  CKPhotoFilterSliderView.m
//  CKPhotoPickerViewController
//
//  Created by Gerald Kim on 2/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPhotoFilterSliderView.h"

@interface CKPhotoFilterSliderView ()

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImageView *sliderCurrentState;
@property (nonatomic, strong) UIImageView *sliderNextState;

@property (nonatomic, strong) NSMutableArray *filterArray;

@end

@implementation FilterObject
@end

@implementation CKPhotoFilterSliderView

- (id)initWithDelegate:(id<CKNotchSliderViewDelegate>)delegate {
    if (self = [super initWithNumNotches:6 delegate:delegate]) {
        [self loadTitleLabels];
    }
    return self;
}

- (NSMutableArray *)filterArray {
    if (!_filterArray)
    {
        _filterArray = [NSMutableArray array];
        
        //NOTE: It is assumed that the index of items in this array match the CKPhotoFilterType values
        
        { //CKPhotoFilterTypeNone
            FilterObject *noneFilterObj = [[FilterObject alloc] init];
            noneFilterObj.title = @"NONE";
            noneFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_none"];
            noneFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_none"];
            [_filterArray addObject:noneFilterObj];
        }
        { //CKPhotoFilterOutdoors
            FilterObject *outdoorsFilterObj = [[FilterObject alloc] init];
            outdoorsFilterObj.title = @"OUTDOORS";
            outdoorsFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_outdoor"];
            outdoorsFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_outdoor"];
            [_filterArray addObject:outdoorsFilterObj];
        }
        { //CKPhotoFilterVibrant
            FilterObject *vibrantFilterObj = [[FilterObject alloc] init];
            vibrantFilterObj.title = @"VIBRANT";
            vibrantFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_bright"];
            vibrantFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_bright"];
            [_filterArray addObject:vibrantFilterObj];
        }
        { //CKPhotoFilterWarm
            FilterObject *warmFilterObj = [[FilterObject alloc] init];
            warmFilterObj.title = @"WARM";
            warmFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_outdoor"];
            warmFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_outdoor"];
            [_filterArray addObject:warmFilterObj];
        }
        { //CKPhotoFilterCool
            FilterObject *coolFilterObj = [[FilterObject alloc] init];
            coolFilterObj.title = @"COOL";
            coolFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_indoor"];
            coolFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_indoor"];
            [_filterArray addObject:coolFilterObj];
        }
        { //CKPhotoFilterText
            FilterObject *textFilterObj = [[FilterObject alloc] init];
            textFilterObj.title = @"TEXT";
            textFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_text"];
            textFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_text"];
            [_filterArray addObject:textFilterObj];
        }
    }
    return _filterArray;
}

- (void)loadTitleLabels
{
    for (UIView *trackNotchView in self.trackNotches)
    {
        UILabel *notchTitle = [[UILabel alloc] initWithFrame:CGRectMake(trackNotchView.frame.origin.x,
                                                                        trackNotchView.frame.origin.y + 70,
                                                                        trackNotchView.frame.size.width,
                                                                        18)];
        notchTitle.text = [self titleForNotchIndex:[self.trackNotches indexOfObject:trackNotchView]];
        notchTitle.textColor = [UIColor whiteColor];
        notchTitle.textAlignment = NSTextAlignmentCenter;
        //TEMP, change to Brandon when adding back to project
        notchTitle.font = [UIFont systemFontOfSize:12];
        [self addSubview:notchTitle];
    }
}

- (UIImage *)trackImageForIndex:(NSInteger)trackIndex {
    return ((FilterObject *)[self.filterArray objectAtIndex:trackIndex]).trackImage;
}

- (UIImage *)imageForIconAtNotchIndex:(NSInteger)notchIndex
{
    return ((FilterObject *)[self.filterArray objectAtIndex:notchIndex]).iconImage;
}

- (NSString *)titleForNotchIndex:(NSInteger)notchIndex
{
    return ((FilterObject *)[self.filterArray objectAtIndex:notchIndex]).title;
}

- (UIImage *)imageForSliderSelected:(BOOL)selected {
    return selected ? [UIImage imageNamed:@"cook_customise_photo_filter_picker"] : [UIImage imageNamed:@"cook_customise_photo_filter_picker"];
}

- (void)initNotchIndex:(NSInteger)selectedNotchIndex {
    self.sliderCurrentState.alpha = 1.0;
    self.sliderNextState.alpha = 0.0;
    [self.currentNotchView addSubview:self.sliderNextState];
    [self.currentNotchView addSubview:self.sliderCurrentState];
}

- (void)selectedNotchIndex:(NSInteger)selectedNotchIndex {
    // Transitions from current slider icon to destination one
    self.sliderNextState.image = [self imageForIconAtNotchIndex:selectedNotchIndex];
    self.sliderNextState.alpha = 0.0;
    self.sliderCurrentState.alpha = 1.0;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.sliderCurrentState.alpha = 0.0;
                         self.sliderNextState.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         self.sliderCurrentState.image = [self imageForIconAtNotchIndex:selectedNotchIndex];
                         self.sliderCurrentState.alpha = 1.0;
                         self.sliderNextState.alpha = 0.0;
                         [self.delegate notchSliderView:self selectedIndex:selectedNotchIndex];
                     }];
}
//
//- (void)updateNotchSliderWithFrame:(CGRect)sliderFrame {
//    [super updateNotchSliderWithFrame:sliderFrame];
//    
//    for (NSInteger trackIndex = 0; trackIndex < [self.trackNotches count]; trackIndex++) {
//        UIImageView *trackImageView = [self.trackNotches objectAtIndex:trackIndex];
//        CGRect trackIntersection = CGRectIntersection(trackImageView.frame, sliderFrame);
//        
//        // Figure out the intersection of the slider, if fully covered, then fully visible.
//        CGFloat intersectionRatio = MIN(1.0, trackIntersection.size.width / sliderFrame.size.width);
//        self.sliderCurrentState.alpha = intersectionRatio;
//        self.sliderNextState.alpha = 1/intersectionRatio;
//    }
//    
//}
//
//- (void)slideToNotchIndex:(NSInteger)notchIndex animated:(BOOL)animated {
//    [super slideToNotchIndex:notchIndex animated:animated];
//    [self updateNotchSliderWithFrame:self.currentNotchView.frame];
//}

- (UIImageView *)sliderCurrentState {
    if (!_sliderCurrentState) {
        _sliderCurrentState = [[UIImageView alloc] initWithImage:[self imageForIconAtNotchIndex:0]];
        _sliderCurrentState.frame = (CGRect){
            floorf((self.currentNotchView.bounds.size.width - _sliderCurrentState.frame.size.width) / 2.0),
            floorf((self.currentNotchView.bounds.size.height - _sliderCurrentState.frame.size.height) / 2.0),
            _sliderCurrentState.frame.size.width,
            _sliderCurrentState.frame.size.height
        };
    }
    return _sliderCurrentState;
}
- (UIImageView *)sliderNextState {
    if (!_sliderNextState) {
        _sliderNextState = [[UIImageView alloc] initWithImage:[self imageForIconAtNotchIndex:0]];
        _sliderNextState.frame = (CGRect){
            floorf((self.currentNotchView.bounds.size.width - _sliderNextState.frame.size.width) / 2.0),
            floorf((self.currentNotchView.bounds.size.height - _sliderNextState.frame.size.height) / 2.0),
            _sliderNextState.frame.size.width,
            _sliderNextState.frame.size.height
        };
    }
    return _sliderNextState;
}

@end
