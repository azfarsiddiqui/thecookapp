//
//  CKPhotoFilterSliderView.h
//  CKPhotoPickerViewController
//
//  Created by Gerald Kim on 2/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKNotchSliderView.h"

typedef enum {
    CKPhotoFilterTypeNone = 0,
    CKPhotoFilterAuto,
    CKPhotoFilterOutdoors,
    CKPhotoFilterVibrant,
    CKPhotoFilterWarm,
    CKPhotoFilterCool,
    CKPhotoFilterText
} CKPhotoFilterType;

@interface FilterObject : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *trackImage;
@property (nonatomic, strong) UIImage *iconImage;

@end

@interface CKPhotoFilterSliderView : CKNotchSliderView

- (id)initWithDelegate:(id<CKNotchSliderViewDelegate>)delegate;

@end
