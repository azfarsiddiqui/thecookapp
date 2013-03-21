//
//  EditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 3/21/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "EditingViewController.h"
#import "ViewHelper.h"

#define kOverlayAlpha           0.7
#define kEnableFadeDuration     0.1
#define kEnableScaleDuration    0.2
#define kDisableScaleDuration   0.2
#define kDisableFadeDuration    0.1
#define kTargetMidAlpha         1.0
#define kTargetViewDuration     0.1

#define kDefaultContentViewInsets  UIEdgeInsetsMake(100.0f,100.0f,100.0f,100.0f)
#define kButtonEdgeInsets   UIEdgeInsetsMake(15.0,20.0f,0,50.0f)
#define kContentViewBackgroundColor [UIColor blackColor]

@interface EditingViewController ()
@property (nonatomic, assign) BOOL saveMode;
@property (nonatomic, assign) BOOL keyboardVisible;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *transparentView;
@end

@implementation EditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Public methods
- (id)initWithDelegate:(id<EditingViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.contentViewInsets = kDefaultContentViewInsets;
    }
    return self;
    
}

- (id)initWithDelegate:(id<EditingViewControllerDelegate>)delegate sourceEditingView:(CKEditableView *)sourceEditingView {
    if (self = [self initWithDelegate:delegate]) {
        self.sourceEditingView = sourceEditingView;
        self.contentViewInsets = kDefaultContentViewInsets;
    }
    return self;
}

- (void)enableEditing:(BOOL)enable completion:(void (^)())completion {
    
    CGRect endDisplayFrame = CGRectMake(self.contentViewInsets.left,
                                        self.contentViewInsets.top,
                                        self.view.bounds.size.width - self.contentViewInsets.left - self.contentViewInsets.right,
                                        self.view.bounds.size.height - self.contentViewInsets.top - self.contentViewInsets.bottom);
    
    CGRect adjustForContentInsetsFrame =   CGRectMake(self.sourceEditingView.frame.origin.x,
                                                      self.sourceEditingView.frame.origin.y + self.sourceEditingView.editButtonOffset.height,
                                                      self.sourceEditingView.frame.size.width - self.sourceEditingView.editButtonOffset.width,
                                                      self.sourceEditingView.frame.size.height- self.sourceEditingView.editButtonOffset.height);
    if (enable) {
        UIView *overlayView = [[UIView alloc]initWithFrame:self.view.bounds];
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.0f;
        self.overlayView = overlayView;
        [self.view addSubview:overlayView];
        
        //Register tap for dismiss.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapped:)];
        [overlayView addGestureRecognizer:tapGesture];
        [self.view sendSubviewToBack:overlayView];
        
        // If we have a source editing view, then prepare for it to be transitioned into edit mode.
        if (self.sourceEditingView) {
            // Create the target editing view and remember its intended frame, then
            self.contentView = [[UIView alloc]initWithFrame:CGRectZero];
            self.contentView.backgroundColor = kContentViewBackgroundColor;
            self.contentView.alpha = 0.0f;
            [self.view addSubview:self.contentView];
            
            // Now get the frame of the source relative to the overlay.
            CGRect relativeFrame = [self.sourceEditingView.superview convertRect:adjustForContentInsetsFrame toView:self.view];
            self.contentView.frame = relativeFrame;
        }
    }
    
    // Inform of editing appear.
    [self editingViewWillAppear:enable];
    
    // Fade overlay.
    [UIView animateWithDuration:enable ? kEnableFadeDuration + kEnableScaleDuration : kDisableScaleDuration + kDisableFadeDuration
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         // Fade in/out the overlay.
                         self.overlayView.alpha = enable ? kOverlayAlpha : 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    if (enable) {
        [UIView animateWithDuration:kEnableFadeDuration
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             // First fade in/out the source and target.
                             self.sourceEditingView.alpha = 0.0;
                             self.contentView.alpha = kTargetMidAlpha;
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:kEnableScaleDuration
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  // Scale the target to its intended frame.
                                                  self.contentView.frame = endDisplayFrame;
                                                  self.contentView.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  [self editingViewDidAppear:YES];
                                                  self.targetEditingView = [self createTargetEditingView];
                                                  self.targetEditingView.alpha = 0.0f;
                                                  [self.view addSubview:self.targetEditingView];

                                                  [UIView animateWithDuration:kTargetViewDuration
                                                                        delay:0.0
                                                                      options:UIViewAnimationOptionCurveEaseIn
                                                                   animations:^{
                                                                       self.targetEditingView.alpha = 1.0f;
                                                                       self.contentView.backgroundColor = [UIColor clearColor];
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       [self addDoneButton];
                                                                   }];
                                              }];
                         }];
    } else {
        
        [UIView animateWithDuration:kTargetViewDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             //fade out targetView
                             self.targetEditingView.alpha = 0.0f;
                             self.contentView.backgroundColor = kContentViewBackgroundColor;
                         }
                         completion:^(BOOL finished) {
                             [self.targetEditingView removeFromSuperview];
                             [UIView animateWithDuration:kDisableScaleDuration
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  self.contentView.frame = [self.sourceEditingView.superview convertRect:adjustForContentInsetsFrame toView:self.view];
                                                  self.contentView.alpha = kTargetMidAlpha;
                                              }
                                              completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:kDisableFadeDuration
                                                                        delay:0.0
                                                                      options:UIViewAnimationCurveEaseIn
                                                                   animations:^{
                                                                       self.contentView.alpha = 0.0;
                                                                       self.sourceEditingView.alpha = 1.0;
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       [self editingViewDidAppear:NO];
                                                                   }];
                                              }];
                         }];
    }
}

- (UIView *)createTargetEditingView {
    
    CGRect targetViewFrame = CGRectMake(self.contentViewInsets.left,
                                      self.contentViewInsets.top,
                                      self.view.bounds.size.width - self.contentViewInsets.left - self.contentViewInsets.right,
                                      self.view.bounds.size.height - self.contentViewInsets.top - self.contentViewInsets.bottom);
    return [[UIView alloc] initWithFrame:targetViewFrame];
}

- (void)editingViewWillAppear:(BOOL)appear {
    [self.delegate editingViewWillAppear:appear];
}

- (void)editingViewDidAppear:(BOOL)appear {
    [self.delegate editingViewDidAppear:appear];
}

- (void)performSave {
    self.saveMode = NO;
    [self enableEditing:NO completion:NULL];
}

#pragma mark - Private methods
- (void)editingViewKeyboardWillAppear:(BOOL)appear keyboardFrame:(CGRect)keyboardFrame {
    // Subclasses to implement.
    self.keyboardVisible = appear;
}

- (void)overlayTapped:(UITapGestureRecognizer *)tapGesture {
    [self doneTapped];
}

- (void)doneTapped {
    
    self.saveMode = YES;
    
    // If keyboard was visible, dismiss it first.
    if (self.keyboardVisible) {
        [self.view endEditing:YES];
        return;
    }
    
    // Perform save
    [self performSave];
}

- (UIButton *)doneButton {
    if (_doneButton == nil) {
        _doneButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                           target:self selector:@selector(doneTapped)];
    }
    return _doneButton;
}

-(void)addDoneButton
{
    UIButton *doneButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                                target:self selector:@selector(doneTapped)];
    
    doneButton.frame = CGRectMake(self.view.frame.size.width - kButtonEdgeInsets.right,
                                  kButtonEdgeInsets.top,
                                  doneButton.frame.size.width,
                                  doneButton.frame.size.height);
    [self.view addSubview:doneButton];
}

#pragma mark - System Notification events
- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self editingViewKeyboardWillAppear:YES keyboardFrame:keyboardFrame];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self editingViewKeyboardWillAppear:NO keyboardFrame:keyboardFrame];
    
    if (self.saveMode) {
        [self performSave];
    }
}



@end
