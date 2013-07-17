//
//  BookAddViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookAddViewController.h"
#import "ViewHelper.h"

@interface BookAddViewController ()

@property (nonatomic, weak) id<BookAddViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *underlayView;
@property (nonatomic, strong) UIButton *recipeButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *noteButton;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation BookAddViewController

#define kUnderlayMaxAlpha   0.7

- (id)initWithDelegate:(id<BookAddViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.underlayView];
}

- (void)enable:(BOOL)enable {
    [self enable:enable completion:nil];
}

#pragma mark - Properties

- (UIView *)underlayView {
    if (!_underlayView) {
        _underlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _underlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _underlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kUnderlayMaxAlpha];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(underlayTapped:)];
        [_underlayView addGestureRecognizer:tapGesture];
    }
    return _underlayView;
}

- (UIButton *)recipeButton {
    if (!_recipeButton) {
        _recipeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_add_recipe.png"]
                                      selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_add_recipe_onpress.png"]
                                             target:self selector:@selector(buttonTapped:)];
        _recipeButton.frame = (CGRect){
            floorf((self.view.bounds.size.width - _recipeButton.frame.size.width) / 2.0),
            self.view.bounds.size.height,
            _recipeButton.frame.size.width,
            _recipeButton.frame.size.height
        };
    }
    return _recipeButton;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_add_photo.png"]
                                     selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_add_photo_onpress.png"]
                                            target:self selector:@selector(buttonTapped:)];
        _photoButton.frame = (CGRect){
            self.view.center.x - _photoButton.frame.size.width,
            self.view.bounds.size.height,
            _photoButton.frame.size.width,
            _photoButton.frame.size.height
        };
    }
    return _photoButton;
}

- (UIButton *)noteButton {
    if (!_noteButton) {
        _noteButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_add_note.png"]
                                    selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_add_note_onpress.png"]
                                           target:self selector:@selector(buttonTapped:)];
        _noteButton.frame = (CGRect){
            self.view.center.x,
            self.view.bounds.size.height,
            _noteButton.frame.size.width,
            _noteButton.frame.size.height
        };
    }
    return _noteButton;
}

#pragma mark - Private

- (void)underlayTapped:(UITapGestureRecognizer *)tapGesture {
    [self enable:NO completion:^{
        [self.delegate bookAddViewControllerCloseRequested];
    }];
}

- (void)enable:(BOOL)enable completion:(void(^)())completion {
    if (enable) {
        
        // Recipe
        [self.view addSubview:self.recipeButton];
        CGPoint recipePoint = (CGPoint){
            self.recipeButton.frame.origin.x + floorf(self.recipeButton.frame.size.width / 2.0),
            self.view.center.y - floorf(self.recipeButton.frame.size.height / 2.0) + 20.0
        };
        UISnapBehavior* recipeSnap = [[UISnapBehavior alloc] initWithItem:self.recipeButton snapToPoint:recipePoint];
        [self.animator addBehavior:recipeSnap];
        
        // Photo
        [self.view addSubview:self.photoButton];
        CGPoint photoPoint = (CGPoint){
            self.photoButton.frame.origin.x + floorf(self.photoButton.frame.size.width / 2.0),
            self.view.center.y + floorf(self.photoButton.frame.size.height / 2.0) - 10.0
        };
        UISnapBehavior* photoSnap = [[UISnapBehavior alloc] initWithItem:self.photoButton snapToPoint:photoPoint];
        [self.animator addBehavior:photoSnap];
        
        // Notes
        [self.view addSubview:self.noteButton];
        CGPoint notePoint = (CGPoint){
            self.noteButton.frame.origin.x + floorf(self.noteButton.frame.size.width / 2.0),
            self.view.center.y + floorf(self.noteButton.frame.size.height / 2.0) - 10.0
        };
        UISnapBehavior* noteSnap = [[UISnapBehavior alloc] initWithItem:self.noteButton snapToPoint:notePoint];
        [self.animator addBehavior:noteSnap];
        
    } else {
        
        [self.animator removeAllBehaviors];
        
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, self.view.bounds.size.height);
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.recipeButton.transform = translate;
                             self.photoButton.transform = translate;
                             self.noteButton.transform = translate;
                         }
                         completion:^(BOOL finished){
                             if (completion != nil) {
                                 completion();
                             }
                         }];
    }
    
}

- (void)buttonTapped:(id)sender {
    [self enable:NO completion:^{
        [self.delegate bookAddViewControllerCloseRequested];
    }];
}

@end
