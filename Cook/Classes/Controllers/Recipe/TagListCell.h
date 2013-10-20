//
//  TagListCell.h
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListCell.h"

@class CKRecipeTag;

@interface TagListCell : CKListCell

@property (nonatomic, strong) CKRecipeTag *recipeTag;

@end
