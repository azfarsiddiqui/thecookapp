//
//  TodayViewController.m
//  CookToday
//
//  Created by Gerald on 2/09/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "TodayViewController.h"
#import "NSString+Utilities.h"
#import <NotificationCenter/NotificationCenter.h>
#import "CKTodayRecipe.h"
#import "TodayRecipeCell.h"
#import "TTTTimeIntervalFormatter.h"
#import <Parse/Parse.h>

@interface TodayViewController () <NCWidgetProviding, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) IBOutlet UITableView *tabelView;

@end

@implementation TodayViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [Parse setApplicationId:@"fYp3YAuFHXpdYNTdjfvZtkbJOXrAL4FGCtj4kMIN" clientKey:@"0Tsu1RPH7tfLXcpzERyfVaCCoV9nZwwowFD3Vewx"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    [self.timeIntervalFormatter setUsesIdiomaticDeicticExpressions:NO];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadDataWithCompletion:^{
        NSLog(@"Success");
    } failure:^{
        NSLog(@"Failure");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    [self loadDataWithCompletion:^{
        completionHandler(NCUpdateResultNewData);
    } failure:^{
        completionHandler(NCUpdateResultFailed);
    }];
//    completionHandler(NCUpdateResultNewData);
}

- (void)loadDataWithCompletion:(void (^)())completion failure:(void (^)())failure {
    [CKTodayRecipe latestRecipesWithSuccess:^(NSArray *object) {
        self.dataSource = object;
        [self.tabelView reloadData];
        completion();
    } failure:^(NSError *error) {
        failure();
    }];
}

- (NSAttributedString *)formattedShortDurationDisplayForMinutes:(NSInteger)minutes {
    NSMutableAttributedString *formattedDisplay = [[NSMutableAttributedString alloc] init];
    NSDictionary *bigAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:14], NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSDictionary *smallAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:11], NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSInteger hours = (minutes / 60);
    if (hours > 0) {
        NSInteger remainderMinutes = minutes % 60;
        NSAttributedString *hourNumber = [[NSAttributedString alloc] initWithString:[@(hours) stringValue] attributes:bigAttributes];
        NSAttributedString *hourString = [[NSAttributedString alloc] initWithString:@"h" attributes:smallAttributes];
        [formattedDisplay appendAttributedString:hourString];
        [formattedDisplay appendAttributedString:hourNumber];
        
        if (remainderMinutes > 0) {
            NSAttributedString *minuteNumber = [[NSAttributedString alloc] initWithString:[@(remainderMinutes) stringValue] attributes:bigAttributes];
            NSAttributedString *minuteString = [[NSAttributedString alloc] initWithString:@"m" attributes:smallAttributes];
            if (remainderMinutes < 10) {
                NSAttributedString *zeroString = [[NSAttributedString alloc] initWithString:@"0" attributes:bigAttributes];
                [formattedDisplay appendAttributedString:zeroString];
            }
            [formattedDisplay appendAttributedString:minuteNumber];
            [formattedDisplay appendAttributedString:minuteString];
        }
    } else {
        NSAttributedString *minuteNumber = [[NSAttributedString alloc] initWithString:[@(minutes) stringValue] attributes:bigAttributes];
        NSAttributedString *minuteString = [[NSAttributedString alloc] initWithString:@"m" attributes:smallAttributes];
        [formattedDisplay appendAttributedString:minuteNumber];
        [formattedDisplay appendAttributedString:minuteString];
    }
    return formattedDisplay;
}

- (NSString *)servesDisplayForNumber:(NSNumber *)serves {
    NSString *servesDisplay = [serves stringValue];
    if (serves && [serves integerValue] > 12) {
        servesDisplay = [NSString stringWithFormat:@"%d+", 12];
    }
    return servesDisplay;
}

- (NSString *)makesDisplayForNumber:(NSNumber *)makes {
    NSString *makesDisplay = [makes stringValue];
    if (makes && [makes integerValue] > 60) {
        makesDisplay = [NSString stringWithFormat:@"%i+", 60];
    }
    return makesDisplay;
}

#pragma mark - UITableView delegate and datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN([self.dataSource count], 3);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodayRecipeCell *cell = [self.tabelView dequeueReusableCellWithIdentifier:@"TodayRecipeCell"];
    CKTodayRecipe *recipe = [self.dataSource objectAtIndex:indexPath.row];
    if (recipe) {
        [self imageWithURL:[NSURL URLWithString:recipe.recipePicUrl] success:^(UIImage *image) {
            if (image) {
                cell.backgroundImageView.image = image;
            }
        } failure:^(NSError *error) {
            cell.backgroundImageView.image = nil;
        }];
        [self imageWithURL:[NSURL URLWithString:recipe.profilePicUrl] success:^(UIImage *image) {
            if (image) {
                cell.profileImageView.image = image;
            }
        } failure:^(NSError *error) {
            cell.profileImageView.image = nil;
        }];
        
        cell.servesLabel.text = recipe.numServes;
        cell.timeLabel.attributedText = [self formattedShortDurationDisplayForMinutes:[recipe.makeTimeMins intValue]];
        cell.titleLabel.text = recipe.recipeName;
        cell.regionLabel.text = recipe.countryName;
        if (recipe.recipeUpdatedAt) {
            cell.timestampLabel.text = [self.timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:recipe.recipeUpdatedAt];
        }
    }
    
    return cell;
}

#pragma mark - Helper methods for images

- (NSURLSessionTask *)imageWithURL:(NSURL *)url
                           success:(void (^)(UIImage *image))success
                           failure:(void (^)(NSError *error))failure {
    
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            return failure(error);
        } else if (response) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //useless optimization as it seems to be decoded while UIImageView is displayed
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        success(image);
                    }
                });
            });
        }
    }];
    
    [task resume];
    return task;
}

@end
