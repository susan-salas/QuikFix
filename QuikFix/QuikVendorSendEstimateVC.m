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
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

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
    self.messageTextView.layer.cornerRadius = 3;
    self.messageTextView.clipsToBounds = YES;
    self.sendButton.layer.cornerRadius = 3;
    self.sendButton.clipsToBounds = YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Please write your message here..."] || [self.messageTextView.text isEqualToString:@""]) {
        textView.text = @"";
        self.messageTextView.textColor = [UIColor blackColor];
    }else if ([self.priceEstimateTextField.text isEqualToString:@"Required"]) {
        self.priceEstimateTextField.text = @"";
        self.priceEstimateTextField.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}
-(BOOL)isClaimMessageReadyToPush{
    if (self.messageTextView.text.length == 0 || [self.messageTextView.text isEqualToString:@"Please write your message here..."] || [self.messageTextView.text isEqualToString:@"Cannot be empty"]) {
        self.messageTextView.textColor = [UIColor redColor];
        self.messageTextView.text = @"Cannot be empty";
        return false;
    }
    else if ([self.messageTextView.text isEqualToString:@"Cannot be empty"]) {
        return false;
    }
    return true;
}
-(BOOL)isClaimPriceReadyToPush{
    if (self.priceEstimateTextField.text.length == 0 || [self.priceEstimateTextField.text isEqualToString:@"Required"]) {
        self.priceEstimateTextField.textColor = [UIColor redColor];
        self.priceEstimateTextField.text = @"Required";
        return false;
    }
    else if ([self.priceEstimateTextField.text isEqualToString:@"Required"]) {
        return false;
    }
    return true;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.messageTextView.text isEqualToString:@"Please write your message here..."] || [self.messageTextView.text isEqualToString:@"Cannot be empty"]) {
        self.messageTextView.text = @"";
    }else if ([self.priceEstimateTextField.text isEqualToString:@"Required"]) {
        self.priceEstimateTextField.text = @"";
    }
    self.messageTextView.textColor = [UIColor blackColor];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(self.messageTextView.text.length == 0 || [self.messageTextView.text isEqualToString:@""]){
        self.messageTextView.textColor = [UIColor lightGrayColor];
        self.messageTextView.text = @"Please write your message here...";
        [self.messageTextView resignFirstResponder];
    }
}

- (IBAction)onSendTapped:(UIButton *)sender {
    if ([self isClaimMessageReadyToPush] && [self isClaimPriceReadyToPush]) {
                Firebase *notificationRef = [[[[[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com"] childByAppendingPath:@"claims" ] childByAppendingPath:self.currentClaim.claimID] childByAppendingPath:@"offers"] childByAutoId];
                NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
                NSDictionary *notification = @{@"vendor": uid,
                                               @"meesage": self.messageTextView.text,
                                               @"bid": self.priceEstimateTextField.text};
                [notificationRef setValue:notification];

    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"unwindToTable"]) {
        if ([self isClaimMessageReadyToPush]) {
            return true;
        }
    }
    return false;
}

@end