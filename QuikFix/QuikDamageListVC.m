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

@interface QuikDamageListVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *carDetailLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *damageListForCar;
@end

@implementation QuikDamageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.carDetailLabel.text = self.car.detail;
    self.damageListForCar = [NSMutableArray new];
    [self loadMyDamage];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.damageListForCar.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    QuikClaim *claim = self.damageListForCar[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Description: %@",claim.damageDescription];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Claim ID: %@",claim.claimID];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *removeFromArray = [[NSMutableArray alloc] initWithArray:self.damageListForCar];
        QuikClaim *removeClaim = self.damageListForCar[indexPath.row];
        [removeFromArray removeObjectAtIndex:indexPath.row];
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
        dest.carDetailText = self.carDetailLabel.text;
        dest.car = self.car;
    }
    else if([sender isKindOfClass:[UITableViewCell class]]) {
        AddDamageVC *dest = segue.destinationViewController;
        NSIndexPath *path =  [self.tableView indexPathForCell:(UITableViewCell *)sender];
        QuikClaim *claim = self.damageListForCar[path.row];
        dest.title = @"Edit Damage";
        dest.carDetailText = self.carDetailLabel.text;
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
            self.damageListForCar = damageFromFirebase;
            [self.tableView reloadData];
        }
    }];
}

@end
