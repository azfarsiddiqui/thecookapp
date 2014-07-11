//
//  CKPhotoFilterSliderView.m
//  CKPhotoPickerViewController
//
//  Created by Gerald Kim on 2/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPhotoFilterSliderView.h"
#import "CKActivityIndicatorView.h"

@interface CKPhotoFilterSliderView ()

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImageView *sliderCurrentState;

@property (nonatomic, strong) NSMutableArray *filterArray;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;

@end

@implementation FilterObject
@end

@implementation CKPhotoFilterSliderView

- (id)initWithDelegate:(id<CKNotchSliderViewDelegate>)delegate {
    if (self = [super initWithNumNotches:8 delegate:delegate]) {
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
            noneFilterObj.title = NSLocalizedString(@"NONE", nil);
            noneFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_none"];
            noneFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_none"];
            [_filterArray addObject:noneFilterObj];
        }
        { //CKPhotoFilterAuto
            FilterObject *autoFilterObj = [[FilterObject alloc] init];
            autoFilterObj.title = NSLocalizedString(@"AUTO", nil);
            autoFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_auto"];
            autoFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_auto"];
            [_filterArray addObject:autoFilterObj];
        }
        { //CKPhotoFilterOutdoors
            FilterObject *outdoorsFilterObj = [[FilterObject alloc] init];
            outdoorsFilterObj.title = NSLocalizedString(@"OUTDOORS", nil);
            outdoorsFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_outdoor"];
            outdoorsFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_outdoor"];
            [_filterArray addObject:outdoorsFilterObj];
        }
        { //CKPhotoFilterIndoors
            FilterObject *indoorFilterObj = [[FilterObject alloc] init];
            indoorFilterObj.title = NSLocalizedString(@"INDOOR", nil);
            indoorFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_indoor"];
            indoorFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_indoor"];
            [_filterArray addObject:indoorFilterObj];
        }
        { //CKPhotoFilterVibrant
            FilterObject *vibrantFilterObj = [[FilterObject alloc] init];
            vibrantFilterObj.title = NSLocalizedString(@"VIBRANT", nil);
            vibrantFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_vibrant"];
            vibrantFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_vibrant"];
            [_filterArray addObject:vibrantFilterObj];
        }
        { //CKPhotoFilterWarm
            FilterObject *warmFilterObj = [[FilterObject alloc] init];
            warmFilterObj.title = NSLocalizedString(@"WARM", nil);
            warmFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_warm"];
            warmFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_warm"];
            [_filterArray addObject:warmFilterObj];
        }
        { //CKPhotoFilterCool
            FilterObject *coolFilterObj = [[FilterObject alloc] init];
            coolFilterObj.title = NSLocalizedString(@"COOL", nil);
            coolFilterObj.trackImage = [UIImage imageNamed:@"cook_customise_photo_filter_bg_cool"];
            coolFilterObj.iconImage = [UIImage imageNamed:@"cook_customise_photo_filter_icon_cool"];
            [_filterArray addObject:coolFilterObj];
        }
        { //CKPhotoFilterText
            FilterObject *textFilterObj = [[FilterObject alloc] init];
            textFilterObj.title = NSLocalizedString(@"TEXT", nil);
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
        notchTitle.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:14.0];
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
    [self.currentNotchView addSubview:self.sliderCurrentState];
    [self.currentNotchView addSubview:self.activityView];
    [super initNotchIndex:selectedNotchIndex];
}

- (void)selectedNotchIndex:(NSInteger)selectedNotchIndex {
    // Transitions from current slider icon to destination one
    self.sliderCurrentState.alpha = 0.0;
    self.sliderCurrentState.image = [self imageForIconAtNotchIndex:selectedNotchIndex];
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.sliderCurrentState.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         [self.delegate notchSliderView:self selectedIndex:selectedNotchIndex];
                     }];
}

- (void)startFilterLoading
{
    [self.activityView startAnimating];
    self.sliderCurrentState.hidden = YES;
}

- (void)stopFilterLoading
{
    [self.activityView stopAnimating];
    self.sliderCurrentState.hidden = NO;
}

- (void)selectNotch:(NSInteger)notch
{
    [self startFilterLoading];
    [super selectNotch:notch];
}

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
- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleTinyDarkBlue];
        _activityView.hidesWhenStopped = YES;
        _activityView.frame = (CGRect){
            floorf((self.currentNotchView.bounds.size.width - _activityView.frame.size.width) / 2.0),
            floorf((self.currentNotchView.bounds.size.height - _activityView.frame.size.height) / 2.0) - 8,
            _activityView.frame.size.width,
            _activityView.frame.size.height
        };
    }
    return _activityView;
}

@end
