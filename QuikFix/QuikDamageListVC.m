//
//  QuikDamageListVC.m
//  QuikFix
//
//  Created by Sean Barry on 2/18/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikDamageListVC.h"
#import "AddDamageVC.h"

@interface QuikDamageListVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *carDetailLabel;
@property NSArray *damageListForCar;
@end

@implementation QuikDamageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.carDetailLabel.text = self.textFromCell;
    NSLog(@"Car dictionary: %@", self.carDictionary);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [UITableViewCell new];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[UIBarButtonItem class]]){
        AddDamageVC *dest = segue.destinationViewController;
        dest.carDetailText = self.carDetailLabel.text;
        dest.carDictionary = self.carDictionary;
    }
}

@end
