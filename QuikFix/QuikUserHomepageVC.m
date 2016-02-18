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
@property Firebase *ref;
@property QuikUser *currentUser;

@end

@implementation QuikUserHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateCarsArray];
    
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
        
    }];
}

-(void) populateCarsArray {
    
}

@end
