//
//  ProfileShareViewController.m
//  Cook
//
//  Created by Gerald on 2/12/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "ProfileShareViewController.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "CKUser.h"
#import <MessageUI/MessageUI.h>
#import "AppHelper.h"
#import "NSString+Utilities.h"

@interface ProfileShareViewController ()

@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) CKBook *book;

@end

@implementation ProfileShareViewController

#define kContentInsets  (UIEdgeInsets){ 25.0, 20.0, 0.0, 10.0 }

- (id)initWithBook:(CKBook *)book delegate:(id<ShareViewControllerDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        self.currentUser = [CKUser currentUser];
        self.book = book;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.closeButton.frame = (CGRect){
        kContentInsets.left,
        kContentInsets.top,
        self.closeButton.frame.size.width,
        self.closeButton.frame.size.height
    };
}

#pragma mark - Share properties

- (NSString *)screenTitleString {
    return NSLocalizedString(@"SHARE BOOK", nil);
}

- (NSString *)shareTitle {
    if ([self.book.author CK_containsText]) {
        return [self.book.author CK_mixedCase];
    } else {
        return [self.book.user friendlyName];
    }
}

- (NSURL *)shareImageURL {
    return [NSURL URLWithString:self.book.titleRecipe.recipeImage.imageFile.url];
}

- (NSURL *)shareURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.worldscookbook.com/profile/%@", self.book.user.objectId]];
}

- (NSString *)shareEmailSubject {
    NSMutableString *subject = [NSMutableString new];
    if (self.currentUser) {
        [subject appendFormat:NSLocalizedString(@"%@ shared a book from Cook", nil), [[self.currentUser friendlyName] CK_mixedCase]];
    } else {
        [subject appendString:NSLocalizedString(@"A book from Cook", nil)];
    }
    return subject;
}

- (NSString *)shareTextWithURL:(BOOL)showUrl showTwitter:(BOOL)showTwitter {
    NSMutableString *shareText = [NSMutableString new];
    [shareText appendString:[NSString stringWithFormat:@"%@", [[self shareTitle] CK_mixedCase]]];
    
    if (showTwitter) {
        [shareText appendString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"on @thecookapp", nil)]];
    }
    if (showUrl) {
        [shareText appendFormat:@"\n%@", [self.shareURL absoluteString]];
    }
    
    return shareText;
}

@end
