//
//  EditBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IllustrationBookCellDelegate <NSObject>

- (UIImage *)imageForIllustration:(NSString *)illustration size:(CGSize)size;
- (UIImage *)imageForCover:(NSString *)cover size:(CGSize)size;

@end

@interface IllustrationBookCell : UICollectionViewCell

@property (nonatomic, weak) id<IllustrationBookCellDelegate> delegate;

+ (CGSize)cellSize;

- (void)setCover:(NSString *)cover;
- (void)setIllustration:(NSString *)illustration;

@end
