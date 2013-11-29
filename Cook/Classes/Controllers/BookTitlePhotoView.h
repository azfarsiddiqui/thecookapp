//
//  BookTitlePhotoView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 29/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

@class CKBook;

@protocol BooKTitlePhotoViewDelegate <NSObject>

- (void)bookTitlePhotoViewProfileTapped;

@end

@interface BookTitlePhotoView : UIView

- (id)initWithBook:(CKBook *)book delegate:(id<BooKTitlePhotoViewDelegate>)delegate;

@end
