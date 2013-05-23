//
//  CKUIHelper.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//  User Interface helper for creation of user interface element
//

#import <QuartzCore/QuartzCore.h>
#import "ViewHelper.h"
#import "AppHelper.h"

@implementation ViewHelper

+ (UIButton *)okButtonWithTarget:(id)target selector:(SEL)selector {
    return [self buttonWithImage:[UIImage imageNamed:@"cook_btns_okay.png"]
                   selectedImage:[UIImage imageNamed:@"cook_btns_okay_onpress.png"]
                          target:target selector:selector];
}

+ (UIButton *)cancelButtonWithTarget:(id)target selector:(SEL)selector {
    return [self buttonWithImage:[UIImage imageNamed:@"cook_btns_cancel.png"]
                   selectedImage:[UIImage imageNamed:@"cook_btns_cancel_onpress.png"]
                          target:target selector:selector];
}

+ (UIButton *)deleteButtonWithTarget:(id)target selector:(SEL)selector {
    return [self buttonWithImage:[UIImage imageNamed:@"cook_btns_delete.png"]
                   selectedImage:[UIImage imageNamed:@"cook_btns_delete_onpress.png"]
                          target:target selector:selector];
}

+ (UIButton *)buttonWithTitle:(NSString*)title backgroundImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    UIButton *button = [self buttonWithImage:image target:target selector:selector];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    button.userInteractionEnabled = (target != nil && selector != nil);
    button.autoresizingMask = UIViewAutoresizingNone;
    return button;
}

+ (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    button.userInteractionEnabled = (target != nil && selector != nil);
    button.autoresizingMask = UIViewAutoresizingNone;
    return button;
}

+(UIButton *)buttonWithImagePrefix:(NSString *)imagePrefix target:(id)target selector:(SEL)selector
{
    UIImage *offImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_off.png",imagePrefix]];
    UIImage *onImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_on.png",imagePrefix]];
    UIButton *button = [self buttonWithImage:offImage target:target selector:selector];
    [button setBackgroundImage:onImage forState:UIControlStateSelected];
    [button setBackgroundImage:onImage forState:UIControlStateHighlighted];
    return button;
}

+ (CGSize)bookSize {
    return CGSizeMake(300.0, 438.0);
}

+ (CGFloat)singleLineHeightForFont:(UIFont *)font {
    return [@"A" sizeWithFont:font constrainedToSize:[ViewHelper bookSize] lineBreakMode:NSLineBreakByTruncatingTail].height;
}

+ (CGSize)screenSize {
    return [[AppHelper sharedInstance] rootView].bounds.size;
}

+(NSString*)formatAsHoursSeconds:(float)timeInSeconds
{
    NSString *result = nil;
    float hours = floor(timeInSeconds/60/60);
    float minutes = (timeInSeconds - hours*60*60)/60;
    if (minutes > 1.0f) {
        result = [NSString stringWithFormat:@"%02.0f:%02.0f", hours,minutes];
    } else {
        result = [NSString stringWithFormat:@"%02.0f:00", hours];
    }
    
    return result;
}


+(void) adjustScrollContentSize:(UIScrollView*)scrollView forHeight:(float)height
{
   scrollView.contentSize = height > scrollView.frame.size.height ?
    CGSizeMake(scrollView.frame.size.width, height) :
    CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
}

+(CGPoint)centerPointForSmallerView:(UIView *)smallerView inLargerView:(UIView *)largerView
{
    return CGPointMake(floorf(0.5f*largerView.frame.size.width) - floorf(0.5f*smallerView.frame.size.width),
    floorf(0.5f*largerView.frame.size.height) - floorf(0.5f*smallerView.frame.size.height));
}

+ (UIImage *)imageWithView:(UIView *)view {
    return [self imageWithView:view opaque:YES];
}

+ (UIImage *)imageWithView:(UIView *)view opaque:(BOOL)opaque {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - UITextField methods

+ (void)setCaretOnFrontForInput:(UITextField *)input {
    [self selectTextForInput:input atRange:NSMakeRange(0, 0)];
}

+ (void)selectTextForInput:(UITextField *)input atRange:(NSRange)range {
    UITextPosition *start = [input positionFromPosition:[input beginningOfDocument] offset:range.location];
    UITextPosition *end = [input positionFromPosition:start offset:range.length];
    [input setSelectedTextRange:[input textRangeFromPosition:start toPosition:end]];
}
@end
