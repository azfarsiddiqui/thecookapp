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
#import "NSString+Utilities.h"
#import "NSString+Utilities.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "AnalyticsHelper.h"
#import "UIDevice+Hardware.h"
#import <Pinterest/Pinterest.h>

@interface RecipeShareViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, weak) id<RecipeShareViewControllerDelegate> delegate;

@property (nonatomic, strong) UIButton *facebookShareButton;
@property (nonatomic, strong) UIButton *twitterShareButton;
@property (nonatomic, strong) UIButton *mailShareButton;
@property (nonatomic, strong) UIButton *messageShareButton;
@property (nonatomic, strong) UIButton *pinterestShareButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) Pinterest *pinterest;
@property (nonatomic, strong, readonly) NSURL *shareURL;

@end

@implementation RecipeShareViewController

#define kUnderlayMaxAlpha   0.7
#define kContentInsets      (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define SHARE_TITLE         @"Check out this recipe"
#define SHARE_DESCRIPTION   @"Shared from Cook"

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeShareViewControllerDelegate>)delegate {
    if (self = [super  init]) {
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
    shareTitleLabel.text = @"SHARE RECIPE";
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
    
    
    //Only show disclaimer if owner of recipe
    
    if ([self.recipe.user.objectId isEqualToString:[CKUser currentUser].objectId]) {
        
        UILabel *bottomLabel = [[UILabel alloc] init];
        [bottomLabel setBackgroundColor:[UIColor clearColor]];
        bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
        bottomLabel.textAlignment = NSTextAlignmentLeft;
        bottomLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        bottomLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:bottomLabel];
        bottomLabel.text = @"SHARED RECIPES ARE PUBLICLY VISIBLE ON THE WEB";
        UIImageView *lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_share_icon_unlocked"]];
        lockImageView.backgroundColor = [UIColor clearColor];
        lockImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:lockImageView];
        
        { //Setting up constraints to space label and lock at bottom
            NSDictionary *metrics = @{@"width":@39.0, @"height":@39.0};
            NSDictionary *views = NSDictionaryOfVariableBindings(bottomLabel, lockImageView);
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[lockImageView(width)]-4.0-[bottomLabel]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=100)-[lockImageView(height)]-10.0-|" options:0 metrics:metrics views:views]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.f constant:0.f]];
        }
    } else {
        UILabel *reportLabel = [[UILabel alloc] init];
        [reportLabel setBackgroundColor:[UIColor clearColor]];
        reportLabel.translatesAutoresizingMaskIntoConstraints = NO;
        reportLabel.textAlignment = NSTextAlignmentLeft;
        reportLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        reportLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:reportLabel];
        reportLabel.text = @"REPORT";
        UIImageView *flagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_share_icon_report"]];
        UITapGestureRecognizer *reportGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reportPressed:)];
        [reportLabel addGestureRecognizer:reportGesture];
        UITapGestureRecognizer *reportGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reportPressed:)];
        [flagImageView addGestureRecognizer:reportGesture2];
        flagImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:flagImageView];
        reportLabel.userInteractionEnabled = YES;
        flagImageView.userInteractionEnabled = YES;
        {
            NSDictionary *views = NSDictionaryOfVariableBindings(reportLabel, flagImageView);
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[flagImageView]-(1)-[reportLabel]-(20)-|" options:NSLayoutFormatAlignAllCenterY metrics:0 views:views]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(35)-[flagImageView]-(>=20)-|" options:0 metrics:0 views:views]];
        }
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
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_close_dark.png"]
                                     selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_close_dark_onpress.png"]
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
    [self shareFacebook];

//    //Login and attach Facebook credentials to account. If successful, do share
//    CKUser *currentUser = [CKUser currentUser];
//    if (!currentUser.facebookId)
//    {
//        [CKUser attachFacebookToCurrentUserWithSuccess:^{
//            [self shareFacebook];
//        } failure:^(NSError *error) {
//            
//            if ([CKUser facebookAlreadyUsedInAnotherAccountError:error]) {
//                [ViewHelper alertWithTitle:@"Couldn’t Add Facebook" message:@"The Facebook account is already used by another Cook account"];
//            } else if ([CKUser isFacebookPermissionsError:error]) {
//                [ViewHelper alertWithTitle:@"Permission Required" message:@"Go to iPad Settings > Facebook and turn on for Cook"];
//            } else {
//                [ViewHelper alertWithTitle:@"Couldn’t Add Facebook" message:nil];
//            }
//        }];
//        
//    } else {
//        [self shareFacebook];
//    }
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
        [FBDialogs presentOSIntegratedShareDialogModallyFrom:self initialText:[self shareTextWithURL:NO] image:nil
                                                         url:self.shareURL
                                                     handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
            if (error) {
                [self errorWithType:CKShareFacebook error:error];
            } else {
                [self successWithType:CKShareFacebook];
            }
        }];
    }
    else if ([FBDialogs canPresentShareDialogWithParams:shareParams])
    { //Present dialog in Facebook app
        [FBDialogs presentShareDialogWithLink:self.shareURL name:[self shareTextWithURL:NO]
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if (error) {
                [self errorWithType:CKShareFacebook error:error];
            } else {
                [self successWithType:CKShareFacebook];
            }
        }];
    }
    else
    { //Present web dialog
        NSDictionary *webParameters = @{
                                        @"name" : [self shareTextWithURL:NO],
                                        @"link" : [self.shareURL absoluteString]
                                        };
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
    [twitterComposeController setInitialText:[self shareTextWithURL:NO showTwitter:YES]];
    
    // Do we have an image to attach?
    UIImage *image = [self.delegate recipeShareViewControllerImageRequested];
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
    NSURL *imageURL = [NSURL URLWithString:self.recipe.recipeImage.imageFile.url];
    if (!imageURL) {
        imageURL = [NSURL URLWithString:@"http://www.worldscookbook.com/images/cook_defaultimage_pinterest@2x.jpg"];
    };
    [self.pinterest createPinWithImageURL:imageURL sourceURL:self.shareURL description:self.recipe.name];
}

- (void)shareEmail
{
    MFMailComposeViewController *mailDialog = [[MFMailComposeViewController alloc] init];
    
    NSMutableString *subject = [NSMutableString new];
    if (self.currentUser) {
        [subject appendFormat:@"%@ shared a recipe from Cook", [self.currentUser friendlyName]];
    } else {
        [subject appendString:@"A recipe from Cook"];
    }
    
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

- (NSString *)shareTextWithURL:(BOOL)showUrl showTwitter:(BOOL)showTwitter {
    NSMutableString *shareText = [NSMutableString new];
    if ([self.recipe.name CK_containsText]) {
        NSMutableString *recipeTitle = [NSMutableString stringWithString:[self.recipe.name CK_mixedCase]];
        [recipeTitle replaceOccurrencesOfString:[NSString CK_lineBreakString] withString:@" " options:0 range:NSMakeRange(0, [recipeTitle length])];
        [recipeTitle replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, [recipeTitle length])];
        [shareText appendString:recipeTitle];
    } else {
        [shareText appendFormat:@"Check out %@ recipe", [self.recipe isOwner] ? @"my" : @"this"];
    }
    if (showTwitter) {
        [shareText appendString:@" via @thecookapp"];
    }
    if (showUrl) {
        [shareText appendFormat:@"\n%@", [self.shareURL absoluteString]];
    }
    
    return shareText;
}

- (void)reportPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailDialog = [[MFMailComposeViewController alloc] init];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString *versionString = [NSString stringWithFormat:@"Version: %@", minorVersion];
        
        CKUser *currentUser = [CKUser currentUser];
        NSString *userDisplay = [NSString stringWithFormat:@"Cook ID: %@", (currentUser != nil) ? currentUser.objectId : @"None"];
        NSString *badRecipeString = [NSString stringWithFormat:@"Reported Recipe ID: %@ \n Reported Recipe Name: %@", self.recipe.objectId, self.recipe.name];
        
        NSString *shareBody = [NSString stringWithFormat:@"\n\n\n\n--\n%@ / %@\n%@", versionString, userDisplay, badRecipeString];
        
        [mailDialog setToRecipients:@[@"report@thecookapp.com"]];
        [mailDialog setSubject:@"Report a Recipe to Cook"];
        [mailDialog setMessageBody:shareBody isHTML:NO];
        mailDialog.mailComposeDelegate = self;
        [self presentViewController:mailDialog animated:YES completion:nil];
    }
    else
        [[[UIAlertView alloc] initWithTitle:@"Mail" message:@"Please set up a mail account in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
