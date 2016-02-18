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
    NSDictionary *carForCellDict = self.myCars[indexPath.row];
    NSString *color = carForCellDict[@"color"];
    NSString *year = carForCellDict[@"year"];
    NSString *make = carForCellDict[@"make"];
    NSString *model = carForCellDict[@"model"];

    NSString *cellLabel = [NSString stringWithFormat:@"%@ - %@ %@  %@", color, year, make, model];
    cell.textLabel.text = cellLabel;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myCars.count;
}

- (IBAction)onAddButtonTapped:(UIBarButtonItem *)sender {

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedCellText = cell.textLabel.text;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = sender;
        QuikDamageListVC *dest = segue.destinationViewController;
        dest.textFromCell = cell.textLabel.text;
        dest.carDictionary = [self.myCars objectAtIndex:[self.tableView indexPathForCell:cell].row];
    }
}


- (void) populateUser{
    [self.ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@" value of snap%@", snapshot.value);
        NSDictionary *userDictionary = snapshot.value;
        self.currentUser = [self.currentUser initWithDictionary:userDictionary];
        NSLog(@"id: %@ username: %@ email: %@", self.currentUser.idNumber, self.currentUser.userName, self.currentUser.email);
    }];
}

-(void) loadMyCars {
    self.ref = [[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/cars"];
    [self.ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray *carsFromFirebase = [NSMutableArray new];
        for (NSString* vinNumber in snapshot.value) {
            NSDictionary *carDict = [snapshot.value objectForKey:vinNumber];
            NSString *owner = [carDict objectForKey:@"owner"];
            if([owner isEqualToString:self.currentUser.idNumber]){
                [carsFromFirebase addObject:carDict];
            }
        }
        self.myCars = carsFromFirebase;
        [self.tableView reloadData];
    }];
}

- (IBAction)onLogoutTapped:(UIBarButtonItem *)sender {
    
    NSString *accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
    
    if (accessToken == nil){
        NSLog(@"FB acces token == nil");
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
        [ref unauth];
    }else {
        NSLog(@"FB acces token != nil");
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
