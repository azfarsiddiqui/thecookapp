//
//  CKSearchFieldView.m
//  CKSearchFieldView
//
//  Created by Jeff Tan-Ang on 13/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKSearchFieldView.h"
#import "UIColor+Expanded.h"

@interface CKSearchFieldView () <UITextFieldDelegate>

@property (nonatomic, weak) id<CKSearchFieldViewDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, assign) BOOL forceUppercase;
@property (nonatomic, assign) NSInteger characterLimit;
@property (nonatomic, assign) NSInteger minCharacterLimit;
@property (nonatomic, strong) NSString *currentSearch;

@end

@implementation CKSearchFieldView

#define kTextFont       [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20]
#define kContentInsets  (UIEdgeInsets){ 10.0, 20.0, 10.0, 20.0 }

- (id)initWithWidth:(CGFloat)width delegate:(id<CKSearchFieldViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.delegate = delegate;
        
        // Behaviour parameters.
        self.forceUppercase = YES;
        self.characterLimit = 30;
        self.minCharacterLimit = 2;
        
        // Background and self frame.
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_library_searchfield.png"]
                                    resizableImageWithCapInsets:(UIEdgeInsets) { 0.0, 7.0, 0.0, 7.0 }];
        CGRect frame = self.frame;
        frame.size.width = width;
        frame.size.height = backgroundImage.size.height;
        self.frame = frame;
        
        self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        self.backgroundView.frame = self.bounds;
        [self addSubview:self.backgroundView];
        
        // Text field.
        self.textField = [[UITextField alloc] initWithFrame:(CGRect){
            kContentInsets.left,
            kContentInsets.top,
            self.bounds.size.width - kContentInsets.left - kContentInsets.right,
            self.bounds.size.height - kContentInsets.top - kContentInsets.bottom
        }];
        self.textField.keyboardType = UIKeyboardTypeAlphabet;
        self.textField.returnKeyType = UIReturnKeySearch;
        self.textField.delegate = self;
        self.textField.font = kTextFont;
        self.textField.leftViewMode = UITextFieldViewModeAlways;
        self.textField.leftView = self.searchButton;
        self.textField.rightViewMode = UITextFieldViewModeWhileEditing;
        self.textField.rightView = self.closeButton;
        [self addSubview:self.textField];
    }
    return self;
}

- (void)focus:(BOOL)focus {
    if (focus) {
        self.textField.placeholder = @"SEARCH BY NAME";
        self.textField.text = self.currentSearch;
        [self.textField becomeFirstResponder];
    } else {
        self.textField.placeholder = nil;
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

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return [self.delegate searchFieldShouldFocus];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *text = [self currentText];
    self.textField.text = text;
    if ([text length] >= self.minCharacterLimit) {
        [self.delegate searchFieldViewSearchByText:text];
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
    
    
    self.currentSearch = self.textField.text;
    return shouldChange;
}

#pragma mark - Properties

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [self buttonWithImage:[UIImage imageNamed:@"cook_library_icons_search.png"]
                                selectedImage:[UIImage imageNamed:@"cook_library_icons_search_off.png"]
                                       target:self selector:@selector(searchTapped)];
    }
    return _searchButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [self buttonWithImage:[UIImage imageNamed:@"cook_library_icons_clear.png"]
                                selectedImage:[UIImage imageNamed:@"cook_library_icons_clear_off.png"]
                                       target:self selector:@selector(clearTapped)];
    }
    return _closeButton;
}

#pragma mark - Private methods

- (NSString *)currentText {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)searchTapped {
    [self.delegate searchFieldViewSearchIconTapped];
}

- (void)clearTapped {
    NSString *currentText = [self currentText];
    if ([currentText length] > 0) {
        self.currentSearch = nil;
        self.textField.text = nil;
    } else {
        [self.textField resignFirstResponder];
    }
    [self.delegate searchFieldViewClearRequested];
}

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

@end
