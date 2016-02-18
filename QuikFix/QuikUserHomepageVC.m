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
#import "Firebase/Firebase.h"
#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface QuikUserHomepageVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *myCars;
@property Firebase *ref;
@property QuikUser *currentUser;

@end

@implementation QuikUserHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateCarsArray];
    self.currentUser = [QuikUser new];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    
    self.ref = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/users"] childByAppendingPath:uid];
    [self populateUser];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myCars.count;
}

- (IBAction)onAddButtonTapped:(UIBarButtonItem *)sender {
    
}

- (void) populateUser{
    [self.ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
      NSLog(@" value of snap%@", snapshot.value);
        NSDictionary *userDictionary = snapshot.value;
        self.currentUser = [self.currentUser initWithDictionary:userDictionary];
        NSLog(@"id: %@ username: %@ email: %@", self.currentUser.idNumber, self.currentUser.userName, self.currentUser.email);
    }];
    
}

-(void) populateCarsArray {
    
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
