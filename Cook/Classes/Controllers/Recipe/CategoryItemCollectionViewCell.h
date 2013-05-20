//
//  CategoryItemCollectionViewCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextItemCollectionViewCell.h"

@class CKBook;

@interface CategoryItemCollectionViewCell : CKTextItemCollectionViewCell

@property (nonatomic, strong) CKBook *book;

@end
