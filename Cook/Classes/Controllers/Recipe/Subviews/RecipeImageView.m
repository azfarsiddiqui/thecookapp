//
//  RecipeImageView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeImageView.h"
@interface RecipeImageView()
@property(nonatomic,strong) PFImageView *imageView;
@property(nonatomic,strong) UIScrollView *recipeImageScrollView;
@property(nonatomic,assign) BOOL loadingImage;
@end
@implementation RecipeImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Editable protocol
-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
}

-(void)setRecipe:(CKRecipe *)recipe
{
    [CKRecipe imagesForRecipe:recipe success:^{
        if ([recipe imageFile]) {
            self.imageView.file = [recipe imageFile];
            if (!self.loadingImage)
            {
                self.loadingImage = YES;
                DLog(@"loading image...");
                [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
                    if (!error) {
                        DLog(@"loaded image");
                        CGSize imageSize = CGSizeMake(image.size.width, image.size.height);
                        DLog(@"recipe image size: %@",NSStringFromCGSize(imageSize));
                        self.imageView.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
                        self.imageView.image = image;
                        self.recipeImageScrollView.contentSize = CGSizeMake(imageSize.width,imageSize.height);
                        if (recipe.recipeViewImageContentOffset.x!=0) {
                            self.recipeImageScrollView.contentOffset = recipe.recipeViewImageContentOffset;
                        } else {
                            self.recipeImageScrollView.contentOffset = CGPointMake(340.0f, 0.0f);
                        }
                        
                    } else {
                        DLog(@"Error loading image in background: %@", [error description]);
                    }
                }];
            }
        }
    } failure:^(NSError *error) {
        DLog(@"Error loading image: %@", [error description]);
    }];
    
}

#pragma mark - Private Methods

//overridden
-(void)configViews
{
    self.recipeImageScrollView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
}


//overridden
-(void) styleViews
{
    
}

-(UIScrollView *)recipeImageScrollView
{
    if (!_recipeImageScrollView) {
        _recipeImageScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _recipeImageScrollView.scrollEnabled = YES;
        [self addSubview:_recipeImageScrollView];
    }
    return _recipeImageScrollView;
}

-(PFImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[PFImageView alloc] init];
        [self.recipeImageScrollView addSubview:_imageView];
    }
    return _imageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
