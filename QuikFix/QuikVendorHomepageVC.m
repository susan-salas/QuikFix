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
#import "QuikCar.h"
#import "QuikVendorCliamDescriptionVC.h"
#import "AFTableViewCell.h"
#import <QuartzCore/QuartzCore.h>


@interface QuikVendorHomepageVC () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property QuikClaim *selectedClaim;
@property NSMutableArray *claims;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property BOOL isFiltered;
@property NSMutableArray *filteredClaims;
@property NSInteger timesUpdated;
@property UITapGestureRecognizer *tapRecognizer;

@end

@implementation QuikVendorHomepageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self toDismissKeyboard];
    [self populateClaimsArray];
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
    self.mapView.hidden = YES;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self updateUserCurrentLocation];
    self.isFiltered = NO;
    self.searchBar.delegate = self;
    self.timesUpdated = 0;

    [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];
}

-(void)addAnnotations {
    if (self.isFiltered == YES) {
        for (QuikClaim *claim in self.filteredClaims)
        {
            CLLocationDirection latitude = [[claim.claimLocation objectForKey:@"latitude"] doubleValue];
            CLLocationDirection longitude = [[claim.claimLocation objectForKey:@"longitude"] doubleValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = coordinate;
            point.accessibilityHint = [NSString stringWithFormat:@"%lu",(unsigned long)[self.filteredClaims indexOfObject:claim]];
            NSString *subtitle = [NSString stringWithFormat:@"%@ - %@", claim.panel, claim.damageType];
            point.title = claim.username;
            point.subtitle = subtitle;
            [self.mapView addAnnotation:point];
        }
    }else {
        for (QuikClaim *claim in self.claims)
        {
            CLLocationDirection latitude = [[claim.claimLocation objectForKey:@"latitude"] doubleValue];
            CLLocationDirection longitude = [[claim.claimLocation objectForKey:@"longitude"] doubleValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = coordinate;
            point.accessibilityHint = [NSString stringWithFormat:@"%lu",(unsigned long)[self.claims indexOfObject:claim]];
            NSString *subtitle = [NSString stringWithFormat:@"%@ - %@", claim.panel, claim.damageType];
            point.title = claim.username;
            point.subtitle = subtitle;
            [self.mapView addAnnotation:point];
        }
    }
}

-(void)hideKeyBoard {
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.isFiltered = NO;
    } else {
        
        self.isFiltered = YES;
        self.filteredClaims = [NSMutableArray new];
        for (QuikClaim *claim in self.claims) {
            NSRange claimUsernameRange = [claim.username rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange claimDamageTypeRange = [claim.damageType rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange claimPanelRange = [claim.panel rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (claimUsernameRange.location != NSNotFound || claimDamageTypeRange.location != NSNotFound || claimPanelRange.location != NSNotFound) {
                [self.filteredClaims addObject:claim];
            }
        }
    }
    [self.tableView reloadData];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self addAnnotations];
}

-(void)updateUserCurrentLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.timesUpdated<1) {
        MKCoordinateRegion mapregion;
        mapregion.center.latitude = self.mapView.userLocation.coordinate.latitude;
        mapregion.center.longitude = self.mapView.userLocation.coordinate.longitude;
        mapregion.span = MKCoordinateSpanMake(0.005,0.005);
        [self.mapView setRegion:mapregion animated:YES];
        self.mapView.userLocation.title = @"You're here";
        self.timesUpdated++;
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
    MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    pin.canShowCallout = YES;
    pin.image = [UIImage imageNamed:@"car"];
    //pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    // Add a detail disclosure button to the callout.
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.rightCalloutAccessoryView = rightButton;
    
    // Add an image to the left callout.
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car"]];
    pin.leftCalloutAccessoryView = iconView;
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (self.isFiltered == YES) {
        MKPointAnnotation *point = view.annotation;
        int index = (int)[point.accessibilityHint integerValue];
        self.selectedClaim = self.filteredClaims[index];
        [self performSegueWithIdentifier:@"FromCellSegue" sender:view];
    } else {
        MKPointAnnotation *point = view.annotation;
        int index = (int)[point.accessibilityHint integerValue];
        self.selectedClaim = self.claims[index];
        [self performSegueWithIdentifier:@"FromCellSegue" sender:view];
    }
}

#pragma mark Zoom

- (IBAction)zoomToCurrentLocation:(UIBarButtonItem *)sender {
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
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

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isFiltered == YES) {
       self.selectedClaim = self.filteredClaims[[(AFIndexedCollectionView *)collectionView indexPath].section];
    } else {
    self.selectedClaim = self.claims[[(AFIndexedCollectionView *)collectionView indexPath].section];
    }
    [self performSegueWithIdentifier:@"FromCellSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    QuikVendorCliamDescriptionVC *claimDescription = segue.destinationViewController;
    claimDescription.currentClaim = self.selectedClaim;
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


- (void) populateClaimsArray{
    Firebase *claimsRef = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com"]childByAppendingPath:@"claims"];
    [claimsRef  observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if(snapshot.exists){
            NSMutableArray *claimsFromFirebase = [NSMutableArray new];
            for (NSDictionary* claim in snapshot.value) {
                NSDictionary *currentClaimDict = snapshot.value[claim];
                QuikClaim *currentClaim = [[QuikClaim alloc] initWithDictionary:currentClaimDict];
                [claimsFromFirebase addObject:currentClaim];
            }
            self.claims = claimsFromFirebase;
            [self.tableView reloadData];
            [self addAnnotations];
        }
    }];
}


#pragma mark - UITableViewDataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isFiltered == YES) {
        QuikClaim *claim = self.filteredClaims[section];
        NSString *sectionTitle = [NSString stringWithFormat:@"%@: %@ - %@",
                                  claim.username,
                                  claim.panel,
                                  claim.damageType];
        return sectionTitle;
    }else {
        QuikClaim *claim = self.claims[section];
        NSString *sectionTitle = [NSString stringWithFormat:@"%@: %@ - %@",
                                  claim.username,
                                  claim.panel,
                                  claim.damageType];
        return sectionTitle;
    }
}
        
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isFiltered == YES) {
        return self.filteredClaims.count;
    }else {
        return self.claims.count;
    }
}

#pragma mark - UICollectionViewDataSource Methods


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isFiltered == YES) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        QuikClaim *claim = self.filteredClaims[[(AFIndexedCollectionView *)collectionView indexPath].section];
        imageView.image = claim.images[indexPath.item];
        [cell addSubview:imageView];
        cell.layer.cornerRadius = 3;
        cell.clipsToBounds = YES;
        return cell;
    }else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        QuikClaim *claim = self.claims[[(AFIndexedCollectionView *)collectionView indexPath].section];
        imageView.image = claim.images[indexPath.item];
        [cell addSubview:imageView];
        cell.layer.cornerRadius = 3;
        cell.clipsToBounds = YES;
        return cell;
    }
}

#pragma mark - UIScrollViewDelegate Methods

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UIColor *appYellow = [UIColor colorWithRed:247.0/255.0 green:219.0/255.0 blue:167.0/255.0 alpha:1];
    view.tintColor = appYellow;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;

    CGFloat horizontalOffset = scrollView.contentOffset.x;
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

#pragma mark - Dismiss Keyboard Methods

-(void)toDismissKeyboard {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
     UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
     UIKeyboardWillHideNotification object:nil];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(didTapAnywhere:)];
}

-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:self.tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:self.tapRecognizer];
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.searchBar resignFirstResponder];
}

@end
