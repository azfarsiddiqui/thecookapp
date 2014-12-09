//
//  PageShareViewController.m
//  Cook
//
//  Created by Gerald on 4/12/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "PageShareViewController.h"
#import "CKBook.h"
#import "CKUser.h"
#import "AppHelper.h"
#import "NSString+Utilities.h"
#import "CKRecipe.h"

@interface PageShareViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSString *pageName;
@property (nonatomic, strong) NSURL *pageImageURL;
@property (nonatomic, strong) CKUser *currentUser;


@end

@implementation PageShareViewController

- (id)initWithBook:(CKBook *)book pageName:(NSString *)page featuredImageURL:(NSURL *)pageImageURL delegate:(id<ShareViewControllerDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        self.currentUser = [CKUser currentUser];
        self.pageName = page;
        self.book = book;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Share properties

- (NSString *)screenTitleString {
    return NSLocalizedString(@"SHARE PAGE", nil);
}

- (NSString *)shareTitle {
    if ([self.book.author CK_containsText]) {
        return [NSString stringWithFormat:@"%@ - %@", self.book.author, self.pageName];
    } else {
        return [NSString stringWithFormat:@"%@ - %@", self.book.user.name, self.pageName];
    }
}

- (NSURL *)shareImageURL {
    return self.pageImageURL;
}

- (NSURL *)shareURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.worldscookbook.com/bookPage/%@/%@", self.book.user.objectId, [self.pageName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
}

- (NSString *)shareEmailSubject {
    NSMutableString *subject = [NSMutableString new];
    if (self.currentUser) {
        [subject appendFormat:NSLocalizedString(@"%@ shared a page from Cook", nil), [self.currentUser friendlyName]];
    } else {
        [subject appendString:NSLocalizedString(@"A page from Cook", nil)];
    }
    return subject;
}

- (NSString *)shareTextWithURL:(BOOL)showUrl showTwitter:(BOOL)showTwitter {
    NSMutableString *shareText = [NSMutableString new];
    [shareText appendString:[NSString stringWithFormat:@"A page from %@", [self shareTitle]]];
    
    if (showTwitter) {
        [shareText appendString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"via @thecookapp", nil)]];
    }
    if (showUrl) {
        [shareText appendFormat:@"\n%@", [self.shareURL absoluteString]];
    }
    
    return shareText;
}

@end
