//
//  QuikVendorHomepageVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendorHomepageVC.h"
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"
#import "LoginViewController.h"


@interface QuikVendorHomepageVC () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *claims;

@end

@implementation QuikVendorHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.hidden = YES;
    self.mapView.delegate = self;
    
}
- (IBAction)logoutButtonPressed:(UIBarButtonItem *)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
    
    if (![[self presentingViewController] presentingViewController]) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)switchButtonMoved:(UISwitch *)sender {
    if([sender isOn] == NO){
        self.mapView.hidden = NO;
        self.tableView.hidden = YES;
            }
    else{
        self.mapView.hidden = YES;
        self.tableView.hidden = NO;
    }
}

- (IBAction)historyButtonPressed:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hello!" message:@"This feature is going to be here very soon!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)sortButtonPressed:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hello!" message:@"This feature is going to be here very soon!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.claims.count;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
