//
//  BookSocialLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookSocialLayoutDelegate <NSObject>

- (void)bookSocialLayoutDidFinish;
- (NSString *)bookSocialCommentAtIndex:(NSInteger)commentIndex;

@end

@interface BookSocialLayout : UICollectionViewLayout

+ (NSInteger)commentsSection;
+ (NSInteger)likesSection;

- (id)initWithDelegate:(id<BookSocialLayoutDelegate>)delegate;

@end
