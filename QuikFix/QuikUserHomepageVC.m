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
#import <QuartzCore/QuartzCore.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "NotificationsVC.h"
#import "QuikClaim.h"
#import "QuikOffers.h"

@interface QuikUserHomepageVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noCarsView;
@property (weak, nonatomic) IBOutlet UIButton *addACar;
@property (nonatomic, strong) NSMutableArray *myCars;
@property (nonatomic, strong) NSString *selectedCellText;
@property (nonatomic, strong) QuikUser *currentUser;
@property (nonatomic, strong) QuikCar *carSelected;
@property (nonatomic, strong) NSMutableArray *offersNotSeen;

@end

@implementation QuikUserHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];

    [self.tableView registerClass:[QuikCarTableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.noCarsView.hidden = YES;
    self.addACar.layer.cornerRadius = 3;
    self.addACar.clipsToBounds = YES;

    self.selectedCellText = @"";
    //self.currentUser = [QuikUser new];
    //self.myCars = [NSMutableArray new];
    
    
    [self populateUser];
    [self loadMyCars];
    
//    BOOL isVendor = [[NSUserDefaults standardUserDefaults] boolForKey:@"isVendorProfile"];
//    if (!(isVendor)) {
//        //[self loadOffersFromFirebase];
//        self.offersNotSeen =[NSMutableArray new];
//    }
//    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QuikCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    QuikCar *car = self.myCars[indexPath.section];
    cell.tableViewWidth = self.tableView.bounds.size.width;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.car = car;
    cell.layer.cornerRadius = 3;
    cell.clipsToBounds = YES;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.myCars.count == 0) {
        self.tableView.hidden = YES;
        self.noCarsView.hidden = NO;
    }
    else{
        self.tableView.hidden = NO;
        self.noCarsView.hidden = YES;
    }

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
        QuikCar *removeCar = self.myCars[indexPath.section];
        [removeFromArray removeObjectAtIndex:indexPath.section];

        self.myCars = removeFromArray;
        [self.tableView reloadData];

        NSString *removeCarURL = [NSString stringWithFormat:@"https://beefstagram.firebaseio.com/cars/%@", removeCar.vin];
        Firebase *removeRef = [[Firebase alloc] initWithUrl: removeCarURL];
        [removeRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            //delete the claims for car
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
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    Firebase* ref = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/users"] childByAppendingPath:uid];
    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
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
    }
    else {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];

        [loginManager logOut];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onOffersTapped:(UIBarButtonItem *)sender {
    NotificationsVC *notificationsVC = [NotificationsVC new];
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Notifications" bundle:[NSBundle mainBundle]];
    notificationsVC = [board instantiateInitialViewController];
    
    
    [self.navigationController pushViewController:notificationsVC animated:YES];
}

//- (void) loadOffersFromFirebase{
//    NSLog(@"loadOffersFromFirebase");
//    Firebase *claimRef = [[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"] childByAppendingPath:@"claims"];
//    
//    NSString *uid = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
//    
//    [[[claimRef queryOrderedByChild:@"owner"] queryEqualToValue:uid] observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
//        if(snapshot.exists){
//            NSLog(@"child has been changed");
//            QuikClaim *currentClaim = [[QuikClaim alloc] initWithDictionary:snapshot.value];
//            for (QuikOffers *offer in currentClaim.offers) {
//                if (offer.hasBeenChecked == NO) {
//                    [self.offersNotSeen addObject:offer];
//              
//                }
//            }
//            [self checkForNewOffers: currentClaim];
//        }
//
//    }];
//}

//- (void) checkForNewOffers: (QuikClaim *) claim{
//            NSLog(@"checkForNewOffers called");
//    if (self.offersNotSeen.count == 0){
//        NSLog(@"no new offers");
//    }else{
//        NSLog(@"new offers!!");
//        [self setupLocalNotifications: claim];
//    }
//}

//- (void)setupLocalNotifications: (QuikClaim *)claim
//{
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    NSDate *now = [NSDate date];
//    localNotification.fireDate = now;
//    localNotification.alertBody = [NSString stringWithFormat:@"For %@ with %@ %@", claim.carDetail, claim.panel, claim.damageType];
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    localNotification.applicationIconBadgeNumber = 1; // increment
//    
//    //    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
//    //    localNotification.userInfo = infoDict;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//}

@end
