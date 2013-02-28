//
//  ServesEditingViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/20/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewController.h"

@interface ServesCookPrepEditingViewController : CKEditingViewController
@property (nonatomic, strong) NSNumber *numServes;
@property (nonatomic, strong) NSNumber *cookingTimeInMinutes;
@property (nonatomic, strong) NSNumber *prepTimeInMinutes;

@end
