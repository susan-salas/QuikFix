//
//  InitialViewController.m
//  QuikFix
//
//  Created by Susan Salas on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "InitialViewController.h"
#import "LoginViewController.h"

@interface InitialViewController ()
@property BOOL isVendorLogin;


@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

- (IBAction)onVendorTapped:(UIButton *)sender {
    self.isVendorLogin = YES;
}

- (IBAction)onUserTapped:(UIButton *)sender {
    self.isVendorLogin = NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    LoginViewController *logInVC = [segue destinationViewController];
    logInVC.isVendorLogIn = self.isVendorLogin;
}

@end
