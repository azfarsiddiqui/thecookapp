//
//  EditIllustrationViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IllustrationViewControllerDelegate

- (void)illustrationSelected:(NSString *)illustration;

@end

@interface IllustrationViewController : UICollectionViewController

@property (nonatomic, strong) NSString *illustration;

- (id)initWithIllustration:(NSString *)illustration cover:(NSString *)cover
                  delegate:(id<IllustrationViewControllerDelegate>)delegate;
- (void)changeCover:(NSString *)cover;

@end
