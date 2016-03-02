//
//  CreateAccountViewController.m
//  QuikFix
//
//  Created by Susan Salas on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "Firebase/Firebase.h"
#import "QuikUserHomepageVC.h"
#import "Batch/Batch.h"

@interface CreateAccountViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *createLabelView;
@property UITapGestureRecognizer *tapRecognizer;

@end

@implementation CreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self toDismissKeyboard];
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.usernameLabel.delegate = self;
    
    self.passwordTextField.layer.cornerRadius = 3;
    self.passwordTextField.clipsToBounds = YES;
    
    self.emailTextField.layer.cornerRadius = 3;
    self.emailTextField.clipsToBounds = YES;
    
    self.usernameLabel.layer.cornerRadius = 3;
    self.usernameLabel.clipsToBounds = YES;
    
    self.createLabelView.layer.cornerRadius = 3;
    self.createLabelView.clipsToBounds = YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)onCreateAccountTapped:(UIButton *)sender {
    if(self.usernameLabel.text.length > 0){
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
        
        NSString *email = self.emailTextField.text;
        NSString *password = self.passwordTextField.text;
        
        //   create user
        if (!([self checkIfFormsAreEmtpy])){
            [ref createUser:email password:password withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
                if (error) {
                    NSLog(@"Error %@", error.description);
                } else {
                    [ref authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
                        if (error) {
                            NSLog(@"Error %@", error.description);
                        } else {
                            [[NSUserDefaults standardUserDefaults] setValue: authData.uid forKey:@"uid"];
                            
                            //set idetifier for Batch
                            BatchUserDataEditor *editor = [BatchUser editor];
                            [editor setIdentifier: authData.uid];
                            [editor save];
                            
                            [[NSUserDefaults standardUserDefaults] setValue: self.usernameLabel.text forKey:@"username"];
                            NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
                            NSDictionary *newUser = @{
                                                      @"email": self.emailTextField.text,
                                                      @"uid": authData.uid,
                                                      @"username": self.usernameLabel.text
                                                      };
                            [[[ref childByAppendingPath:@"users"] childByAppendingPath:authData.uid] setValue:newUser];
                            [self callPresentVC];
                        }
                    }];
                }
            }];
        }
    }
    else{
        self.usernameLabel.placeholder = @"Username required";
        self.emailTextField.placeholder = @"Email required";
        self.passwordTextField.placeholder = @"Password required";
    }
}

- (void) callPresentVC {
    
    QuikUserHomepageVC *quickUserVC = [QuikUserHomepageVC new];
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"QuikUserHomepage" bundle:[NSBundle mainBundle]];
    
    quickUserVC = [board instantiateInitialViewController];
    [self presentViewController:quickUserVC animated:YES completion:nil];
    
}

- (BOOL) checkIfFormsAreEmtpy{
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""] || [self.usernameLabel.text isEqualToString:@""]) {
        return YES;
    }
    return NO;
}
#pragma mark - Dismiss Keyboard Methods

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
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.usernameLabel resignFirstResponder];
}


@end
