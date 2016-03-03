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
@property (weak, nonatomic) IBOutlet UILabel *vendorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingsLabel;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property QuikVendor *currentVendor;

@end

@implementation QuikOfferDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.currentOffer.vendor.locationLatitude doubleValue], [self.currentOffer.vendor.locationLongitude doubleValue]);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.009, 0.009);
    MKCoordinateRegion region = {coord, span};
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coord];
    
    [self.mapView setRegion:region];
    [self.mapView addAnnotation:annotation];
    self.currentVendor = self.currentOffer.vendor;
    self.messageTextView.text = self.currentOffer.message;
    self.estimateLabel.text = [NSString stringWithFormat:@"$%@", self.currentOffer.bid];
    self.vendorImageView.image = self.currentVendor.image;
    self.vendorNameLabel.text = self.currentVendor.vendorName;
    self.ratingsLabel.text = [NSString stringWithFormat:@"Rating: %@", self.currentVendor.vendorRating];
    self.addressTextView.text = self.currentVendor.address;
    
}

- (IBAction)onCallTapped:(UIButton *)sender {
    NSURL *phoneNumber = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"tel:%@", self.currentOffer.vendor.vendorPhoneNumber]];
    [[UIApplication sharedApplication] openURL: phoneNumber];
}
- (IBAction)onEmailTapped:(UIButton *)sender {
    NSString *mailString = [NSString stringWithFormat:@"mailto://%@", self.currentOffer.vendor.vendorEmail];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}
- (IBAction)onWebTapped:(UIButton *)sender {
    NSURL *vendorURL = [[NSURL alloc] initWithString:self.currentVendor.vendorWebsite];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:vendorURL];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
}

@end
