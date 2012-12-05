//
//  RecipeImageView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeImageView.h"
#import "ViewHelper.h"

@interface RecipeImageView()
@property(nonatomic,strong) PFImageView *imageView;
@property(nonatomic,strong) UIScrollView *recipeImageScrollView;
@property(nonatomic,strong) UIButton *editImageButton;
@property(nonatomic,assign) BOOL loadingImage;
@end
@implementation RecipeImageView


-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    self.recipeImageScrollView.scrollEnabled = YES;
    self.editImageButton.hidden = !editable;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Editable protocol
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
        _recipeImageScrollView.scrollEnabled = NO;
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

-(UIButton *)editImageButton
{
    if (!_editImageButton) {
        _editImageButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_editrecipe_editphoto.png"] target:self selector:@selector(editImageTapped:)];
        _editImageButton.hidden =YES;
        _editImageButton.frame = CGRectMake(5.0f,self.bounds.size.height - _editImageButton.frame.size.height-5.0f,
                                                 _editImageButton.frame.size.width, _editImageButton.frame.size.height);
        [self addSubview:_editImageButton];
    }
    return _editImageButton;
}

#pragma mark - Action methods
-(void)editImageTapped:(UIButton*)button
{
    DLog();
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
