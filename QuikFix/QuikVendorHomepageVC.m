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
#import "InitialViewController.h"
#import "Firebase/Firebase.h"
#import "QuikClaim.h"
#import "QuikVendorCliamDescriptionVC.h"
#import "AFTableViewCell.h"


@interface QuikVendorHomepageVC () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property NSMutableArray *claims;

@end

@implementation QuikVendorHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.hidden = YES;
    self.mapView.delegate = self;
    [self populateClaimsArray];

    const NSInteger numberOfTableViewRows = 5;
    const NSInteger numberOfCollectionViewCells = 4;

    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];

    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];

        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {

            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];

            [colorArray addObject:color];
        }

        [mutableArray addObject:colorArray];
    }

    self.colorArray = [NSArray arrayWithArray:mutableArray];

    self.contentOffsetDictionary = [NSMutableDictionary dictionary];    
}

- (IBAction)logoutButtonPressed:(UIBarButtonItem *)sender {
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
    [ref unauth];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    UINavigationController *navVC = [self presentingViewController];
//    NSArray *vcArray = navVC.viewControllers;
//    if([vcArray[vcArray.count - 1] isKindOfClass: [InitialViewController class]]){
//        LoginViewController *controller = [LoginViewController new];
//        UIStoryboard *board = [UIStoryboard storyboardWithName:@"LoginViewController" bundle:[NSBundle mainBundle]];
//        controller = [board instantiateInitialViewController];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
//        [[self presentingViewController] presentViewController:nav animated:YES completion:nil];
//    }
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

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    AFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    QuikClaim *currentClaim = self.claims[indexPath.row];
//    //cell.textLabel.text = currentClaim.damageDescription;
//    return cell;
//}

//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.claims.count;
//}


- (void) populateClaimsArray{
    Firebase *claimsRef = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com"]childByAppendingPath:@"claims"];
    [claimsRef  observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray *claimsFromFirebase = [NSMutableArray new];
        for (NSDictionary* claim in snapshot.value) {
           
            NSDictionary *currentClaimDict = snapshot.value [claim];
            QuikClaim *currentClaim = [[QuikClaim alloc] initWithDictionary:currentClaimDict];
            [claimsFromFirebase addObject:currentClaim];
        }
        self.claims = claimsFromFirebase;
        [self.tableView reloadData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    QuikVendorCliamDescriptionVC *claimDescription = segue.destinationViewController;
    NSLog(@"indexPath.row == %lu", (long)indexPath.row);
    claimDescription.currentClaim = self.claims[indexPath.row];
    
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section #%ld", section+1];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.colorArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";

    AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell)
    {
        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.collectionView.tag;

    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 340;
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionViewArray = self.colorArray[[(AFIndexedCollectionView *)collectionView indexPath].row];
    return collectionViewArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];

    NSArray *collectionViewArray = self.colorArray[[(AFIndexedCollectionView *)collectionView indexPath].row];
    cell.backgroundColor = collectionViewArray[indexPath.item];

    return cell;
}

#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;

    CGFloat horizontalOffset = scrollView.contentOffset.x;

    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

@end
