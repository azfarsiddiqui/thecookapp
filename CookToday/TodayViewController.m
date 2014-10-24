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

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) IBOutlet UITableView *tabelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeight;
//@property (nonatomic, strong) NSURLSession *session;

@end

@implementation TodayViewController

#define LAST_UPDATED_KEY @"lastUpdated"

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [Parse setApplicationId:@"fYp3YAuFHXpdYNTdjfvZtkbJOXrAL4FGCtj4kMIN" clientKey:@"0Tsu1RPH7tfLXcpzERyfVaCCoV9nZwwowFD3Vewx"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray new];
    self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    [self.timeIntervalFormatter setUsesIdiomaticDeicticExpressions:NO];
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.cook.thecookapp.config"];
//    configuration.sharedContainerIdentifier = @"group.com.cook.thecookapp";
//    configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
//    self.session = [NSURLSession sessionWithConfiguration:configuration];
    
//    self.preferredContentSize = CGSizeMake(800, 200);
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    sleep(0.5);
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

#pragma mark - NCWidgetProviding methods

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encoutered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"com.cook.thecookapp"];
    NSDate *lastUpdated = [sharedDefaults objectForKey:LAST_UPDATED_KEY];
    if ([lastUpdated timeIntervalSinceNow] > 600) {
        [self loadDataWithCompletion:^{
            completionHandler(NCUpdateResultNewData);
        } failure:^{
            completionHandler(NCUpdateResultFailed);
        }];
    } else {
        completionHandler(NCUpdateResultNoData);
    }
//    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (void)loadDataWithCompletion:(void (^)())completion failure:(void (^)())failure {
    [CKTodayRecipe latestRecipesWithSuccess:^(NSArray *object) {
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"com.cook.thecookapp"];
        [sharedDefaults setObject:[NSDate date] forKey:LAST_UPDATED_KEY];
        [sharedDefaults synchronize];
        
        //Iterate through array of Recipes and grab background images
        [self.dataSource removeAllObjects];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [object enumerateObjectsUsingBlock:^(CKTodayRecipe *obj, NSUInteger idx, BOOL *stop) {
                if (!obj.backgroundImage) {
                    [self imageWithURL:[NSURL URLWithString:obj.recipePic.url] success:^(UIImage *image) {
                        if (image) {
//                            NSLog(@"Loaded image for %@", obj.recipeName);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                obj.backgroundImage = image;
                                [self.dataSource addObject:obj];
                                self.tableHeight.constant = [self.dataSource count] * 100;
                                [self.dataSource sortUsingComparator:^NSComparisonResult(CKTodayRecipe *obj1, CKTodayRecipe *obj2) {
                                    return [obj2.recipeUpdatedAt compare:obj1.recipeUpdatedAt];
                                }];
                                [self.tabelView reloadData];
                            });
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"Failed background image");
                    }];
                } else { //How does fresh recipe already have data? Just in case...
                    [self.dataSource addObject:obj];
                    [self.tabelView reloadData];
                }
            }];
        });
        completion();
    } failure:^(NSError *error) {
        failure();
    }];
}

- (NSAttributedString *)formattedShortDurationDisplayForMinutes:(NSInteger)minutes {
    NSMutableAttributedString *formattedDisplay = [[NSMutableAttributedString alloc] init];
    NSDictionary *bigAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:12], NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSDictionary *smallAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:10], NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSInteger hours = (minutes / 60);
    if (hours > 0) {
        NSInteger remainderMinutes = minutes % 60;
        NSAttributedString *hourNumber = [[NSAttributedString alloc] initWithString:[@(hours) stringValue] attributes:bigAttributes];
        NSAttributedString *hourString = [[NSAttributedString alloc] initWithString:@"h" attributes:smallAttributes];
        [formattedDisplay appendAttributedString:hourNumber];
        [formattedDisplay appendAttributedString:hourString];
        
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
        cell.backgroundImageView.image = recipe.backgroundImage;
        if (recipe.profileImage) {
            cell.profileImageView.image = recipe.profileImage;
        } else {
            cell.profileImageView.image = [UIImage imageNamed:@"cook_default_profile"];
            [self imageWithURL:[NSURL URLWithString:recipe.profilePicUrl] success:^(UIImage *image) {
                if (image) {
                    recipe.profileImage = image;
                    cell.profileImageView.image = image;
                }
            } failure:^(NSError *error) {
                NSLog(@"Failed profile image");
                cell.profileImageView.image = nil;
            }];
        }
        
        cell.servesLabel.text = recipe.numServes;
        if (recipe.makeTimeMins != (id)[NSNull null]) {
            cell.timeLabel.attributedText = [self formattedShortDurationDisplayForMinutes:[recipe.makeTimeMins integerValue]];
        }
        cell.titleLabel.text = recipe.recipeName.uppercaseString;
        cell.regionLabel.text = recipe.countryName.uppercaseString;
        if (recipe.recipeUpdatedAt) {
            cell.timestampLabel.text = [self.timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:recipe.recipeUpdatedAt].uppercaseString;
        }
        
        if ([recipe.quantityType isEqual:@0]) {
            cell.makesTypeImageView.image = [UIImage imageNamed:@"cook_widget_icon_serves"];
        } else if ([recipe.quantityType isEqual:@1]) {
            cell.makesTypeImageView.image = [UIImage imageNamed:@"cook_widget_icon_makes"];
        }
        
        if (recipe.numServes <= 0) {
            cell.makesTypeImageView.alpha = 0.0;
        }
        if (recipe.makeTimeMins <= 0) {
            cell.makesTimeImageView.alpha = 0.0;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CKTodayRecipe *recipe = [self.dataSource objectAtIndex:indexPath.row];
    // Recipe App URL
    NSString *appURL = [NSString stringWithFormat:@"cookapp:///recipe/%@", recipe.recipeObjectId];
    [[self extensionContext] openURL:[NSURL URLWithString:appURL] completionHandler:nil];
}

#pragma mark - Helper methods for images

- (NSURLSessionTask *)imageWithURL:(NSURL *)url
             success:(void (^)(UIImage *image))success
             failure:(void (^)(NSError *error))failure {
//    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.cook.thecookapp.config"];
//    sessionConfig.sharedContainerIdentifier = @"group.com.cook.thecookapp";
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Failed to download image");
            return failure(error);
        } else if (response) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //useless optimization as it seems to be decoded while UIImageView is displayed
//                NSLog(@"Downloaded to: %@", location.absoluteString);
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        //Cache image
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
