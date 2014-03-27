//
//  CKSearchFieldView.h
//  CKSearchFieldView
//
//  Created by Jeff Tan-Ang on 13/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKSearchFieldViewDelegate <NSObject>

- (UIFont *)searchFieldTextFont;
- (BOOL)searchFieldShouldFocus;
- (BOOL)searchFieldViewSearchIconTappable;
- (void)searchFieldViewSearchIconTapped;
- (void)searchFieldViewSearchByText:(NSString *)text;
- (void)searchFieldViewClearRequested;
- (NSString *)searchFieldViewPlaceholderText;

@end

@interface CKSearchFieldView : UIView

@property (nonatomic, strong) UIImageView *backgroundView;

- (id)initWithWidth:(CGFloat)width delegate:(id<CKSearchFieldViewDelegate>)delegate;
- (void)focus:(BOOL)focus;
- (void)clearSearch;

@end
