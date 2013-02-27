//
//  FacebookUserView.h
//  Cook
//
//  Created by Jonny Sagorin on 11/14/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKUser.h"
@interface FacebookUserView : UIView
-(void)setUser:(CKUser*)user;
-(void)setUser:(CKUser*)user inFrame:(CGRect)frame;
@end
