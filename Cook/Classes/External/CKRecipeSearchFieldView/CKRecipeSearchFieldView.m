//
//  CKRecipeSearchFieldView.m
//  CKRecipeSearchFieldViewDemo
//
//  Created by Jeff Tan-Ang on 27/03/2014.
//  Copyright (c) 2014 Cook App Pty Ltd. All rights reserved.
//

#import "CKRecipeSearchFieldView.h"
#import "CKRecipeSearchTextField.h"

@interface CKRecipeSearchFieldView () <UITextFieldDelegate>

@property (nonatomic, weak) id<CKRecipeSearchFieldViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) CKRecipeSearchTextField *textField;
@property (nonatomic, strong) UIView *leftSearchView;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, assign) BOOL forceUppercase;
@property (nonatomic, assign) NSInteger characterLimit;
@property (nonatomic, assign) NSInteger minCharacterLimit;
@property (nonatomic, strong) NSString *currentSearch;

@end

@implementation CKRecipeSearchFieldView

#define kExpandedSize       (CGSize){ 610.0, 90.0 }
#define kMiniSize           (CGSize){ 410.0, 75.0 }
#define kContentInsets      (UIEdgeInsets){ 10.0, 24.0, 10.0, 20.0 }
#define kTextColour         [UIColor whiteColor]
#define kPlaceholderColour  [UIColor lightTextColor]
#define kFont               [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30]

- (id)initWithDelegate:(id<CKRecipeSearchFieldViewDelegate>)delegate {
    if (self = [super initWithFrame:(CGRect){ 0.0, 0.0, kExpandedSize.width, kExpandedSize.height} ]) {
        self.delegate = delegate;
        
        // Placeholder text.
        self.placeholderText = [self.delegate recipeSearchFieldViewPlaceholderText];
        
        // Behaviour parameters.
        self.forceUppercase = YES;
        self.characterLimit = 50;
        self.minCharacterLimit = 2;
        
        // Background
        self.backgroundView.frame = self.bounds;
        [self addSubview:self.backgroundView];
        
        // Text field.
        self.textField = [[CKRecipeSearchTextField alloc] initWithFrame:(CGRect){
            kContentInsets.left,
            kContentInsets.top,
            self.bounds.size.width - kContentInsets.left - kContentInsets.right,
            self.bounds.size.height - kContentInsets.top - kContentInsets.bottom
        }];
        self.textField.keyboardType = UIKeyboardTypeAlphabet;
//        self.textField.backgroundColor = [UIColor greenColor];
        self.textField.returnKeyType = UIReturnKeySearch;
        self.textField.delegate = self;
        self.textField.font = kFont;
        self.textField.textColor = kTextColour;
        self.textField.leftViewMode = UITextFieldViewModeAlways;
        self.textField.leftView = self.leftSearchView;
        self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
        self.textField.rightView = self.closeButton;
        self.textField.placeholder = self.placeholderText;
//        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholderText
                                                                               attributes:@{ NSForegroundColorAttributeName: kPlaceholderColour }];
        [self addSubview:self.textField];
    }
    return self;
}

- (CGSize)sizeForExpanded:(BOOL)expanded {
    return expanded ? kExpandedSize : kMiniSize;
}

- (void)expand:(BOOL)expand {
    [self expand:expand animated:NO];
}

- (void)expand:(BOOL)expand animated:(BOOL)animated {
    CGAffineTransform transform = expand ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.8, 0.8);
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.textField.transform = transform;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.textField.transform = transform;
    }
}

- (void)focus:(BOOL)focus {
    if (focus) {
        [self.searchButton setBackgroundImage:[self imageForSearchSelected:NO] forState:UIControlStateNormal];
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholderText
                                                                               attributes:@{ NSForegroundColorAttributeName: kPlaceholderColour }];
        self.textField.text = self.currentSearch;
        [self.textField becomeFirstResponder];
    } else {
        [self.searchButton setBackgroundImage:[self imageForSearchSelected:YES] forState:UIControlStateNormal];
        self.textField.attributedPlaceholder = nil;
        self.textField.text = nil;
        [self.textField resignFirstResponder];
    }
}

- (void)clearSearch {
    self.currentSearch = nil;
    self.textField.text = nil;
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [self.textField resignFirstResponder];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // Re-adjust the textfield frame.
    CGRect textFieldFrame = self.textField.frame;
    textFieldFrame = (CGRect){
        kContentInsets.left,
        kContentInsets.top,
        self.bounds.size.width - kContentInsets.left - kContentInsets.right,
        self.bounds.size.height - kContentInsets.top - kContentInsets.bottom
    };
    self.textField.frame = textFieldFrame;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL shouldFocus = [self.delegate recipeSearchFieldShouldFocus];
    if (shouldFocus) {
        [self updateCloseButton];
    }
    return shouldFocus;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *text = [self currentText];
    self.textField.text = text;
    if ([text length] >= self.minCharacterLimit) {
        [self.delegate recipeSearchFieldViewSearchByText:text];
        [self.textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL isBackspace = [newString length] < [textField.text length];
    BOOL shouldChange = NO;
    
    if ([textField.text length] >= self.characterLimit && !isBackspace) {
        return NO;
    }
    
    if (self.forceUppercase) {
        
        UITextPosition *beginning = textField.beginningOfDocument;
        UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
        UITextPosition *end = [textField positionFromPosition:start offset:range.length];
        UITextRange *textRange = [textField textRangeFromPosition:start toPosition:end];
        
        // replace the text in the range with the upper case version of the replacement string
        [textField replaceRange:textRange withText:[string uppercaseString]];
        
    } else {
        
        shouldChange = YES;
    }
    
    // Remember search term.
    self.currentSearch = self.textField.text;
    
    [self updateCloseButton];
    
    return shouldChange;
}

#pragma mark - Properties

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        UIImage *image = [[UIImage imageNamed:@"cook_dash_search_textfield.png"] resizableImageWithCapInsets:(UIEdgeInsets){ 7.0, 9.0, 10.0, 9.0 }];
        _backgroundView = [[UIImageView alloc] initWithImage:image];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    }
    return _backgroundView;
}

- (UIView *)leftSearchView {
    if (!_leftSearchView) {
        
        // Add some padding to the right.
        CGRect frame = self.searchButton.frame;
        frame.size.width += 10.0;
        
        _leftSearchView = [[UIView alloc] initWithFrame:frame];
        [_leftSearchView addSubview:self.searchButton];
    }
    return _leftSearchView;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [self buttonWithImage:[self imageForSearchSelected:YES]
                                selectedImage:[self imageForSearchSelected:YES]
                                       target:self selector:@selector(searchTapped)];
        _searchButton.userInteractionEnabled = NO;
    }
    return _searchButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [self buttonWithImage:[self imageForCloseOffState:YES]
                               selectedImage:[self imageForCloseOffState:YES]
                                      target:self selector:@selector(clearTapped)];
    }
    return _closeButton;
}

#pragma mark - Private methods

- (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target
                     selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    if (selectedImage) {
        [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
        [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    }
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    button.userInteractionEnabled = (target != nil && selector != nil);
    button.autoresizingMask = UIViewAutoresizingNone;
    return button;
}

- (UIImage *)imageForSearchSelected:(BOOL)selected {
    return selected ? [UIImage imageNamed:@"cook_dash_icons_textfield_search.png"] : [UIImage imageNamed:@"cook_dash_icons_textfield_search.png"];
}

- (UIImage *)imageForCloseOffState:(BOOL)offState {
    return offState ? [UIImage imageNamed:@"cook_dash_icons_textfield_clear_onpress.png"] : [UIImage imageNamed:@"cook_dash_icons_textfield_clear.png"];
}

- (void)searchTapped {
    // Nothing.
}

- (void)clearTapped {
    NSString *currentText = [self currentText];
    if ([currentText length] > 0) {
        self.currentSearch = nil;
        self.textField.text = nil;
    } else {
        [self.textField resignFirstResponder];
    }
    
    [self updateCloseButton];
    [self.delegate recipeSearchFieldViewClearRequested];
}

- (NSString *)currentText {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)updateCloseButton {
    
    // Check empty text and clear button.
    if ([self.textField.text length] > 0) {
        [self.closeButton setBackgroundImage:[self imageForCloseOffState:NO] forState:UIControlStateNormal];
    } else {
        [self.closeButton setBackgroundImage:[self imageForCloseOffState:YES] forState:UIControlStateNormal];
    }
}

@end
