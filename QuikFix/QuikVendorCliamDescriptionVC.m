//
//  QuikVendorCliamDescriptionVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendorCliamDescriptionVC.h"
#import "QuikVendorSendEstimateVC.h"

@interface QuikVendorCliamDescriptionVC ()
@property (weak, nonatomic) IBOutlet UITextView *claimDescriptionTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *imageButtons;

@end

@implementation QuikVendorCliamDescriptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.claimDescriptionTextView.text = self.currentClaim.damageDescription;
}

- (IBAction)onSendEstimateTapped:(UIButton *)sender {
}
- (IBAction)onImageButtonsTapped:(UIButton *)sender {
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier  isEqual: @"estimateSegue"]){
        QuikVendorSendEstimateVC *estimateVC = segue.destinationViewController;
        estimateVC.currentClaim = self.currentClaim;
    }
    
}

@end
