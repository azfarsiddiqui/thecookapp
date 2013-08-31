//
//  RecipeShareViewController.m
//  Cook
//
//  Created by Gerald Kim on 31/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeShareViewController.h"
#import "ViewHelper.h"
#import "CKRecipe.h"
#import "CKUser.h"
#import "AppHelper.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>

@interface RecipeShareViewController ()

@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, weak) id<RecipeShareViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *facebookShareButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterShareButton;
@property (weak, nonatomic) IBOutlet UIButton *mailShareButton;
@property (weak, nonatomic) IBOutlet UIButton *msgShareButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSURL *shareURL;

@end

@implementation RecipeShareViewController

#define kUnderlayMaxAlpha   0.7
#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeShareViewControllerDelegate>)delegate {
    if (self = [super  initWithNibName:@"RecipeShareViewController" bundle:nil]) {
        self.currentUser = [CKUser currentUser];
        self.recipe = recipe;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kUnderlayMaxAlpha];
    [self.view addSubview:self.closeButton];
    
    // Attach actions to buttons
	[self.facebookShareButton addTarget:self action:@selector(facebookShareTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property getters

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_close_dark.png"]
                                            target:self
                                          selector:@selector(closeTapped:)];
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

- (NSURL *)shareURL
{
    if (self.recipe)
        return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[AppHelper configValueForKey:@"COOK_SHARE_BASE_URL"], self.recipe.objectId]];
    else
        return nil;
}

#pragma mark - Button actions and handlers

- (void)closeTapped:(id)sender {
    [self.delegate recipeShareViewControllerCloseRequested];
}

- (void)facebookShareTapped:(id)sender {
    DLog(@"Share URL: %@", self.shareURL);
    // Add in checks here?
    [self shareFacebook];
}

#pragma mark - Sharers

- (void)shareFacebook
{
    BOOL displayedOSDialog = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self initialText:nil image:nil url:self.shareURL handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
        if (error) {
            DLog(@"Saved to FAcebook");
        } else {
            DLog(@"Successfully shared to Facebook");
        }
    }];
    if (displayedOSDialog)
        return;
    
    BOOL displayedFBAppDialog = [FBDialogs presentShareDialogWithLink:self.shareURL handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        if (error) {
            DLog(@"Saved to FAcebook");
        } else {
            DLog(@"Successfully shared to Facebook");
        }
    }];
    if (displayedFBAppDialog)
        return;
    
    NSDictionary *webParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Cook", @"name",
                                   @"Cook is awesome", @"caption",
                                   @"Info about recipe", @"description",
                                   self.shareURL.absoluteString, @"link",
                                   nil];
    [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:webParameters handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        if (error) {
            DLog(@"Saved to FAcebook");
        } else {
            DLog(@"Successfully shared to Facebook");
        }
    }];
}

@end
