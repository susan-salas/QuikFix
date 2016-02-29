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
@end

@implementation NotificationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"HELLO");
    self.offersArray = [NSMutableArray new];
    
    for (NSDictionary *offerDictionary in self.currentClaim.offers) {
        QuikOffers *currentOffer = [[QuikOffers alloc]initWithDictionary:offerDictionary];
        [self.offersArray addObject:currentOffer];       
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.offersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    QuikOffers *currentOffer = self.offersArray[indexPath.row];
    cell.textLabel.text = currentOffer.message;
    return cell; 
}

//- (void) loadOffersFromFirebase{
//    Firebase *claimRef = [[[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/claims"] childByAppendingPath:self.currentClaim.claimID] childByAppendingPath:@"offers"];
//    [claimRef ];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UITableViewCell *cell = sender;
    QuikOfferDetailsVC *dest = segue.destinationViewController;
    dest.currentOffer = [self.offersArray objectAtIndex:[self.tableView indexPathForCell:cell].row];
}

@end
