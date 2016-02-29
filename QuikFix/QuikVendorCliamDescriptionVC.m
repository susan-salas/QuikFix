//
//  QuikVendorCliamDescriptionVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendorCliamDescriptionVC.h"
#import "QuikVendorSendEstimateVC.h"
#import "QuikClaimDescriptionBigPicVC.h"

@interface QuikVendorCliamDescriptionVC ()
@property (weak, nonatomic) IBOutlet UIButton *image1;
@property (weak, nonatomic) IBOutlet UITextView *claimDescriptionTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *imageButtons;

@end

@implementation QuikVendorCliamDescriptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.currentClaim.carDetail;
    self.claimDescriptionTextView.text = self.currentClaim.damageDescription;
    self.claimDescriptionTextView.editable = NO;
    int count = 0;
    
    for (UIButton *button in self.imageButtons) {
        UIImage *image = self.currentClaim.images[count];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        count ++;
    }
}


- (IBAction)onSendEstimateTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"SendEstimateSegue" sender:nil];
}


- (IBAction)onImageButtonsTapped:(UIButton *)sender {
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier  isEqual: @"SendEstimateSegue"]){
        QuikVendorSendEstimateVC *estimateVC = segue.destinationViewController;
        estimateVC.currentClaim = self.currentClaim;
    } else {
        QuikClaimDescriptionBigPicVC *image = segue.destinationViewController;
        image.currentImage = [(UIButton *)sender backgroundImageForState:UIControlStateNormal];
    }
}

@end
