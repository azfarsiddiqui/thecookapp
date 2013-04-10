//
//  RecipeViewController.m
//  RecipeViewPrototype
//
//  Created by Jeff Tan-Ang on 9/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeViewController.h"
#import "CKRecipe.h"
#import "ViewHelper.h"

typedef enum {
	PhotoWindowHeightMin,
	PhotoWindowHeightMid,
	PhotoWindowHeightMax,
	PhotoWindowHeightFullScreen,
} PhotoWindowHeight;

@interface RecipeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CKRecipe *recipe;

@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *windowView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) PhotoWindowHeight photoWindowHeight;
@property (nonatomic, assign) PhotoWindowHeight previousPhotoWindowHeight;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation RecipeViewController

#define kWindowMinHeight        70.0
#define kWindowMidHeight        260.0
#define kWindowMinSnapOffset    175.0
#define kWindowMaxSnapOffset    400.0
#define kWindowBounceOffset     20.0

#define kHeaderHeight           210.0
#define kContentMaxHeight       468.0
#define kContentCellId          @"kContentCellId"
#define kWindowSection          0
#define kContentSection         1

#define kButtonInsets  UIEdgeInsetsMake(15.0, 20.0, 15.0, 20.0)

- (id)initWithRecipe:(CKRecipe *)recipe {
    if (self = [super init]) {
        self.recipe = recipe;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    [self initContentContainerView];
    [self initHeaderView];
    [self initTableView];
    [self initBackgroundImageView];
    [self updateButtons];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"Content Offset: %@", NSStringFromCGPoint(scrollView.contentOffset));
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContentCellId forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.text = @"Some description about this recipe.";
    contentLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [contentLabel sizeToFit];
    contentLabel.frame = CGRectMake(floorf((cell.contentView.bounds.size.width - contentLabel.frame.size.width) / 2.0),
                                    10.0,
                                    contentLabel.frame.size.width,
                                    contentLabel.frame.size.height);
    [cell.contentView addSubview:contentLabel];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kContentMaxHeight;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Unselectable.
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Lazy getters.

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_white.png"]
                                            target:self
                                          selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_closeButton setFrame:CGRectMake(kButtonInsets.left,
                                          kButtonInsets.top,
                                          _closeButton.frame.size.width,
                                          _closeButton.frame.size.height)];
    }
    return _closeButton;
}

#pragma mark - Private methods

- (void)initPanGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.view];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self panSnapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGPoint)translation {
    CGFloat dragRatio = 0.5;
    CGFloat panOffset = ceilf(translation.y * dragRatio);
    CGRect contentFrame = self.contentContainerView.frame;
    contentFrame.origin.y += panOffset;
    
    if (contentFrame.origin.y <= kWindowMinHeight) {
        contentFrame.origin.y = kWindowMinHeight;
    }

    self.contentContainerView.frame = contentFrame;
}

- (void)panSnapIfRequired {
    CGRect contentFrame = self.contentContainerView.frame;
    PhotoWindowHeight photoWindowHeight = PhotoWindowHeightMid;
    
    if (contentFrame.origin.y <= kWindowMinSnapOffset) {
        
        // Collapse photo to min height.
        photoWindowHeight = PhotoWindowHeightMin;
        
    } else if (contentFrame.origin.y > kWindowMaxSnapOffset) {
        
        // Expand photo.
        photoWindowHeight = PhotoWindowHeightMax;
        
    } else {
        
        // Restore to default mid.
        photoWindowHeight = PhotoWindowHeightMid;
    }
    
    // Snap animation.
    [self snapContentToPhotoWindowHeight:photoWindowHeight];
}

- (void)snapContentToPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight {
    CGFloat snapDuration = 0.15;
    CGFloat bounceDuration = 0.2;
    
    // Remember previous/current state.
    self.previousPhotoWindowHeight = self.photoWindowHeight;
    self.photoWindowHeight = photoWindowHeight;
    
    // Target contentFrame to snap to.
    CGRect contentFrame = [self contentFrameForPhotoWindowHeight:photoWindowHeight];
    
    // Figure out the required bounce in the same direction.
    CGFloat bounceOffset = kWindowBounceOffset;
    bounceOffset *= (self.photoWindowHeight > self.previousPhotoWindowHeight) ? 1.0 : -1.0;
    CGRect bounceFrame = contentFrame;
    bounceFrame.origin.y += bounceOffset;
    
    // Animate to the contentFrame via a bounce.
    [UIView animateWithDuration:snapDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.contentContainerView.frame = bounceFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         // Rest on the target contentFrame.
                         [UIView animateWithDuration:bounceDuration
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.contentContainerView.frame = contentFrame;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              // Update buttons when toggling between fullscreen modes.
                                              if (self.previousPhotoWindowHeight == PhotoWindowHeightFullScreen
                                                  || self.photoWindowHeight == PhotoWindowHeightFullScreen) {
                                                  [self updateButtons];
                                              }
                                          }];
                     }];
}

- (CGRect)contentFrameForPhotoWindowHeight:(PhotoWindowHeight)photoWindowHeight {
    CGRect contentFrame = self.contentContainerView.frame;
    switch (photoWindowHeight) {
        case PhotoWindowHeightMin:
            contentFrame.origin.y = kWindowMinHeight;
            break;
        case PhotoWindowHeightMid:
            contentFrame.origin.y = kWindowMidHeight;
            break;
        case PhotoWindowHeightMax:
            contentFrame.origin.y = self.view.bounds.size.height - self.headerView.frame.size.height;
            break;
        case PhotoWindowHeightFullScreen:
            contentFrame.origin.y = self.view.bounds.size.height;
            break;
        default:
            contentFrame.origin.y = kWindowMidHeight;
            break;
    }
    return contentFrame;
}

- (void)initContentContainerView {
    UIView *contentContainerView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                            kWindowMidHeight,
                                                                            self.view.bounds.size.width,
                                                                            self.view.bounds.size.height - kWindowMidHeight)];
    contentContainerView.backgroundColor = [UIColor whiteColor];
    contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:contentContainerView];
    self.contentContainerView = contentContainerView;
    
    // Register pan on the content container.
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [contentContainerView addGestureRecognizer:panGesture];
    
    self.previousPhotoWindowHeight = PhotoWindowHeightMid;
    self.photoWindowHeight = PhotoWindowHeightMid;
}

- (void)initHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(self.contentContainerView.bounds.origin.x,
                                                                  self.contentContainerView.bounds.origin.y,
                                                                  self.contentContainerView.bounds.size.width,
                                                                  kHeaderHeight)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    headerView.backgroundColor = [UIColor lightGrayColor];
    [self.contentContainerView addSubview:headerView];
    self.headerView = headerView;
    
    // Register tap on headerView for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
    [headerView addGestureRecognizer:tapGesture];
}

- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.contentContainerView.bounds.origin.x,
                                                                           self.headerView.frame.origin.y + self.headerView.frame.size.height,
                                                                           self.contentContainerView.bounds.size.width,
                                                                           self.contentContainerView.bounds.size.height - self.headerView.frame.size.height)];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.userInteractionEnabled = NO;
    [self.contentContainerView addSubview:tableView];
    self.tableView = tableView;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kContentCellId];
}

- (void)initBackgroundImageView {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:nil];
    backgroundImageView.userInteractionEnabled = YES;
    backgroundImageView.backgroundColor = [UIColor darkGrayColor];
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:backgroundImageView belowSubview:self.contentContainerView];
    self.backgroundImageView = backgroundImageView;
    
    // Register tap on headerView for tap expand.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTapped:)];
    [backgroundImageView addGestureRecognizer:tapGesture];
}

- (void)headerTapped:(UITapGestureRecognizer *)tapGesture {
    PhotoWindowHeight photoWindowHeight = PhotoWindowHeightMid;
    switch (self.photoWindowHeight) {
        case PhotoWindowHeightMin:
            photoWindowHeight = PhotoWindowHeightMid;
            break;
        case PhotoWindowHeightMid:
            photoWindowHeight = PhotoWindowHeightMin;
            break;
        case PhotoWindowHeightMax:
            photoWindowHeight = PhotoWindowHeightMid;
            break;
        default:
            break;
    }
    [self snapContentToPhotoWindowHeight:photoWindowHeight];
}

- (void)windowTapped:(UITapGestureRecognizer *)tapGesture {
    PhotoWindowHeight photoWindowHeight = PhotoWindowHeightFullScreen;
    switch (self.photoWindowHeight) {
        case PhotoWindowHeightFullScreen:
            photoWindowHeight = self.previousPhotoWindowHeight;
            break;
        default:
            photoWindowHeight = photoWindowHeight;
            break;
    }
    
    [self snapContentToPhotoWindowHeight:photoWindowHeight];
}

- (void)updateButtons {
    if (self.editMode) {
        self.cancelButton.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        [self.backgroundImageView addSubview:self.cancelButton];
        [self.backgroundImageView addSubview:self.saveButton];
    } else {
        self.closeButton.alpha = 0.0;
        self.editButton.alpha = 0.0;
        self.shareButton.alpha = 0.0;
        [self.backgroundImageView addSubview:self.closeButton];
        [self.backgroundImageView addSubview:self.editButton];
        [self.backgroundImageView addSubview:self.shareButton];
    }
    
    // Buttons are hidden on full screen mode only.
    CGFloat buttonsVisibleAlpha = (self.photoWindowHeight == PhotoWindowHeightFullScreen) ? 0.0 : 1.0;
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.closeButton.alpha = self.editMode ? 0.0 : buttonsVisibleAlpha;
                         self.editButton.alpha = self.editMode ? 0.0 : buttonsVisibleAlpha;
                         self.shareButton.alpha = self.editMode ? 0.0 : buttonsVisibleAlpha;
                         self.cancelButton.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                         self.saveButton.alpha = self.editMode ? buttonsVisibleAlpha : 0.0;
                     }
                     completion:^(BOOL finished)  {
                         if (self.editMode) {
                             [self.closeButton removeFromSuperview];
                             [self.editButton removeFromSuperview];
                             [self.shareButton removeFromSuperview];
                         } else {
                             [self.cancelButton removeFromSuperview];
                             [self.saveButton removeFromSuperview];
                         }
                     }];
}

- (void)closeTapped:(id)sender {
    DLog();
}

@end
