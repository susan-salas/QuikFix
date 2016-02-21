//
//  AddDamageVC.m
//  QuikFix
//
//  Created by Sean Barry on 2/18/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "AddDamageVC.h"
#import "QuikClaim.h"
#import "QuikCar.h"
#import "QuikClaim.h"
#import "Firebase/Firebase.h"


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
        claim.carWithDamage = self.car.vin;
        claim.images = [NSMutableArray arrayWithObjects:self.closeUpOne, self.closeUpTwo, self.twoFootOne, self.twoFootTwo, nil];
        claim.damageDescription = self.damageDescription.text;
        claim.ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
        [self addClaimToDatabase:claim];
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

-(void) addClaimToDatabase:(QuikClaim *)claim{
    Firebase *ref = [[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/claims"] childByAutoId];

    NSMutableDictionary *claimDict = [NSMutableDictionary new];
    [claimDict setObject:[ref key] forKey:@"claimID"];
    [claimDict setObject:claim.carWithDamage forKey:@"carWithDamage"];
    [claimDict setObject:claim.damageDescription forKey:@"damageDescription"];
    [claimDict setObject:claim.ownerID forKey:@"owner"];

    NSArray *images = claim.images;
    NSString *encodedCloseUp1 = [UIImagePNGRepresentation(images[0]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *encodedCloseUp2 = [UIImagePNGRepresentation(images[1]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *encodedTwoFt1 = [UIImagePNGRepresentation(images[2]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *encodedTwoFt2 = [UIImagePNGRepresentation(images[3]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    NSDictionary *imageDict = @{@"closeUp1":encodedCloseUp1,
                                @"closeUp2":encodedCloseUp2,
                                @"TwoFt1":encodedTwoFt1,
                                @"TwoFt2":encodedTwoFt2};
    [claimDict setObject:imageDict forKey:@"images"];
    [ref setValue: claimDict];
}

@end
