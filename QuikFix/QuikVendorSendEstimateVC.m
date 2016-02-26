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
    self.title = self.currentClaim.username;
}

- (IBAction)onSendTapped:(UIButton *)sender {
    NSLog(@"self.currentClaims.claimID on estimate VC == %@",self.currentClaim.claimID);
    Firebase *notificationRef = [[[[[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com"] childByAppendingPath:@"claims" ] childByAppendingPath:self.currentClaim.claimID] childByAppendingPath:@"offers"] childByAutoId];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    
    NSDictionary *notification = @{@"vendor": uid,
                                   @"meesage": self.messageTextView.text,
                                   @"bid": self.priceEstimateTextField.text};
    [notificationRef setValue:notification];
    

    
}


@end



    

