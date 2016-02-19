//
//  AddDamageVC.m
//  QuikFix
//
//  Created by Sean Barry on 2/18/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "AddDamageVC.h"
#import "QuikClaim.h"


@interface AddDamageVC ()
@property (weak, nonatomic) IBOutlet UILabel *carDetailLabel;
@property (weak, nonatomic) IBOutlet UITextView *damageDescription;
@property UIImage *closeUpOne;
@property UIImage *closeUpTwo;
@property UIImage *twoFootOne;
@property UIImage *twoFootTwo;
@end

@implementation AddDamageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"car dict %@", [self.carDictionary valueForKey:@"vin"]);
    self.closeUpOne = [UIImage imageNamed:@"dent"];
    self.closeUpTwo = [UIImage imageNamed:@"dent"];
    self.twoFootOne = [UIImage imageNamed:@"dent"];
    self.twoFootTwo = [UIImage imageNamed:@"dent"];

    self.carDetailLabel.text = self.carDetailText;

}
- (IBAction)onCloseUpOneTapped:(UIButton *)sender {
}
- (IBAction)onTwoFootOneTapped:(UIButton *)sender {
}
- (IBAction)onCloseUpTwoTapped:(UIButton *)sender {
}
- (IBAction)onTwoFootTwoTapped:(UIButton *)sender {
}

- (IBAction)onSubmitTapped:(UIButton *)sender {

    if ([self isClaimReadyToPush]) {
        QuikClaim *claim = [QuikClaim new];
        claim.carWithDamage = [self.carDictionary valueForKey:@"vin"];
        claim.images = [NSMutableArray arrayWithObjects:self.closeUpOne, self.closeUpTwo, self.twoFootOne, self.twoFootTwo, nil];
        claim.damageDescription = self.damageDescription.text;
        claim.ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
        [claim addClaimToDatabase];
    }
}

-(BOOL)isClaimReadyToPush{
    if (self.closeUpOne == nil) {
        return false;
    }
    else if (self.closeUpTwo == nil) {
        return false;
    }
    else if (self.twoFootOne == nil) {
        return false;
    }
    else if (self.twoFootTwo == nil) {
        return false;
    }
    else if (self.damageDescription.text.length == 0) {
        return false;
    }
    return true;
}

@end
