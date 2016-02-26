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
#import "Firebase/Firebase.h"
#import "QuikUserHomepageVC.h"
#import "QuikVendorHomepageVC.h"
#import "Batch/Batch.h"


@interface LoginViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property NSString *email;
@property bool isVendorLogIn;

@end

@implementation LoginViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isVendorLogIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"isVenderProfile"];
    
    if (self.isVendorLogIn == YES) {
        self.title = @"Login";
        self.createAccountButton.hidden = true;
    }else{
        FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
        //check for current button title
        if([loginButton.currentTitle isEqualToString:@"Log out"]){
            [self callPresentVC];
        }
         
        loginButton.delegate = self;
        loginButton.center = self.view.center;
        CGRect fbFrame = loginButton.frame;
        fbFrame.origin.y = self.enterButton.frame.origin.y + 50;
        loginButton.frame = fbFrame;
        [self.view addSubview:loginButton];
        self.createAccountButton.hidden = NO;
        self.title = @"Login";
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.emailTextField.text = @"";
    self.passwordTextField.text = @"";
}


- (IBAction)onLogInTapped:(UIButton *)sender {
    NSString *email =  self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    if ([self.emailTextField.text isEqualToString:@""] && [self.passwordTextField.text isEqualToString:@""]){
        //ui alert cannot leave textfields blank
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Please enter email and password" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
        [ref authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
            
            if (error) {
                NSLog(@"We are not logged in %@", error);
            } else {
                [self callPresentVC];
                NSLog(@"user is now logged in");
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:authData.uid forKey:@"uid"];
            
            NSString *userURL = [NSString stringWithFormat:@"https://beefstagram.firebaseio.com/users/%@",authData.uid];
            
            Firebase *usersRef = [[Firebase alloc] initWithUrl: userURL];
            [usersRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                NSDictionary *userDict = snapshot.value;
                [[NSUserDefaults standardUserDefaults] setValue:[userDict objectForKey:@"username"] forKey:@"username"];
            }];
            
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
        NSLog(@"This is our access token %@",accessToken);
        
        [ref authWithOAuthProvider:@"facebook" token:accessToken withCompletionBlock:^(NSError *error, FAuthData *authData) {
            
            if (error) {
                NSLog(@"Login failed. %@", error.description);
            } else {
                
                Firebase *userRef = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/user"] childByAppendingPath:authData.uid];
                [userRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:authData.uid forKey:@"uid"];
                    [[NSUserDefaults standardUserDefaults] setValue:authData.providerData[@"displayName"] forKey:@"username"];
                    
                    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
                    NSLog(@"nsuserdefaults set in facebook log in == %@",uid);
                    NSLog(@"authData.providerData[@displayName] == %@",authData.providerData[@"displayName"]);
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




@end
