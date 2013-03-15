//
//  EditingOverlayView.m
//  Cook
//
//  Created by Jonny Sagorin on 3/15/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "EditingOverlayView.h"
#import "ViewHelper.h"

@interface EditingOverlayView()
@property(nonatomic,assign) CGRect transparentOverlayRect;
@property(nonatomic,assign) id<EditingOverlayViewDelegate> editingOverlayViewDelegate;
@property(nonatomic,assign) CGFloat currentAlpha;
@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIView *leftView;
@property(nonatomic,strong) UIView *rightView;
@end
@implementation EditingOverlayView

- (id)initWithFrame:(CGRect)frame withTransparentOverlay:(CGRect)transparentOverlayRect withEditViewDelegate:(id<EditingOverlayViewDelegate>)editingOverlayViewDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.transparentOverlayRect = transparentOverlayRect;
        self.editingOverlayViewDelegate = editingOverlayViewDelegate;
        [self style];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)style
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.0;

}

-(void)viewAppeared
{
    [self drawTransparentOverlayRect];
    [self addDoneButton];
}

-(void)drawTransparentOverlayRect
{
    if (!CGRectEqualToRect(self.transparentOverlayRect, CGRectZero)) {
       NSAssert(self.transparentOverlayRect.origin.y == 0, @"currently not supported on y-axis > 0");
        DLog(@"current alpha is %f", self.alpha);
        self.currentAlpha  = self.alpha;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1.0f;
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      self.transparentOverlayRect.size.height,
                                                                      self.frame.size.width,
                                                                      self.frame.size.height-self.transparentOverlayRect.size.height)];
        bottomView.backgroundColor = [UIColor blackColor];
        bottomView.alpha = self.currentAlpha;
        self.bottomView = bottomView;
        [self addSubview:bottomView];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      self.transparentOverlayRect.origin.x,
                                                                      self.transparentOverlayRect.size.height)];
        leftView.backgroundColor = [UIColor blackColor];
        leftView.alpha = self.currentAlpha;
        self.leftView = leftView;

        [self addSubview:leftView];

        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.transparentOverlayRect.origin.x+self.transparentOverlayRect.size.width,
                                                                      0.0f,
                                                                      self.frame.size.width - self.transparentOverlayRect.origin.x+self.transparentOverlayRect.size.width,
                                                                      self.transparentOverlayRect.size.height)];
        rightView.backgroundColor = [UIColor blackColor];
        rightView.alpha = self.currentAlpha;
        self.rightView = rightView;
        [self addSubview:rightView];

    }
    
}

-(void)addDoneButton
{
        float buttonPadding = 50.0f;
        UIButton *doneButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                 target:self selector:@selector(doneTapped)];

        doneButton.frame = CGRectMake(self.frame.origin.x + self.frame.size.width - buttonPadding - floorf(0.5f*doneButton.frame.size.width),
                                           self.frame.origin.y + buttonPadding - floorf(0.5*doneButton.frame.size.height),
                                           doneButton.frame.size.width,
                                           doneButton.frame.size.height);
        [self addSubview:doneButton];
}

-(void)doneTapped
{
    //remove overlays, restore alpha
    [self.leftView removeFromSuperview];
    [self.rightView removeFromSuperview];
    [self.bottomView removeFromSuperview];

    self.backgroundColor = [UIColor blackColor];
    self.alpha = self.currentAlpha;

    [self.editingOverlayViewDelegate editOverlayViewDidRequestDone];
}
@end
