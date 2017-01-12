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
#define RECIPE_CACHE_KEY @"cachedRecipes"

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
            configuration.applicationId = @"36DsRqQPcsSgInjBmAiUYDHFtxkFqlxHnoli69VS";
            configuration.clientKey = @"c4J2TvKqYVh7m7pfZRasve4HuySArVSDxpAOXmMN";
            configuration.server = @"https://pg-app-pgajndhfkya28qd545dzexybadqt8h.scalabl.cloud/1/";
            
        }]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray new];
    self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    [self.timeIntervalFormatter setUsesIdiomaticDeicticExpressions:NO];
    
//    self.preferredContentSize = CGSizeMake(800, 200);
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Load data from cache
    NSArray *recipeArray = [CKTodayRecipe getCachedRecipes];
//    //Grab images for all recipes
//    [recipeArray enumerateObjectsUsingBlock:^(CKTodayRecipe *obj, NSUInteger idx, BOOL *stop) {
//        obj.backgroundImage = [UIImage imageWithData:obj.recipeImageData];
//    }];
    self.dataSource = [NSMutableArray arrayWithArray:recipeArray];
    [self.dataSource sortUsingComparator:^NSComparisonResult(CKTodayRecipe *obj1, CKTodayRecipe *obj2) {
        return [obj2.recipeUpdatedAt compare:obj1.recipeUpdatedAt];
    }];
    self.tableHeight.constant = [self.dataSource count] * 100;
    
//    [self.tabelView reloadData];
    
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
        NSArray *recipeArray = [CKTodayRecipe getCachedRecipes];
        self.dataSource = [NSMutableArray arrayWithArray:recipeArray];
        [self.dataSource sortUsingComparator:^NSComparisonResult(CKTodayRecipe *obj1, CKTodayRecipe *obj2) {
            return [obj2.recipeUpdatedAt compare:obj1.recipeUpdatedAt];
        }];
        self.tableHeight.constant = [self.dataSource count] * 100;
        //    NSLog(@"Datasource count: %i", [self.dataSource count]);
        completionHandler(NCUpdateResultNoData);
    }
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [object enumerateObjectsUsingBlock:^(CKTodayRecipe *obj, NSUInteger idx, BOOL *stop) {
                // Check if downloaded recipe already exists in cache
                __block BOOL containsRecipe = NO;
                [self.dataSource enumerateObjectsUsingBlock:^(CKTodayRecipe *obj2, NSUInteger idx, BOOL *stop) {
                    if ([obj.recipeObjectId isEqualToString:obj2.recipeObjectId]) {
                        containsRecipe = YES;
                    }
                }];
                
                // If recipe isn't contained, download new background image if needed
                if (!containsRecipe) {
//                    NSLog(@"Loading data for: %@", obj.recipeName);
                    if (!obj.backgroundImage && !obj.recipeImageData) {
                        [self imageWithURL:[NSURL URLWithString:obj.recipePic.url] success:^(UIImage *image) {
                            if (image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    obj.backgroundImage = image;
                                    obj.recipeImageData = UIImageJPEGRepresentation(image, 0.8);
                                    [self cacheRecipe:obj];
                                    
                                    [self.dataSource addObject:obj];
                                    self.tableHeight.constant = [self.dataSource count] * 100;
                                    
                                    //Shuffle data by date
                                    [self.dataSource sortUsingComparator:^NSComparisonResult(CKTodayRecipe *obj1, CKTodayRecipe *obj2) {
                                        return [obj2.recipeUpdatedAt compare:obj1.recipeUpdatedAt];
                                    }];
                                    [self.tabelView reloadData];
                                });
                            }
                        } failure:^(NSError *error) {
                            NSLog(@"Failed background image");
                        }];
                    }
                    else { //How does fresh recipe already have data? Just in case...
                        [self.dataSource addObject:obj];
                    }
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

- (void)cacheRecipe:(CKTodayRecipe *)recipe {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"com.cook.thecookapp"];
    NSMutableArray *currentCacheArray = [NSMutableArray arrayWithArray:[sharedDefaults objectForKey:RECIPE_CACHE_KEY]];
    
    __block BOOL containsRecipe = NO;
    [currentCacheArray enumerateObjectsUsingBlock:^(NSDictionary *obj2, NSUInteger idx, BOOL *stop) {
        if ([recipe.recipeObjectId isEqualToString:[obj2 objectForKey:@"recipeObjectId"]]) {
            containsRecipe = YES;
        }
    }];
    
    if (!containsRecipe){
//        NSLog(@"Caching recipe: %@", recipe.recipeName);
        [currentCacheArray addObject:[recipe dictionaryRepresentation]];
    }
    
    NSInteger maxRange = MIN([currentCacheArray count], 3);
    [currentCacheArray sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSDate *date1 = (NSDate *)[obj1 objectForKey:@"recipeUpdatedAt"];
        NSDate *date2 = (NSDate *)[obj2 objectForKey:@"recipeUpdatedAt"];
        return [date2 compare:date1];
    }];
    
    NSArray *subArray = [currentCacheArray subarrayWithRange:NSMakeRange(0, maxRange)];
    [sharedDefaults setObject:subArray forKey:RECIPE_CACHE_KEY];
    [sharedDefaults synchronize];
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
        if (recipe.backgroundImage) {
            cell.backgroundImageView.image = recipe.backgroundImage;
        } else if (recipe.recipeImageData) {
            UIImage *recipeImage = [UIImage imageWithData:recipe.recipeImageData];
            cell.backgroundImageView.image = recipeImage;
        }
        if (recipe.profileImage) {
            cell.profileImageView.image = recipe.profileImage;
        } else {
            cell.profileImageView.image = [UIImage imageNamed:@"cook_default_profile"];
            [self imageWithURL:[NSURL URLWithString:recipe.profilePicUrl] success:^(UIImage *image) {
                if (image) {
                    //Cell originally associated with recipe mgiht hve changed order
                    
                    //Get new indexPath
                    NSInteger newIndex = [self.dataSource indexOfObject:recipe];
                    TodayRecipeCell *newCell = (TodayRecipeCell *)[self.tabelView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
                    recipe.profileImage = image;
                    newCell.profileImageView.image = image;
                }
            } failure:^(NSError *error) {
                NSLog(@"Failed profile image");
                cell.profileImageView.image = [UIImage imageNamed:@"cook_default_profile"];
            }];
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
        } else {
            cell.makesTypeImageView.image = [UIImage imageNamed:@"cook_widget_icon_serves"];
        }
        
        //Hide and adjust constraint priority to properly center elements
        if (!recipe.numServes || [recipe.numServes isEqualToString:@"0"]) {
            cell.makesTypeImageView.hidden = YES;
            cell.timeFrontConstraint.priority = 901;
        } else {
            cell.makesTypeImageView.hidden = NO;
            cell.timeFrontConstraint.priority = 50;
        }
        
        if ([recipe.makeTimeMins integerValue] <= 0) {
            cell.makesTimeImageView.hidden = YES;
            cell.makesEndConstraint.priority = 901;
        } else {
            cell.makesTimeImageView.hidden = NO;
            cell.makesEndConstraint.priority = 50;
        }

        cell.servesLabel.text = recipe.numServes;
        if (recipe.makeTimeMins != (id)[NSNull null]) {
            cell.timeLabel.attributedText = [self formattedShortDurationDisplayForMinutes:[recipe.makeTimeMins integerValue]];
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
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Failed to download image");
            return failure(error);
        } else if (response) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //useless optimization as it seems to be decoded while UIImageView is displayed
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
