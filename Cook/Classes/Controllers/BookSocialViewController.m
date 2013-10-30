//
//  BookSocialViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 16/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookSocialViewController.h"
#import "ViewHelper.h"
#import "BookSocialLayout.h"
#import "BookSocialHeaderView.h"
#import "CKSupplementaryContainerView.h"
#import "BookCommentView.h"
#import "CKLikeView.h"
#import "CKRecipe.h"
#import "CKUser.h"

@interface BookSocialViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, weak) id<BookSocialViewControllerDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *underlayView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) CKLikeView *likeView;
@property (nonatomic, strong) BookCommentView *commentView;

@end

@implementation BookSocialViewController

#define kUnderlayMaxAlpha   0.7
#define kButtonInsets       UIEdgeInsetsMake(15.0, 20.0, 15.0, 20.0)
#define kCommentCellId      @"CommentCellId"
#define kCommentHeaderId    @"CommentHeaderId"
#define kCommentFooterId    @"CommentFooterId"
#define kLikeHeaderId       @"LikeHeaderId"

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<BookSocialViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.recipe = recipe;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.underlayView];
    [self initCollectionView];
    [self.view addSubview:self.closeButton];
    [self loadData];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    numItems = [self.comments count];
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCommentCellId forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = nil;
    if (indexPath.section == [BookSocialLayout commentsSection] && indexPath.item == 0) {
        
        BookSocialHeaderView *bookHeaderView = (BookSocialHeaderView *)[self.collectionView dequeueReusableSupplementaryViewOfKind:[BookSocialHeaderView bookSocialHeaderKind] withReuseIdentifier:kCommentHeaderId forIndexPath:indexPath];
        [bookHeaderView configureTitle:@"COMMENTS"];
        headerView = bookHeaderView;
        
    } else if (indexPath.section == [BookSocialLayout commentsSection] && indexPath.item == 1) {
        
        CKSupplementaryContainerView *bookFooterView = (CKSupplementaryContainerView *)[self.collectionView dequeueReusableSupplementaryViewOfKind:[CKSupplementaryContainerView bookSocialCommentBoxKind] withReuseIdentifier:kCommentFooterId forIndexPath:indexPath];
        [bookFooterView configureContentView:self.commentView];
        headerView = bookFooterView;
    
    } else if (indexPath.section == [BookSocialLayout likesSection]) {
        
        CKSupplementaryContainerView *bookHeaderView = (CKSupplementaryContainerView *)[self.collectionView dequeueReusableSupplementaryViewOfKind:[CKSupplementaryContainerView bookSocialLikeKind] withReuseIdentifier:kLikeHeaderId forIndexPath:indexPath];
        [bookHeaderView configureContentView:self.likeView];
        headerView = bookHeaderView;
    }
    return headerView;
}


#pragma mark - Properties

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_close_dark.png"]
                        selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_close_dark_onpress.png"]
                                            target:self
                                          selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kButtonInsets.left,
            kButtonInsets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

- (UIView *)underlayView {
    if (!_underlayView) {
        _underlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _underlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _underlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kUnderlayMaxAlpha];
    }
    return _underlayView;
}

- (CKLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[CKLikeView alloc] initWithRecipe:self.recipe darkMode:YES];
    }
    return _likeView;
}

- (BookCommentView *)commentView {
    if (!_commentView) {
        _commentView = [[BookCommentView alloc] initWithUser:[CKUser currentUser]];
    }
    return _commentView;
}

#pragma mark - Private methods

- (void)initCollectionView {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:[[BookSocialLayout alloc] init]];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    collectionView.alwaysBounceVertical = YES;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCommentCellId];
    [self.collectionView registerClass:[BookSocialHeaderView class] forSupplementaryViewOfKind:[BookSocialHeaderView bookSocialHeaderKind]
                   withReuseIdentifier:kCommentHeaderId];
    [self.collectionView registerClass:[CKSupplementaryContainerView class] forSupplementaryViewOfKind:[CKSupplementaryContainerView bookSocialCommentBoxKind]
                   withReuseIdentifier:kCommentFooterId];
    [self.collectionView registerClass:[CKSupplementaryContainerView class] forSupplementaryViewOfKind:[CKSupplementaryContainerView bookSocialLikeKind]
                   withReuseIdentifier:kLikeHeaderId];
}

- (void)loadData {
    self.comments = [NSMutableArray array];
}

- (void)closeTapped:(id)sender {
    [self.delegate bookSocialViewControllerCloseRequested];
}

@end
