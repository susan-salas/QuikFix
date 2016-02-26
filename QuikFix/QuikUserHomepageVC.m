//
//  QuikUserHomepageVC.m
//  QuikFix
//
//  Created by Sean Barry on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikUserHomepageVC.h"
#import "QuikUser.h"
#import "QuikCar.h"
#import "QuikDamageListVC.h"
#import "Firebase/Firebase.h"
#import "LoginViewController.h"
#import "QuikCarTableViewCell.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface QuikUserHomepageVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *myCars;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property Firebase *ref;
@property QuikUser *currentUser;
@property QuikCar *carSelected;
@property NSString *selectedCellText;

@end

@implementation QuikUserHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[QuikCarTableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.selectedCellText = @"";
    self.currentUser = [QuikUser new];
    self.myCars = [NSMutableArray new];
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    self.ref = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/users"] childByAppendingPath:uid];
    UIColor *navColor = [UIColor colorWithRed:221.0 green:230.0 blue:231 alpha:1];
    [[self.navigationController navigationBar] setTintColor:navColor];

    [self populateUser];
    [self loadMyCars];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QuikCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    QuikCar *car = self.myCars[indexPath.section];
    cell.tableViewWidth = self.tableView.bounds.size.width;
    cell.car = car;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.myCars.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QuikCar *item = self.myCars[indexPath.section];
    return [QuikCarTableViewCell heightForCarItem:item width:self.tableView.bounds.size.width];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *removeFromArray = [[NSMutableArray alloc] initWithArray:self.myCars];
        QuikCar *removeCar = self.myCars[indexPath.row];
        [removeFromArray removeObjectAtIndex:indexPath.row];

        self.myCars = removeFromArray;
        [self.tableView reloadData];

        NSString *removeCarURL = [NSString stringWithFormat:@"https://beefstagram.firebaseio.com/cars/%@", removeCar.vin];
        Firebase *removeRef = [[Firebase alloc] initWithUrl: removeCarURL];
        [removeRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            Firebase *damageRef = [[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/claims"];
            [[[[damageRef queryOrderedByChild:@"carWithDamage"] queryEqualToValue:removeCar.vin] ref] removeValue];
        }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"CellTappedSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([sender isKindOfClass:[QuikCarTableViewCell class]]) {
        QuikCarTableViewCell *cell = sender;
        QuikDamageListVC *dest = segue.destinationViewController;
        dest.car = [self.myCars objectAtIndex:[self.tableView indexPathForCell:cell].section];
    }
}

- (void) populateUser{
    [self.ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSDictionary *userDictionary = snapshot.value;
        self.currentUser = [self.currentUser initWithDictionary:userDictionary];
    }];
}

-(void) loadMyCars {
    Firebase *carsRef = [[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/cars"];
    [carsRef  observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if(snapshot.exists){
            NSMutableArray *carsFromFirebase = [NSMutableArray new];
            for (NSString* vinNumber in snapshot.value) {
                NSDictionary *carDict = [snapshot.value objectForKey:vinNumber];
                NSString *owner = [carDict objectForKey:@"owner"];
                if([owner isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"uid"]]){
                    QuikCar *car = [[QuikCar alloc] initWithDictionary:carDict];
                    [carsFromFirebase addObject:car];
                }
            }
            self.myCars = carsFromFirebase;
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)onLogoutTapped:(UIBarButtonItem *)sender {
    
    NSString *accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
    
    if (accessToken == nil){
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
        [ref unauth];
    }else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
    [self dismissViewControllerAnimated:YES completion:nil];
//    LoginViewController *controller = [LoginViewController new];
//    UIStoryboard *board = [UIStoryboard storyboardWithName:@"LoginViewController" bundle:[NSBundle mainBundle]];
//    controller = [board instantiateInitialViewController];
//    [[self presentingViewController] presentViewController:controller animated:YES completion:nil];
}

@end
