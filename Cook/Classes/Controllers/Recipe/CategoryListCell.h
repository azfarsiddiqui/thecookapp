//
//  CategoryListCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 31/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListCell.h"

@class CKBook;

@interface CategoryListCell : CKListCell

@property (nonatomic, strong) CKBook *book;

@end
