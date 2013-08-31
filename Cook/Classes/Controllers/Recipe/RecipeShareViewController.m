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
#import <MessageUI/MessageUI.h>

@interface RecipeShareViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, weak) id<RecipeShareViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *facebookShareButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterShareButton;
@property (weak, nonatomic) IBOutlet UIButton *mailShareButton;
@property (weak, nonatomic) IBOutlet UIButton *msgShareButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong, readonly) NSURL *shareURL;

@end

@implementation RecipeShareViewController

#define kUnderlayMaxAlpha   0.7
#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define SHARE_TITLE @"Check out this recipe"
#define SHARE_DESCRIPTION @"Shared from Cook"

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
    [self.twitterShareButton addTarget:self action:@selector(twitterShareTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.mailShareButton addTarget:self action:@selector(mailShareTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.msgShareButton addTarget:self action:@selector(messageShareTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    // Check active FBSession here, if not, do login and grab token
    [self shareFacebook];
}

- (void)twitterShareTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [self shareTwitter];
    }
    else
    {
        [self errorWithType:CKShareTwitter error:nil];
    }
}

- (void)mailShareTapped:(id)sender {
    if ([MFMailComposeViewController canSendMail])
        [self shareMail];
    else
        [[[UIAlertView alloc] initWithTitle:@"Mail" message:@"Please set up a mail account in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)messageShareTapped:(id)sender {
    if ([MFMessageComposeViewController canSendText])
        [self shareMessage];
    else
        [[[UIAlertView alloc] initWithTitle:@"Message" message:@"Please set up iMessage in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - Social Sharers

- (void)shareFacebook
{
    FBShareDialogParams *shareParams = [[FBShareDialogParams alloc] init];
    shareParams.link = self.shareURL;
    if ([FBDialogs canPresentOSIntegratedShareDialogWithSession:nil])
    { //Present OS dialog
        [FBDialogs presentOSIntegratedShareDialogModallyFrom:self initialText:SHARE_TITLE image:nil url:self.shareURL handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
            if (error) {
                [self errorWithType:CKShareFacebook error:error];
            } else {
                [self successWithType:CKShareFacebook];
            }
        }];
    }
    else if ([FBDialogs canPresentShareDialogWithParams:shareParams])
    { //Present dialog in Facebook app
        [FBDialogs presentShareDialogWithLink:self.shareURL handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if (error) {
                [self errorWithType:CKShareFacebook error:error];
            } else {
                [self successWithType:CKShareFacebook];
            }
        }];
    }
    else
    { //Present web dialog
        NSDictionary *webParameters = @{@"name" : SHARE_TITLE,
                                        @"description" : SHARE_DESCRIPTION,
                                        @"link" : self.shareURL.absoluteString};
        [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:webParameters handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
            if (error) {
                [self errorWithType:CKShareFacebook error:error];
            } else {
                [self successWithType:CKShareFacebook];
            }
        }];
    }
}

- (void)shareTwitter
{
    SLComposeViewController *twitterComposeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterComposeController addURL:self.shareURL];
    [twitterComposeController setCompletionHandler:^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled)
        {
            //Cancelled, do nothing
            DLog(@"Cancelled Twitter");
        }
        else
        {
            [self successWithType:CKShareTwitter];
        }
    }];
    [self presentViewController:twitterComposeController animated:YES completion:nil];
}

- (void)shareMail
{
    MFMailComposeViewController *mailDialog = [[MFMailComposeViewController alloc] init];
    NSString *shareBody = [NSString stringWithFormat:@"%@ %@", SHARE_DESCRIPTION, self.shareURL.absoluteString];
    [mailDialog setSubject:SHARE_TITLE];
    [mailDialog setMessageBody:shareBody isHTML:NO];
    mailDialog.mailComposeDelegate = self;
    [self presentViewController:mailDialog animated:YES completion:nil];
}

- (void)shareMessage
{
    MFMessageComposeViewController *messageDialog = [[MFMessageComposeViewController alloc] init];
    [messageDialog setBody:[NSString stringWithFormat:@"%@ %@", SHARE_DESCRIPTION, self.shareURL.absoluteString]];
    messageDialog.messageComposeDelegate = self;
    [self presentViewController:messageDialog animated:YES completion:nil];
}

- (void)errorWithType:(CKShareType)shareType error:(NSError *)error
{
    NSString *errorString;
    if (error) DLog(@"Error in sharing: %@", error.localizedDescription);
    switch (shareType) {
        case CKShareFacebook:
            errorString = @"Error in posting to Facebook";
            break;
        case CKShareTwitter:
            errorString = @"Please set up a Twitter account in the Settings app";
            break;
        case CKShareMail:
            errorString = @"Error in posting to Mail";
            break;
        case CKShareMessage:
            errorString = @"Error in posting to Message";
            break;
        default:
            errorString = @"Error";
            break;
    }
    [[[UIAlertView alloc] initWithTitle:@"Error in sharing" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)successWithType:(CKShareType)shareType
{
    NSString *successString;
    switch (shareType) {
        case CKShareFacebook:
            successString = @"Success in posting to Facebook";
            break;
        case CKShareTwitter:
            successString = @"Success in posting to Twitter";
            break;
        case CKShareMail:
            successString = @"Success in posting to Mail";
            break;
        case CKShareMessage:
            successString = @"Success in posting to Message";
            break;
        default:
            successString = @"Success";
            break;
    }
    DLog(@"%@", successString);
}

#pragma mark - Mail and Message delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultFailed:
            [self errorWithType:CKShareMessage error:nil];
            break;
        case MessageComposeResultSent:
            [self successWithType:CKShareMessage];
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultFailed:
            [self errorWithType:CKShareMail error:error];
            break;
        case MFMailComposeResultSaved:
        case MFMailComposeResultSent:
            [self successWithType:CKShareMail];
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
