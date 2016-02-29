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

@interface QuikOfferDetailsVC () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *vendorImageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *estimateLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property QuikVendor *currentVendor;

@end

@implementation QuikOfferDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadVendor];
    
}

-(void) loadVendor{
    Firebase *vendorRef = [[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/vendors"] childByAppendingPath:self.currentOffer.vendor];
    [vendorRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (snapshot.exists) {
            NSLog(@"snapshot == %@", snapshot);
            self.currentVendor = [[QuikVendor alloc]initWithDictionary:snapshot.value];
            [self loadMyViews];
        }
    
    }];
}

- (void) loadMyViews{
    [super loadView];
    self.messageTextView.text = self.currentOffer.message;
    NSLog(@"currentOffer.description == %@", self.currentOffer.message);
    self.estimateLabel.text = [NSString stringWithFormat:@"$%@", self.currentOffer.bid];
}

- (IBAction)onCallTapped:(UIButton *)sender {
}
- (IBAction)onEmailTapped:(UIButton *)sender {
}
- (IBAction)onWebTapped:(UIButton *)sender {
}

@end
