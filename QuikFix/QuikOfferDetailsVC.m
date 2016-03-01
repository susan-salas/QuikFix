//
//  QuikOfferDetailsVC.m
//  QuikFix
//
//  Created by Susan Salas on 2/28/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikOfferDetailsVC.h"
#import "Mapkit/Mapkit.h"
#import "Firebase/Firebase.h"
#import "QuikVendor.h"
#import <SafariServices/SafariServices.h>

@interface QuikOfferDetailsVC () <MKMapViewDelegate, CLLocationManagerDelegate, SFSafariViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *vendorImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *estimateLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property QuikVendor *currentVendor;
@property (weak, nonatomic) IBOutlet UILabel *vendorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingsLabel;

@end

@implementation QuikOfferDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadVendor];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(12.0433, 77.0283);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = {coord, span};
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coord];
    
    [self.mapView setRegion:region];
    [self.mapView addAnnotation:annotation];
}

-(void) loadVendor{
    //
    Firebase *vendorRef = [[[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"] childByAppendingPath:@"vendors"] childByAppendingPath: self.currentOffer.vendor];
    [vendorRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.exists) {
            NSLog(@"snapshot == %@", snapshot);
            self.currentVendor = [[QuikVendor alloc]initWithDictionary:snapshot.value];
            [self loadMyViews];
        }
    }];
}

- (void) loadMyViews{
    self.messageTextView.text = self.currentOffer.message;
    self.estimateLabel.text = [NSString stringWithFormat:@"$%@", self.currentOffer.bid];
    self.vendorImageView.image = self.currentVendor.image;
    self.vendorNameLabel.text = self.currentVendor.vendorName;
    self.ratingsLabel.text = [NSString stringWithFormat:@"Rating: %@", self.currentVendor.vendorRating];
    
}

- (IBAction)onCallTapped:(UIButton *)sender {
    NSURL *phoneNumber = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"tel:%@", self.currentVendor.vendorPhoneNumber]];
    [[UIApplication sharedApplication] openURL: phoneNumber];
}
- (IBAction)onEmailTapped:(UIButton *)sender {
}
- (IBAction)onWebTapped:(UIButton *)sender {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:self.currentVendor.vendorWebsite];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
}

@end
