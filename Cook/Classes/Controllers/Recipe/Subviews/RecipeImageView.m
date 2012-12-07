//
//  RecipeImageView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeImageView.h"
#import "ViewHelper.h"
#import "AppHelper.h"
#import "AFPhotoEditorController.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface RecipeImageView()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, AFPhotoEditorControllerDelegate>
//UI
@property(nonatomic,strong) PFImageView *imageView;
@property(nonatomic,strong) UIScrollView *recipeImageScrollView;
@property(nonatomic,strong) UIButton *editImageButton;
@property(nonatomic,strong) UIButton *addImageButtonFromCamera;
@property(nonatomic,strong) UIButton *addImageButtonFromLibrary;
@property (nonatomic,strong) UIPopoverController *popoverController;
@property (nonatomic,strong) AFPhotoEditorController *photoEditorController;

//data
@property (nonatomic,assign) BOOL loadingImage;
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
    [CKRecipe fetchImagesForRecipe:recipe success:^{
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

-(CGPoint)scrollViewContentOffset
{
    return self.recipeImageScrollView.contentOffset;
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
        _recipeImageScrollView.bounces = NO;
        _recipeImageScrollView.showsHorizontalScrollIndicator = NO;
        _recipeImageScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _recipeImageScrollView.showsVerticalScrollIndicator = NO;

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
        _editImageButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_editrecipe_editphoto.png"] target:self selector:@selector(uploadImageTapped:)];
        _editImageButton.hidden =YES;
        _editImageButton.frame = CGRectMake(5.0f,self.bounds.size.height - _editImageButton.frame.size.height-5.0f,
                                                 _editImageButton.frame.size.width, _editImageButton.frame.size.height);
        [self addSubview:_editImageButton];
    }
    return _editImageButton;
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.recipeImageScrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - Action methods
-(IBAction)uploadImageTapped:(UIButton *)button
{
    if (([button isEqual:self.addImageButtonFromCamera] || [button isEqual:self.editImageButton]) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        UIView *pickerView = picker.view;
        pickerView.frame = self.superview.bounds;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self.parentViewController presentViewController:picker animated:YES completion:nil];
    } else if ([button isEqual:self.addImageButtonFromLibrary] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = @[(NSString *) kUTTypeImage];
        picker.delegate = self;
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popoverController.delegate=self;
        UIView *rootView = [[AppHelper sharedInstance] rootView];
        [self.popoverController presentPopoverFromRect:[button.superview convertRect:button.frame toView:rootView] inView:rootView
                                               permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        
    } else {
        DLog("** no camera available - stubbed image **");
        //so we simulate an image
        self.photoEditorController = [[AFPhotoEditorController alloc] initWithImage:[UIImage imageNamed:@"test_image"]];
        [self.photoEditorController setDelegate:self];
        self.photoEditorController.view.frame = self.superview.bounds;
        [self.superview addSubview:self.photoEditorController.view];
    }
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.parentViewController dismissViewControllerAnimated:YES
                             completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSParameterAssert(image);
    DLog(@"image size after picker: %f, %f", image.size.width,image.size.height);
    if (self.popoverController) {
        //origin via popover for library picker
        [self.popoverController dismissPopoverAnimated:NO];
        self.photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
        [self.photoEditorController setDelegate:self];
        self.photoEditorController.view.frame = self.superview.bounds;
        [self.superview addSubview:self.photoEditorController.view];
    } else {
        [self.parentViewController dismissViewControllerAnimated:NO completion:^{
            self.photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
            [self.photoEditorController setDelegate:self];
            self.photoEditorController.view.frame = self.superview.bounds;
            [self.superview addSubview:self.photoEditorController.view];
        }];
    }
}

#pragma mark - UIPopoverDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverController = nil;
}

#pragma mark - AFPhotoEditorControllerDelegate
-(void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    NSParameterAssert(editor == self.photoEditorController);
    [self.photoEditorController.view removeFromSuperview];
    self.photoEditorController = nil;
    
    NSParameterAssert(image);
    self.recipeImage = image;
    self.imageView.image = image;
    _imageEdited = YES;
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    self.recipeImageScrollView.contentSize = image.size;
    [self centerScrollViewContents];
    DLog(@"photo size %@", NSStringFromCGSize(image.size));
    //TODO for new images: self.cameraButtonsView.hidden = YES;
}

-(void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self.photoEditorController.view removeFromSuperview];
    self.photoEditorController = nil;
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
