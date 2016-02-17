//
//  QuikVendorHomepageVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendorHomepageVC.h"
#import "MapKit/MapKit.h"


@interface QuikVendorHomepageVC () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation QuikVendorHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.hidden = YES;
    // Do any additional setup after loading the view.
}
- (IBAction)logoutButtonPressed:(UIBarButtonItem *)sender {
}
- (IBAction)switchButtonMoved:(UISwitch *)sender {
}
- (IBAction)historyButtonPressed:(UIBarButtonItem *)sender {
}
- (IBAction)sortButtonPressed:(UIBarButtonItem *)sender {
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
