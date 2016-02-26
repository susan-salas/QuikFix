//
//  QuikVendorSendEstimateVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendorSendEstimateVC.h"
#import "Firebase/Firebase.h"

@interface QuikVendorSendEstimateVC ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property (weak, nonatomic) IBOutlet UITextField *priceEstimateTextField;

@end

@implementation QuikVendorSendEstimateVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onSendTapped:(UIButton *)sender {
    if ([self.priceEstimateTextField.text isEqualToString:@""]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Please enter estimate" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
    Firebase *notificationRef = [[[[[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com"] childByAppendingPath:@"claims" ] childByAppendingPath:self.currentClaim.claimID] childByAppendingPath:@"offers"] childByAutoId];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    
    NSDictionary *notification = @{@"vendor": uid,
                                   @"meesage": self.messageTextView.text,
                                   @"bid": self.priceEstimateTextField.text};
    [notificationRef setValue:notification];
    }
}


@end



    

