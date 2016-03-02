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
@property NSMutableArray *offersArray;
@property NSMutableArray *allOffersArray;
@end

@implementation NotificationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.offersArray = [NSMutableArray new];
    self.allOffersArray = [NSMutableArray new];
    [self loadOffersFromFirebase];
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allOffersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    QuikOffers *currentOffer = self.allOffersArray[indexPath.row];
    cell.textLabel.text = currentOffer.message;
    return cell; 
}

- (void) loadOffersFromFirebase{
    Firebase *claimRef = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/claims"];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
    
    [[[claimRef queryOrderedByChild:@"owner"] queryEqualToValue:uid] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"loadOffersFromFirebase");
        if(snapshot.exists){
            NSDictionary *offersDictionary = snapshot.value[@"offers"];
            for (NSString *key in offersDictionary) {
                QuikOffers *currentOffer = [[QuikOffers alloc]initWithDictionary:[offersDictionary objectForKey:key]];
                [self.allOffersArray addObject:currentOffer];
              
            }
            [self setupLocalNotifications];
        }
        [self.tableView reloadData];

        }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UITableViewCell *cell = sender;
    QuikOfferDetailsVC *dest = segue.destinationViewController;
    dest.currentOffer = [self.allOffersArray objectAtIndex:[self.tableView indexPathForCell:cell].row];
}

- (void)setupLocalNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    localNotification.fireDate = now;
    localNotification.alertBody = @"From: ";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1; // increment
    
//    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
//    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
