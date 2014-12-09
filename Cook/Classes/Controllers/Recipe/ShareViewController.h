//
//  ShareViewController.h
//  Cook
//
//  Created by Gerald Kim on 31/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

typedef enum {
    CKShareTwitter = 0,
    CKShareFacebook,
    CKShareMail,
    CKShareMessage,
    CKSharePinterest,
} CKShareType;

@protocol ShareViewControllerDelegate <NSObject>

- (void)shareViewControllerCloseRequested;
- (UIImage *)shareViewControllerImageRequested;

@end

@interface ShareViewController : UIViewController

- (id)initWithDelegate:(id<ShareViewControllerDelegate>)delegate;
- (NSString *)screenTitleString;
- (NSString *)shareTitle;
- (NSString *)shareEmailSubject;
- (NSURL *)shareImageURL;
- (NSURL *)shareURL;
- (NSString *)shareTextWithURL:(BOOL)showUrl showTwitter:(BOOL)showTwitter;
- (void)successWithType:(CKShareType)shareType;

@end
