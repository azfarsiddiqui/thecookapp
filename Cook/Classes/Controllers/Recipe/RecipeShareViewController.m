//
//  RecipeShareViewController.m
//  Cook
//
//  Created by Gerald on 18/11/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeShareViewController.h"
#import "CKRecipe.h"
#import "CKUser.h"
#import <MessageUI/MessageUI.h>
#import "AppHelper.h"
#import "NSString+Utilities.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface RecipeShareViewController () <MFMailComposeViewControllerDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) CKRecipe *recipe;

@end

@implementation RecipeShareViewController

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<ShareViewControllerDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        self.currentUser = [CKUser currentUser];
        self.recipe = recipe;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Only show disclaimer if owner of recipe
    
    if ([self.recipe.user.objectId isEqualToString:[CKUser currentUser].objectId]) {
        
        UILabel *bottomLabel = [[UILabel alloc] init];
        [bottomLabel setBackgroundColor:[UIColor clearColor]];
        bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
        bottomLabel.textAlignment = NSTextAlignmentLeft;
        bottomLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        bottomLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:bottomLabel];
        bottomLabel.text = NSLocalizedString(@"SHARED RECIPES ARE PUBLICLY VISIBLE ON THE WEB", nil);
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
        reportLabel.text = NSLocalizedString(@"REPORT", nil);
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
}

- (void)successWithType:(CKShareType)shareType
{
    [super successWithType:shareType];
    
}

#pragma mark - Actions

- (void)reportPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailDialog = [[MFMailComposeViewController alloc] init];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString *versionString = [NSString stringWithFormat:@"Version: %@", minorVersion];
        
        CKUser *currentUser = [CKUser currentUser];
        NSString *userDisplay = [NSString stringWithFormat:@"Cook ID: %@", (currentUser != nil) ? currentUser.objectId : NSLocalizedString(@"None", nil)];
        NSString *badRecipeString = [NSString stringWithFormat:@"ID: %@ \n Name: %@", self.recipe.objectId, self.recipe.name];
        NSString *badURLString = [NSString stringWithFormat:@"URL: http://www.worldscookbook.com/%@", self.recipe.objectId];
        NSString *shareBody = [NSString stringWithFormat:@"\n\n\n\n--\n%@ / %@\n%@\n%@", versionString, userDisplay, badRecipeString, badURLString];
        
        [mailDialog setToRecipients:@[@"report@thecookapp.com"]];
        [mailDialog setSubject:NSLocalizedString(@"Report a Recipe to Cook", nil)];
        [mailDialog setMessageBody:shareBody isHTML:NO];
        mailDialog.mailComposeDelegate = self;
        [self presentViewController:mailDialog animated:YES completion:nil];
    }
    else
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mail", nil) message:NSLocalizedString(@"Please set up a mail account in Settings", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

#pragma mark - Share properties

- (NSString *)screenTitleString {
    return NSLocalizedString(@"SHARE RECIPE", nil);
}

- (NSString *)shareTitle {
    return self.recipe.name;
}

- (NSURL *)shareImageURL {
    return [NSURL URLWithString:self.recipe.recipeImage.imageFile.url];
}

- (NSURL *)shareURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.worldscookbook.com/%@", self.recipe.objectId]];
}

- (NSString *)shareEmailSubject {
    NSMutableString *subject = [NSMutableString new];
    if (self.currentUser) {
        [subject appendFormat:NSLocalizedString(@"%@ shared a recipe from Cook", nil), [self.currentUser friendlyName]];
    } else {
        [subject appendString:NSLocalizedString(@"A recipe from Cook", nil)];
    }
    return subject;
}

- (NSString *)shareTextWithURL:(BOOL)showUrl showTwitter:(BOOL)showTwitter {
    NSMutableString *shareText = [NSMutableString new];
    if ([self.recipe.name CK_containsText]) {
        NSMutableString *recipeTitle = [NSMutableString stringWithString:[self.recipe.name CK_mixedCase]];
        [recipeTitle replaceOccurrencesOfString:[NSString CK_lineBreakString] withString:@" " options:0 range:NSMakeRange(0, [recipeTitle length])];
        [recipeTitle replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, [recipeTitle length])];
        [shareText appendString:recipeTitle];
    } else {
        
        if ([self.recipe isOwner]) {
            [shareText appendString:NSLocalizedString(@"Check out my recipe", nil)];
        } else {
            [shareText appendString:NSLocalizedString(@"Check out this recipe", nil)];
        }
    }
    if (showTwitter) {
        [shareText appendString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"via @thecookapp", nil)]];
    }
    if (showUrl) {
        [shareText appendFormat:@"\n%@", [self.shareURL absoluteString]];
    }
    
    return shareText;
}

- (void) sharerDidCancel :(id<FBSDKSharing>)sharer {
    NSLog(@"Share cancelled..");
}

@end
