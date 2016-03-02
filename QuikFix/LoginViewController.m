//
//  LoginViewController.m
//  QuikFix
//
//  Created by Susan Salas on 2/15/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Firebase/Firebase.h"
#import "QuikUserHomepageVC.h"
#import "QuikVendorHomepageVC.h"
#import "Batch/Batch.h"


@interface LoginViewController () <FBSDKLoginButtonDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabelView;
@property (weak, nonatomic) IBOutlet UIButton *logInLabelView;
@property NSString *email;
@property bool isVendorLogIn;
@property UITapGestureRecognizer *tapRecognizer;

@end

@implementation LoginViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self toDismissKeyboard];
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.passwordTextField.layer.cornerRadius = 3;
    self.passwordTextField.clipsToBounds = YES;
    
    self.emailTextField.layer.cornerRadius = 3;
    self.emailTextField.clipsToBounds = YES;
    
    self.logInLabelView.layer.cornerRadius = 3;
    self.logInLabelView.clipsToBounds = YES;
    
    self.isVendorLogIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"isVenderProfile"];
    
    if (self.isVendorLogIn == YES) {
        self.orLabelView.hidden = YES;
    }
    else{
        FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
        //check for current button title
        if([loginButton.currentTitle isEqualToString:@"Log out"]){
            [self callPresentVC];
        }
        
        UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:@"Create Account"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(onCreateTapped)];
        self.navigationItem.rightBarButtonItem = createButton;
        
        loginButton.delegate = self;
        CGRect fbFrame = loginButton.frame;
        fbFrame = CGRectMake(20, 20, self.view.bounds.size.width - 40, 60);
        loginButton.frame = fbFrame;
        
        [self.view addSubview:loginButton];
    }
}


- (void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)onCreateTapped{
    [self performSegueWithIdentifier:@"CreateTapped" sender:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.emailTextField.text = @"";
    self.passwordTextField.text = @"";
}


- (IBAction)onLogInTapped:(UIButton *)sender {
    NSString *email =  self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]){
        //ui alert cannot leave textfields blank
        self.emailTextField.placeholder = @"Email required";
        self.passwordTextField.placeholder = @"Password required";
    }else{
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
        [ref authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
            
            if (error) {
                NSLog(@"We are not logged in %@", error);
            } else {
                [self callPresentVC];
                NSLog(@"user is now logged in");
                [[NSUserDefaults standardUserDefaults] setValue:authData.uid forKey:@"uid"];
                
                NSString *userURL = [NSString stringWithFormat:@"https://beefstagram.firebaseio.com/users/%@",authData.uid];
                
                Firebase *usersRef = [[Firebase alloc] initWithUrl: userURL];
                [usersRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    NSDictionary *userDict = snapshot.value;
                    [[NSUserDefaults standardUserDefaults] setValue:[userDict objectForKey:@"username"] forKey:@"username"];
                }];
            }
            
            
            
        }];
    }
    
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
    if (error) {
        NSLog(@"Facebook login failed. Error: %@", error);
    }
    else {
        NSString *accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];

        [ref authWithOAuthProvider:@"facebook" token:accessToken withCompletionBlock:^(NSError *error, FAuthData *authData) {
            
            if (error) {
                NSLog(@"Login failed. %@", error.description);
            } else {
                
                Firebase *userRef = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/user"] childByAppendingPath:authData.uid];
                [userRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:authData.uid forKey:@"uid"];
                    [[NSUserDefaults standardUserDefaults] setValue:authData.providerData[@"displayName"] forKey:@"username"];


                if (snapshot.value == [NSNull null]) {
                       if (authData.providerData[@"email"] == NULL){
                            NSDictionary *newUser = @{
                                                      @"provider": authData.provider,
                                                      @"username": authData.providerData[@"displayName"],
                                                      
                                                      @"uid": authData.uid
                                                      };
                            [[[ref childByAppendingPath:@"users"] childByAppendingPath:authData.uid] setValue:newUser];
                            
                            
                        }else {
                            NSDictionary *newUser = @{
                                                      @"provider": authData.provider,
                                                      @"username": authData.providerData[@"displayName"],
                                                      @"email":authData.providerData[@"email"],
                                                      @"uid": authData.uid
                                                      };
                            [[[ref childByAppendingPath:@"users"] childByAppendingPath:authData.uid] setValue:newUser];
                            [self callPresentVC];
                        }
                    }
                }];
            }
        }];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}

- (void) callPresentVC {
    
    if (self.isVendorLogIn == true){
        QuikVendorHomepageVC *vendorHomepageVC = [QuikVendorHomepageVC new];
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"QuikVendorHomepage" bundle:[NSBundle mainBundle]];
        vendorHomepageVC = [board instantiateInitialViewController];
        [self presentViewController:vendorHomepageVC animated:YES completion:nil];
        
    }else{
        QuikUserHomepageVC *quickUserVC = [QuikUserHomepageVC new];
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"QuikUserHomepage" bundle:[NSBundle mainBundle]];
        
        quickUserVC = [board instantiateInitialViewController];
        [self presentViewController:quickUserVC animated:YES completion:nil];
    }
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
}



@end
