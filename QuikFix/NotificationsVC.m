//
//  NotificationsVC.m
//  QuikFix
//
//  Created by Susan Salas on 2/20/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "NotificationsVC.h"
#import "Firebase/Firebase.h"
#import "QuikOffers.h"
#import "QuikClaim.h"
#import "Firebase/Firebase.h"
#import "QuikOffers.h"
#import "QuikOfferDetailsVC.h"

@interface NotificationsVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *claimsArray;
@property NSMutableArray *allOffersArray;
@end

@implementation NotificationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.claimsArray = [NSMutableArray new];
    self.allOffersArray = [NSMutableArray new];
    [self loadOffersFromFirebase];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.claimsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    QuikClaim *currentClaim = [self.claimsArray objectAtIndex:section];
    return currentClaim.damageDescription;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    QuikClaim *currentSection= [self.claimsArray objectAtIndex:section];
    return currentSection.offers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    QuikClaim *currentClaim = [self.claimsArray objectAtIndex:indexPath.section];
    QuikOffers *currentOffer = [currentClaim.offers objectAtIndex:indexPath.row];
    cell.textLabel.text = currentOffer.message;
    return cell; 
}

- (void) loadOffersFromFirebase{
    Firebase *claimRef = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/claims"];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
    
    [[[claimRef queryOrderedByChild:@"owner"] queryEqualToValue:uid] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        if(snapshot.exists){
            QuikClaim *currentClaim = [[QuikClaim alloc] initWithDictionary:snapshot.value];
            [self.claimsArray addObject:currentClaim];
            //            [self setupLocalNotifications];
        }
        [self.tableView reloadData];
        if ([self checkIfUserHasOffers:self.claimsArray] == false){
            NSLog(@"user has no offers");
        }else{
            NSLog(@"user has offers");
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UITableViewCell *cell = sender;
    QuikOfferDetailsVC *dest = segue.destinationViewController;
    QuikClaim *currentClaim = [self.claimsArray objectAtIndex:[self.tableView indexPathForCell:cell].section];
    dest.currentOffer = [currentClaim.offers objectAtIndex:[self.tableView indexPathForCell:cell].row];

}

- (BOOL) checkIfUserHasOffers: (NSMutableArray *) arrayOfClaims{
    NSLog(@"checkIfUserHasOffers gets called");
    for (QuikClaim *currentClaim in arrayOfClaims) {
        if (currentClaim.offers.count == 0) {
            return false;
        }
    }
    return true;
}
- (void) checkForNewOffers: (NSMutableArray *) arrayOfClaims{
    
    for (QuikClaim *currentClaim in arrayOfClaims) {
        if (currentClaim.offers.count == 0) {
        }
    }
}

//- (void)setupLocalNotifications {
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    NSDate *now = [NSDate date];
//    localNotification.fireDate = now;
//    localNotification.alertBody = @"From: ";
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    localNotification.applicationIconBadgeNumber = 1; // increment
//    
////    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
////    localNotification.userInfo = infoDict;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//}


@end
