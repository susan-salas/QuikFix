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

@interface NotificationsVC () <UITableViewDataSource, UITableViewDelegate>
@property NSMutableArray *offersArray;
@end

@implementation NotificationsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"HELLO!");
    self.offersArray = [NSMutableArray new];
    NSLog(@"self.currentClaim.offers == %@", self.currentClaim.offers);
    
    for (NSDictionary *offerDictionary in self.currentClaim.offers) {
        NSLog(@"offerDictionary == %@", offerDictionary);
        QuikOffers *currentOffer = [[QuikOffers alloc]initWithDictionary:offerDictionary];
        NSLog(@" currentOffer.message == %@", currentOffer.message);
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

@end
