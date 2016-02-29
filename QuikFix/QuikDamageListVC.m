//
//  QuikDamageListVC.m
//  QuikFix
//
//  Created by Sean Barry on 2/18/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikDamageListVC.h"
#import "AddDamageVC.h"
#import "Firebase/Firebase.h"
#import "QuikCar.h"
#import "QuikClaim.h"
#import "NotificationsVC.h"

@interface QuikDamageListVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *damageListForCar;
@end

@implementation QuikDamageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.car.detail;
    self.damageListForCar = [NSMutableArray new];
    [self loadMyDamage];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];

    [self.navigationItem setBackBarButtonItem:backItem];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.damageListForCar.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    QuikClaim *claim = self.damageListForCar[indexPath.section];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", claim.panel, claim.damageType];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",claim.damageDescription];

    cell.layer.cornerRadius = 3;
    cell.clipsToBounds = YES;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *removeFromArray = [[NSMutableArray alloc] initWithArray:self.damageListForCar];
        QuikClaim *removeClaim = self.damageListForCar[indexPath.section];
        [removeFromArray removeObjectAtIndex:indexPath.section];
        NSString *removeURL = [NSString stringWithFormat:@"https://beefstagram.firebaseio.com/claims/%@", removeClaim.claimID];
        Firebase *removeRef = [[Firebase alloc] initWithUrl: removeURL];
        [removeRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
            self.damageListForCar = removeFromArray;
            [self.tableView reloadData];
        }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UIBarButtonItem class]]){
        AddDamageVC *dest = segue.destinationViewController;
        dest.carDetailText = self.car.detail;
        dest.car = self.car;
    }
    else if([sender isKindOfClass:[UITableViewCell class]]) {
        AddDamageVC *dest = segue.destinationViewController;
        NSIndexPath *path =  [self.tableView indexPathForCell:(UITableViewCell *)sender];
        QuikClaim *claim = self.damageListForCar[path.section];
        dest.title = @"Edit Damage";
        dest.carDetailText = self.car.detail;
        dest.car = self.car;
        dest.claim = claim;
    }
}

-(void)loadMyDamage{
    Firebase *damageRef = [[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/claims"];
    [[[damageRef queryOrderedByChild:@"carWithDamage"] queryEqualToValue:self.car.vin] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if ([snapshot exists]) {
            NSMutableArray *damageFromFirebase = [NSMutableArray new];
            for (NSString* claimID in snapshot.value) {
                NSDictionary *claimDict = [snapshot.value objectForKey:claimID];
                QuikClaim *claim = [[QuikClaim alloc] initWithDictionary:claimDict];
                [damageFromFirebase addObject:claim];
            }
            [self sendClaimToNotificationVC:damageFromFirebase[0]];
            self.damageListForCar = damageFromFirebase;
            [self.tableView reloadData];
        }
    }];
}

-(void)sendClaimToNotificationVC:(QuikClaim *) claim{
    
    NotificationsVC *notificationsVC = [NotificationsVC new];
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Notifications" bundle:[NSBundle mainBundle]];
    notificationsVC = [board instantiateInitialViewController];
    notificationsVC.currentClaim = claim;
    
    [self presentViewController:notificationsVC animated:YES completion:nil];
}



@end
