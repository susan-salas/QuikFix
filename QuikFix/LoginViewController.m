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


@interface LoginViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
    FBSDKLoginManager *facebookLogin = [[FBSDKLoginManager alloc] init];
    
    [facebookLogin logInWithReadPermissions:@[@"email"]
                                    handler:^(FBSDKLoginManagerLoginResult *facebookResult, NSError *facebookError) {
                                        
                                        if (facebookError) {
                                            NSLog(@"Facebook login failed. Error: %@", facebookError);
                                        } //else if (facebookResult.isCancelled) {
                                        // NSLog(@"Facebook login got cancelled.");
                                        //}
                                        
                                        else {
                                            NSString *accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
                                            NSLog(@"This is our access token %@",accessToken);
                                            
                                            [ref authWithOAuthProvider:@"facebook" token:accessToken
                                                   withCompletionBlock:^(NSError *error, FAuthData *authData) {
                                                       
                                                       if (error) {
                                                           NSLog(@"Login failed. %@", error.description);
                                                       } else {
                                                              Firebase *userRef = [[[Firebase alloc] initWithUrl: @"https://beefstagram.firebaseio.com/user"] childByAppendingPath:authData.uid];
                                                            [userRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                                                               
                                                               if (snapshot.value == [NSNull null]) {
                                                                   
                                                                               NSLog(@"Logged in! %@", authData);
                                                           NSLog(@"displayname = %@", authData.providerData[@"displayName"]);
                                                           NSLog(@"provider = %@", authData.provider);
                                                           NSLog(@"uid = %@", authData.uid);
                                                           NSDictionary *newUser = @{
                                                                                     @"provider": authData.provider,
                                                                                     @"full name": authData.providerData[@"displayName"],
                                                                                     @"email":authData.providerData[@"email"],
                                                                                     @"uid": authData.uid
                                                                                     };
                                                           [[[ref childByAppendingPath:@"users"] childByAppendingPath:authData.uid] setValue:newUser]; 
                                                               }
                                                               
                                                           }];
                                                           
                                              
                                                       }
                                                   }];
                                        }
                                    }];
    
    
}
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self;
    loginButton.center = self.view.center;
    [self.view addSubview:loginButton];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    
    if (uid != nil){
        
        Firebase *currentUserRef = [[[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/media"] childByAppendingPath:@"users"] childByAppendingPath:uid];
        
        if (currentUserRef.authData) {
            // user authenticated
            //segue to user page VC
            NSLog(@"This is the auth data %@", currentUserRef.authData);
            NSLog(@"user already logged in");
        } else {
            NSLog(@"user not logged in");
            // No user is signed in
        }
    }
    
}

- (IBAction)onLogInTapped:(UIButton *)sender {
    NSString *email =  self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
    [ref authUser:email password:password
withCompletionBlock:^(NSError *error, FAuthData *authData) {
    
    if (error) {
        NSLog(@"We are not logged in");
    } else {
        //perfrom segue
        NSLog(@"user is now logged in");
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:authData.uid forKey:@"uid"];
}];
}




@end
