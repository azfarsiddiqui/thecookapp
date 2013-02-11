//
//  IngredientEditorViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientEditorViewController.h"
#import "IngredientTableViewCell.h"
#import "EditableIngredientTableViewCell.h"
#import "ViewHelper.h"

#define kEditIngredientTableViewCell   @"EditIngredientTableViewCell"
#define kCellHeight 90.0f

@interface IngredientEditorViewController ()<UITableViewDataSource,UITableViewDelegate, IngredientEditTableViewCellDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,assign) UIEdgeInsets viewInsets;
@end

@implementation IngredientEditorViewController

- (id)initWithFrame:(CGRect)frame withViewInsets:(UIEdgeInsets)viewInsets
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.viewInsets = viewInsets;
        [self config];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateFrameSize:(CGRect)frame forExpansion:(BOOL)expansion
{
    self.view.frame = frame;
    CGRect tableViewframe = CGRectZero;
    if (expansion) {
        tableViewframe = CGRectMake(self.viewInsets.left,
                                    self.viewInsets.top,
                                    frame.size.width - self.viewInsets.left - self.viewInsets.right,
                                    frame.size.height - self.viewInsets.top - self.viewInsets.bottom);
    } else {
        tableViewframe = CGRectMake(0,
                                    0,
                                    frame.size.width,
                                    frame.size.height);
    }
    self.tableView.frame = tableViewframe;
    
}

#pragma mark - IngredientEditDelegate

-(void)didUpdateIngredientAtTouch:(UITouch *)touch withMeasurement:(NSString *)measurementString description:(NSString *)ingredientDescription
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [touch locationInView: self.tableView]];
    //adjusted index
    [self.ingredientEditorDelegate didUpdateIngredient:ingredientDescription atRowIndex:indexPath.row + self.selectedIndex];
}

#pragma mark - Private Methods

-(void)config
{
    [self addTableView];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredientList count] - self.selectedIndex;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger adjustedIndex = self.selectedIndex + indexPath.row;
    NSString *data = [self.ingredientList objectAtIndex:adjustedIndex];
    EditableIngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEditIngredientTableViewCell];
    [cell configureCellWithText:data forRowAtIndexPath:indexPath editDelegate:self];
    return cell;
}

-(void) addTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)
                                                          style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor =[UIColor blackColor];
    [tableView registerClass:[EditableIngredientTableViewCell class] forCellReuseIdentifier:kEditIngredientTableViewCell];
    self.tableView = tableView;
    [self.view addSubview:tableView];
}

@end
