//
//  QuikVendorSendEstimateVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendorSendEstimateVC.h"
#import "QuikClaim.h"
#import "QuikVendor.h"
#import "Firebase/Firebase.h"

@interface QuikVendorSendEstimateVC () <UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *priceEstimateTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property QuikVendor *vendor;
@property UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) NSDictionary *vendorDict;
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
    self.sendButton.enabled = NO;
    [self toDismissKeyboard];
    [self loadVendor];
}

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
    [self.messageTextView resignFirstResponder];
    [self.priceEstimateTextField resignFirstResponder];
}
//
//- (void)textViewDidBeginEditing:(UITextView *)textView{
//    [textView becomeFirstResponder];
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.textColor == [UIColor lightGrayColor]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.textColor == [UIColor lightGrayColor]) {
        textField.text = @"";
    }
    textField.textColor = [UIColor blackColor];
}

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    if ((textView.textColor = [UIColor lightGrayColor])) {
//        textView.text = @"";
//    }
//    textView.textColor = [UIColor blackColor];
//    return YES;
//}

-(BOOL)isClaimMessageReadyToPush{
    if ([self.messageTextView.text length] > 0 || self.messageTextView.text != nil || [self.messageTextView.text isEqual:@""] == FALSE || self.priceEstimateTextField.text) {
        return true;
    }else if ([self.messageTextView.text isEqualToString:@"Message required"]) {
        return false;
    }
    self.messageTextView.text = @"Message required";
    return false;
}

-(BOOL)isClaimPriceReadyToPush{
    if ([self.priceEstimateTextField.text length] > 0 || self.priceEstimateTextField.text != nil || [self.priceEstimateTextField.text isEqual:@""] == FALSE) {
        return true;
    }
    self.priceEstimateTextField.placeholder = @"$ required";
    return false;
}


- (IBAction)onSendTapped:(UIButton *)sender {

    if ([self isClaimMessageReadyToPush] && [self isClaimPriceReadyToPush]) {
                Firebase *notificationRef = [[[[[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com"] childByAppendingPath:@"claims" ] childByAppendingPath:self.currentClaim.claimID] childByAppendingPath:@"offers"] childByAutoId];
                NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
                NSDictionary *notification = @{@"vendor": uid,
                                               @"vendorDict":self.vendorDict,
                                               @"message": self.messageTextView.text,
                                               @"bid": self.priceEstimateTextField.text};
                [notificationRef setValue:notification];
    }
    //ui alert cannot leave textfields blank
    if ([self.priceEstimateTextField.text isEqualToString:@""]) {
        self.priceEstimateTextField.placeholder = @"$ required";
    }
    if ([self.messageTextView.text isEqualToString:@"Please write your message here..."] || [self.messageTextView.text isEqualToString:@""]) {
    self.messageTextView.textColor = [UIColor lightGrayColor];
    self.messageTextView.text = @"Message required";
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"unwindToTable"]) {
        if ([self.priceEstimateTextField.text isEqualToString:@""] || [self.messageTextView.text isEqualToString:@""] || [self.messageTextView.text isEqualToString:@"Please write your message here..."] || [self.messageTextView.text isEqualToString:@"Message required"]) {
            return false;
        }
    }
    return true;
}

-(void)loadVendor{
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    Firebase* ref = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/vendors"] childByAppendingPath:uid];
    [ref observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if(snapshot.exists){
            self.vendorDict = snapshot.value;
            self.vendor = [[QuikVendor alloc] initWithDictionary:self.vendorDict];
            self.sendButton.enabled = YES;
        }
    }];
}

@end