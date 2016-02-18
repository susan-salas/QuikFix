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

@interface QuikUserHomepageVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *myCars;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property Firebase *ref;
@property QuikUser *currentUser;

@end

@implementation QuikUserHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = [QuikUser new];
    self.myCars = [NSMutableArray new];
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    self.ref = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/users"] childByAppendingPath:uid];
    [self populateUser];
    [self loadMyCars];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = @"COOL CARS";
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

-(void) loadMyCars {
    self.ref = [[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/cars"];
    [self.ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        for (NSString* key in snapshot.value) {
            NSDictionary *carDict = [snapshot.value objectForKey:key];
            NSString *owner = [carDict objectForKey:@"owner"];
            if([owner isEqualToString:self.currentUser.idNumber]){
                NSLog(@"hello");
                [self.myCars addObject:carDict];
            }
        }

        [self.tableView reloadData];
    }];
}

@end
