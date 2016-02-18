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

@interface CreateAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;

@end

@implementation CreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)onCreateAccountTapped:(UIButton *)sender {
    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"];
    

    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *username = self.usernameLabel.text;
    
    //   create user
    if (!([email isEqualToString:@""] && [password isEqualToString:@""])){
        [ref createUser:email password:password
withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
    
    if (error) {
        // There was an error creating the account
        NSLog(@"error %@", error.description);
    } else {
        NSString *uid = [result objectForKey:@"uid"];
        NSLog(@"Successfully created user account with uid: %@", uid);
        
        [ref authUser:email password:password
  withCompletionBlock:^(NSError *error, FAuthData *authData) {
      
      if (error) {
          // Something went wrong. :(
      } else {
          // Authentication just completed successfully :)
          //segue to
          
          // The logged in user's unique identifier
          [self callPresentVC];
          NSLog(@"Print out UID %@", authData.uid);
          
          // Create a new user dictionary accessing the user's info
          // provided by the authData parameter
          NSDictionary *newUser = @{
                                    @"provider": authData.provider,
                                    @"email": email,
                                    @"uid": authData.uid,
                                    @"username": username
                                    };
          
          // Create a child path with a key set to the uid underneath the "users" node
          // This creates a URL path like the following:
          //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
          [[[ref childByAppendingPath:@"users"] childByAppendingPath:authData.uid] setValue:newUser];
      }
  }];
    }
    
    
}];
    }
    
    
}

- (void) callPresentVC {
    
        QuikUserHomepageVC *quickUserVC = [QuikUserHomepageVC new];
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"QuikUserHomepage" bundle:[NSBundle mainBundle]];
        
        quickUserVC = [board instantiateInitialViewController];
        [self presentViewController:quickUserVC animated:YES completion:nil];
    
}

@end
