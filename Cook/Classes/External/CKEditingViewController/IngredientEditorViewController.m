//
//  IngredientEditorViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientEditorViewController.h"
#import "EditableIngredientTableViewCell.h"
#import "IngredientTableViewCell.h"
#import "ViewHelper.h"
#define kEditIngredientTableViewCell   @"EditIngredientTableViewCell"

@interface IngredientEditorViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIButton *doneButton;
@end

@implementation IngredientEditorViewController


- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor greenColor];
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

-(void)updateFrameSize:(CGRect)frame
{
    self.view.frame = frame;
    self.tableView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
}

-(void)doneTapped:(UIButton*)doneButton
{
    DLog(@"Done button tapped");
}

#pragma mark - Private Methods

-(void)config
{
    [self addTableView];
//    [self addDoneButton];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredientList count] - self.selectedIndex;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger adjustedIndex = self.selectedIndex + indexPath.row;
    NSString *data = [self.ingredientList objectAtIndex:adjustedIndex];
    EditableIngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEditIngredientTableViewCell];
    [cell configureCellWithText:data forRowAtIndexPath:indexPath];
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

-(void) addDoneButton
{
    self.doneButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                           target:self selector:@selector(doneTapped:)];
    self.doneButton.frame = CGRectMake(self.tableView.frame.origin.x + self.tableView.frame.size.width - floorf(self.doneButton.frame.size.width / 2.0),
                                       self.tableView.frame.origin.y - floorf(self.doneButton.frame.size.height / 3.0),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);
    [self.view addSubview:self.doneButton];

}

@end
