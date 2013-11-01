//
//  SocialMediaActionHeader.h
//  Cook
//
//  Created by Gerald Kim on 31/10/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SectionSelectBlock)();

@interface SocialMediaActionHeader : UICollectionReusableView

@property (nonatomic, copy) SectionSelectBlock completionBlock;

@end
