//
//  InitialViewController.m
//  QuikFix
//
//  Created by Susan Salas on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "InitialViewController.h"
#import "LoginViewController.h"
#import "QuikUserHomepageVC.h"
#import "Firebase/Firebase.h"
#import "QuikVendorHomepageVC.h"

@interface InitialViewController ()
@property bool isVenderProfile;

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [Firebase defaultConfig].persistenceEnabled = YES;
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
    self.isVenderProfile = [[NSUserDefaults standardUserDefaults] boolForKey:@"isVenderProfile"];
    
    if (uid != nil){
        
        Firebase *currentUserRef = [[[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com"] childByAppendingPath:@"users"] childByAppendingPath:uid];
        
        if (currentUserRef.authData) {
            // user authenticated
            [self callPresentVC];
        } else {
            NSLog(@"user not logged in");
        }
    }

    UIColor *navColor = [UIColor colorWithRed:221.0 green:230.0 blue:231 alpha:1];
    [[self.navigationController navigationBar] setTintColor:navColor];
  
}

- (IBAction)onVendorTapped:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isVenderProfile"];
}

- (IBAction)onUserTapped:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isVenderProfile"];
}

- (void) callPresentVC {
    
    if (self.isVenderProfile == YES){
        QuikVendorHomepageVC *vendorHomepageVC = [QuikVendorHomepageVC new];
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"QuikVendorHomepage" bundle:[NSBundle mainBundle]];
        vendorHomepageVC = [board instantiateInitialViewController];
        [self presentViewController:vendorHomepageVC animated:YES completion:nil];
        
    }else if (self.isVenderProfile == NO) {
        QuikUserHomepageVC *quickUserVC = [QuikUserHomepageVC new];
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"QuikUserHomepage" bundle:[NSBundle mainBundle]];
        quickUserVC = [board instantiateInitialViewController];
        [self presentViewController:quickUserVC animated:YES completion:nil];
    }else {
        NSLog(@"could not recognize user or vendor");
    }
    
    
    
}

@end
