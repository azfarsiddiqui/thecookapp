//
//  EditIllustrationViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IllustrationPickerViewControllerDelegate

- (void)illustrationSelected:(NSString *)illustration;

@end

@interface IllustrationPickerViewController : UICollectionViewController

@property (nonatomic, strong) NSString *illustration;

- (id)initWithIllustration:(NSString *)illustration cover:(NSString *)cover
                  delegate:(id<IllustrationPickerViewControllerDelegate>)delegate;
- (void)changeCover:(NSString *)cover;
- (void)scrollToIllustration;

@end
