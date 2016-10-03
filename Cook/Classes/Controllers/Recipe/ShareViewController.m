//
//  ShareViewController.m
//  Cook
//
//  Created by Gerald Kim on 31/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ShareViewController.h"
#import "ViewHelper.h"
#import "CKRecipe.h"
#import "AppHelper.h"
#import "NSString+Utilities.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "AnalyticsHelper.h"
#import <Pinterest/Pinterest.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ShareViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBSDKSharingDelegate>

@property (nonatomic, weak) id<ShareViewControllerDelegate> delegate;

@property (nonatomic, strong) UIButton *facebookShareButton;
@property (nonatomic, strong) UIButton *twitterShareButton;
@property (nonatomic, strong) UIButton *mailShareButton;
@property (nonatomic, strong) UIButton *messageShareButton;
@property (nonatomic, strong) UIButton *pinterestShareButton;
@property (nonatomic, strong) Pinterest *pinterest;

@end

@implementation ShareViewController

#define kUnderlayMaxAlpha   0.7
#define kContentInsets      (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define SHARE_TITLE         NSLocalizedString(@"Check out this recipe", nil)
#define SHARE_DESCRIPTION   NSLocalizedString(@"Shared from Cook", nil)

- (id)initWithDelegate:(id<ShareViewControllerDelegate>)delegate {
    if (self = [super  init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kUnderlayMaxAlpha];
    [self.view addSubview:self.closeButton];
    UIView *middleContentView = [[UIView alloc] init];
    middleContentView.translatesAutoresizingMaskIntoConstraints = NO;
    middleContentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:middleContentView];
    
    // Setting up constraints to center share content horizontally and vertically
    {
        NSDictionary *metrics = @{@"height":@180.0, @"width":@520.0};
        NSDictionary *views = NSDictionaryOfVariableBindings(middleContentView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[middleContentView]-(>=20)-|"
                                                                          options:NSLayoutFormatAlignAllCenterX
                                                                          metrics:metrics
                                                                            views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=20)-[middleContentView(height)]-(>=20)-|"
                                                                          options:NSLayoutFormatAlignAllCenterY
                                                                          metrics:metrics
                                                                            views:views]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:middleContentView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.f constant:0.f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:middleContentView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.f constant:0.f]];
    }
    
    //Styling and placing buttons
    self.facebookShareButton = [[UIButton alloc] init];
    [self.facebookShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_facebook"] forState:UIControlStateNormal];
    [self.facebookShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_facebook_onpress"] forState:UIControlStateHighlighted];
    self.facebookShareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.facebookShareButton];
    self.twitterShareButton = [[UIButton alloc] init];
    [self.twitterShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_twitter"] forState:UIControlStateNormal];
    [self.twitterShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_twitter_onpress"] forState:UIControlStateHighlighted];
    self.twitterShareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.twitterShareButton];
    self.pinterestShareButton = [[UIButton alloc] init];
    [self.pinterestShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_pinterest"] forState:UIControlStateNormal];
    [self.pinterestShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_pinterest_onpress"] forState:UIControlStateHighlighted];
    self.pinterestShareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.pinterestShareButton];
    self.mailShareButton = [[UIButton alloc] init];
    [self.mailShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_email"] forState:UIControlStateNormal];
    [self.mailShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_email_onpress"] forState:UIControlStateHighlighted];
    self.mailShareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.mailShareButton];
    self.messageShareButton = [[UIButton alloc] init];
    [self.messageShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_imessage"] forState:UIControlStateNormal];
    [self.messageShareButton setBackgroundImage:[UIImage imageNamed:@"cook_book_share_icon_imessage_onpress"] forState:UIControlStateHighlighted];
    self.messageShareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.messageShareButton];
    UILabel *shareTitleLabel = [[UILabel alloc] init];
    [shareTitleLabel setBackgroundColor:[UIColor clearColor]];
    shareTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    shareTitleLabel.textAlignment = NSTextAlignmentCenter;
    shareTitleLabel.text = [self screenTitleString];
    shareTitleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Light" size:40.0];
    shareTitleLabel.textColor = [UIColor whiteColor];
    [shareTitleLabel sizeToFit];
    [middleContentView addSubview:shareTitleLabel];
    
    { //Setting up constraints to space buttons in content view
        NSDictionary *metrics = @{@"height":@110.0, @"width":@110.0, @"titleHeight":@38.0, @"spacing":@10.0};
        NSDictionary *views = @{@"facebook" : self.facebookShareButton,
                                @"twitter" : self.twitterShareButton,
                                @"pinterest" : self.pinterestShareButton,
                                @"mail" : self.mailShareButton,
                                @"message" : self.messageShareButton,
                                @"title" : shareTitleLabel};
        NSString *buttonConstraints = @"|-(>=0)-[facebook(width)]-spacing-[twitter(facebook)]-spacing-[pinterest(facebook)]-spacing-[mail(facebook)]-spacing-[message(facebook)]-(>=0)-|";
        [middleContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:buttonConstraints options:NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
        [middleContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title(titleHeight)]-[facebook(height)]" options:0 metrics:metrics views:views]];
        [middleContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[title]-(>=20)-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
        [middleContentView addConstraint:[NSLayoutConstraint constraintWithItem:shareTitleLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:middleContentView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.f constant:0.f]];
    }
    
    // Attach actions to buttons
	[self.facebookShareButton addTarget:self action:@selector(facebookShareTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.twitterShareButton addTarget:self action:@selector(twitterShareTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.pinterestShareButton addTarget:self action:@selector(pinterestShareTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.mailShareButton addTarget:self action:@selector(mailShareTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.messageShareButton addTarget:self action:@selector(messageShareTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property getters

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

#pragma mark - Button actions and handlers

- (void)closeTapped:(id)sender {
    [self.delegate shareViewControllerCloseRequested];
}

- (void)facebookShareTapped:(id)sender {
    DLog(@"Share URL: %@", self.shareURL);
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

- (void)pinterestShareTapped:(id)sender {
    [self sharePinterest];
}

- (void)mailShareTapped:(id)sender {
    if ([MFMailComposeViewController canSendMail])
        [self shareEmail];
    else
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mail", nil)
                                    message:NSLocalizedString(@"Please set up a mail account in Settings", nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

- (void)messageShareTapped:(id)sender {
    if ([MFMessageComposeViewController canSendText])
        [self shareMessage];
    else
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message", nil)
                                    message:NSLocalizedString(@"Please set up iMessage in Settings", nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

#pragma mark - Social Sharers

- (void)shareFacebook
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = self.shareURL;
    
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.shareContent = content;
    
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
    
}

- (void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [self successWithType:CKShareFacebook];
}

- (void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [self errorWithType:CKShareFacebook error:error];
}

- (void)shareTwitter
{
    SLComposeViewController *twitterComposeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [twitterComposeController addURL:self.shareURL];
    [twitterComposeController setInitialText:[self shareTextWithURL:NO showTwitter:YES]];
    
    // Do we have an image to attach?
    UIImage *image = [self.delegate shareViewControllerImageRequested];
    if (image) {
        [twitterComposeController addImage:image];
    }
    
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

- (void)sharePinterest {
    
    // Assume success as we don't deal with callbacks yet.
    [self successWithType:CKSharePinterest];
    
    self.pinterest = [[Pinterest alloc] initWithClientId:@"1436113"];
    NSURL *imageURL = [self shareImageURL];
    if (!imageURL) {
        imageURL = [NSURL URLWithString:@"http://www.worldscookbook.com/images/cook_defaultimage_pinterest@2x.jpg"];
    };
    [self.pinterest createPinWithImageURL:imageURL sourceURL:self.shareURL description:[self shareTitle]];
}

- (void)shareEmail
{
    MFMailComposeViewController *mailDialog = [[MFMailComposeViewController alloc] init];
    
    NSString *subject = [self shareEmailSubject];
    
    [mailDialog setSubject:subject];
    [mailDialog setMessageBody:[self shareText] isHTML:NO];
    mailDialog.mailComposeDelegate = self;
    [self presentViewController:mailDialog animated:YES completion:nil];
}

- (void)shareMessage
{
    MFMessageComposeViewController *messageDialog = [[MFMessageComposeViewController alloc] init];
    [messageDialog setBody:[self shareText]];
    messageDialog.messageComposeDelegate = self;
    [self presentViewController:messageDialog animated:YES completion:nil];
}

- (void)errorWithType:(CKShareType)shareType error:(NSError *)error
{
    NSString *errorString;
    if (error) DLog(@"Error in sharing: %@", error.localizedDescription);
    switch (shareType) {
        case CKShareFacebook:
            errorString = NSLocalizedString(@"Error in posting to Facebook", nil);
            break;
        case CKShareTwitter:
            errorString = NSLocalizedString(@"Please set up a Twitter account in the Settings app", nil);
            break;
        case CKShareMail:
            errorString = NSLocalizedString(@"Error in posting to Mail", nil);
            break;
        case CKShareMessage:
            errorString = NSLocalizedString(@"Error in posting to Message", nil);
            break;
        default:
            errorString = NSLocalizedString(@"Error", nil);
            break;
    }
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error in sharing", nil) message:errorString
                               delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

- (void)successWithType:(CKShareType)shareType
{
    NSString *successString;
    NSString *socialString;
    switch (shareType) {
        case CKShareFacebook:
            successString = @"Success in posting to Facebook";
            socialString = @"Facebook";
            break;
        case CKShareTwitter:
            successString = @"Success in posting to Twitter";
            socialString = @"Twitter";
            break;
        case CKShareMail:
            successString = @"Success in posting to Mail";
            socialString = @"Mail";
            break;
        case CKShareMessage:
            successString = @"Success in posting to Message";
            socialString = @"iMessage";
            break;
        case CKSharePinterest:
            successString = @"Success in posting to Pinterest";
            socialString = @"Pinterest";
            break;
        default:
            successString = @"Success";
            socialString = @"";
            break;
    }
    
    // Analytics
    [AnalyticsHelper trackEventName:kEventRecipeShare params:@{ @"type" : socialString }];
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

- (NSString *)shareText {
    return [self shareTextWithURL:YES];
}

- (NSString *)shareTextWithURL:(BOOL)showUrl {
    return [self shareTextWithURL:showUrl showTwitter:NO];
}

#pragma mark - Subclassable share properties

- (NSString *)screenTitleString {
    return @"";
}

- (NSString *)shareTitle {
    return @"";
}

- (NSURL *)shareImageURL {
    return [NSURL URLWithString:@""];
}

- (NSURL *)shareURL {
    return [NSURL URLWithString:@""];
}

- (NSString *)shareEmailSubject {
    return @"";
}

- (NSString *)shareTextWithURL:(BOOL)showUrl showTwitter:(BOOL)showTwitter {
    NSMutableString *shareText = [NSMutableString new];
    [shareText appendString:NSLocalizedString(@"Check out this recipe", nil)];

    if (showTwitter) {
        
        [shareText appendString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"via @thecookapp", nil)]];
    }
    if (showUrl) {
        [shareText appendFormat:@"\n%@", [[self shareURL] absoluteString]];
    }
    
    return shareText;
}

@end
