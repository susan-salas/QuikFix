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

@interface QuikDamageListVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *carDetailLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *damageListForCar;
@end

@implementation QuikDamageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.carDetailLabel.text = self.textFromCell;
    self.damageListForCar = [NSMutableArray new];
    [self loadMyDamage];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.damageListForCar.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = @"Got my claims";
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UIBarButtonItem class]]){
        AddDamageVC *dest = segue.destinationViewController;
        dest.carDetailText = self.carDetailLabel.text;
        dest.carDictionary = self.carDictionary;
    }
}

-(void)loadMyDamage{
    Firebase *damageRef = [[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/claims"];
    [damageRef  observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray *damageFromFirebase = [NSMutableArray new];
        for (NSString* claimID in snapshot.value) {
            NSDictionary *claimDict = [snapshot.value objectForKey:claimID];
            NSString *ownerID = [claimDict objectForKey:@"owner"];
            if([ownerID isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"uid"]])
            {
                [damageFromFirebase addObject:claimDict];
            }
        }
        self.damageListForCar = damageFromFirebase;
       [self.tableView reloadData];
    }];
}

@end
