//
//  QuikVendorSendEstimateVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendorSendEstimateVC.h"
#import "Firebase/Firebase.h"

@interface QuikVendorSendEstimateVC () <UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *priceEstimateTextField;

@end

@implementation QuikVendorSendEstimateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * name = self.currentClaim.username;
    self.title = name;
    self.messageTextView.text = @"Please write your message here...";
    self.messageTextView.textColor = [UIColor lightGrayColor];
    self.messageTextView.delegate = self;
    self.priceEstimateTextField.delegate = self;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.messageTextView.text = @"";
    self.messageTextView.textColor = [UIColor blackColor];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(self.messageTextView.text.length == 0){
        self.messageTextView.textColor = [UIColor lightGrayColor];
        self.messageTextView.text = @"Please write your message here...";
        [self.messageTextView resignFirstResponder];
    }
}

- (IBAction)onSendTapped:(UIButton *)sender {
    if ([self.messageTextView.text  isEqualToString:@""] || [self.priceEstimateTextField.text  isEqualToString:@""] || [self.messageTextView.text isEqualToString:@"Please write your message here..."] || [self.messageTextView.text  isEqualToString:@" "]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!" message:@"Please write a message and set the price..." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        NSLog(@"self.currentClaims.claimID on estimate VC == %@",self.currentClaim.claimID);
        Firebase *notificationRef = [[[[[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com"] childByAppendingPath:@"claims" ] childByAppendingPath:self.currentClaim.claimID] childByAppendingPath:@"offers"] childByAutoId];
        NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        NSDictionary *notification = @{@"vendor": uid,
                                       @"message": self.messageTextView.text,
                                       @"bid": self.priceEstimateTextField.text};
        [notificationRef setValue:notification];
    }
}


@end





