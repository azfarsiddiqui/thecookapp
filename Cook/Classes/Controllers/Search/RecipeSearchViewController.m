//
//  RecipeSearchViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/03/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSearchViewController.h"
#import "AnalyticsHelper.h"
#import "ViewHelper.h"

@interface RecipeSearchViewController ()

@property (nonatomic, weak) id<RecipeSearchViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation RecipeSearchViewController

#define kContentInsets          (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }

- (id)initWithDelegate:(id<RecipeSearchViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.closeButton];
    [self loadData];
    
    [AnalyticsHelper trackEventName:kEventNotificationsView];
}

#pragma mark - Properties

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

//- (UICollectionView *)collectionView {
//    if (!_collectionView) {
//        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
//                                             collectionViewLayout:[[NotificationsFlowLayout alloc] init]];
//        _collectionView.bounces = YES;
//        _collectionView.backgroundColor = [UIColor clearColor];
//        _collectionView.showsVerticalScrollIndicator = NO;
//        _collectionView.alwaysBounceVertical = YES;
//        _collectionView.delegate = self;
//        _collectionView.dataSource = self;
//        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityId];
//        [_collectionView registerClass:[NotificationCell class] forCellWithReuseIdentifier:kCellId];
//        [_collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                   withReuseIdentifier:kHeaderCellId];
//    }
//    return _collectionView;
//}

#pragma mark - Private methods

- (void)loadData {
    
}

- (void)closeTapped:(id)sender {
    [self.delegate recipeSearchViewControllerDismissRequested];
}


@end
