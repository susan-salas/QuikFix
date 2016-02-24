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
    self.selectedCellText = @"";
    self.currentUser = [QuikUser new];
    self.myCars = [NSMutableArray new];
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    self.ref = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/users"] childByAppendingPath:uid];
    [self populateUser];
    [self loadMyCars];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    QuikCar *car = self.myCars[indexPath.row];
    cell.textLabel.text = car.detail;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myCars.count;
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = sender;
        QuikDamageListVC *dest = segue.destinationViewController;
        dest.car = [self.myCars objectAtIndex:[self.tableView indexPathForCell:cell].row];
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
