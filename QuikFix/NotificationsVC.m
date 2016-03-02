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
#import "QuikNotificationCell.h"
#import <QuartzCore/QuartzCore.h>

@interface NotificationsVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *claimsArray;
@property NSMutableArray *allOffersArray;
@end

@implementation NotificationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Offers";
    self.claimsArray = [NSMutableArray new];
    self.allOffersArray = [NSMutableArray new];
    [self loadOffersFromFirebase];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UIColor *appYellow = [UIColor colorWithRed:247.0/255.0 green:219.0/255.0 blue:167.0/255.0 alpha:1];
    view.tintColor = appYellow;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    QuikClaim *claim = self.claimsArray[section];
    UIColor *appYellow = [UIColor colorWithRed:247.0/255.0 green:219.0/255.0 blue:167.0/255.0 alpha:1];
    UILabel *sectionTextLabel = [[UILabel alloc] init];
    [sectionTextLabel setFont:[UIFont systemFontOfSize:14]];
    sectionTextLabel.text = [NSString stringWithFormat: @"   %@ %@ - %@",claim.carDetail, claim.panel, claim.damageType];
    sectionTextLabel.textColor = [UIColor blackColor];
    sectionTextLabel.numberOfLines = 0;
    sectionTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    sectionTextLabel.backgroundColor = appYellow;

    return sectionTextLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.claimsArray.count;
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    view.tintColor = [UIColor clearColor];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    QuikClaim *currentClaim = [self.claimsArray objectAtIndex:section];
    NSString *sectionTitle = [NSString stringWithFormat:@"%@: %@-%@",currentClaim.carDetail, currentClaim.panel,currentClaim.damageType];
    return sectionTitle;
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
    
    cell.layer.cornerRadius = 3;
    cell.clipsToBounds = YES;
    [cell setFrame:cell.frame];
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
