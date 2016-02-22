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
#import "QuikUserImagePickerVC.h"
#import "QuikClaim.h"

@interface AddDamageVC () <UITextViewDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *carDetailLabel;
@property (weak, nonatomic) IBOutlet UITextView *damageDescription;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;

@end

@implementation AddDamageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleTap:)];
    tap1.delegate = self;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleTap:)];
    tap2.delegate = self;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleTap:)];
    tap3.delegate = self;
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleTap:)];
    tap3.delegate = self;

    self.carDetailLabel.text = self.carDetailText;

    self.image1.userInteractionEnabled = YES;
    self.image2.userInteractionEnabled = YES;
    self.image3.userInteractionEnabled = YES;
    self.image4.userInteractionEnabled = YES;

    [self.image1 addGestureRecognizer:tap1];
    [self.image2 addGestureRecognizer:tap2];
    [self.image3 addGestureRecognizer:tap3];
    [self.image4 addGestureRecognizer:tap4];

    if([self.title isEqualToString:@"Edit Damage"]){
        NSArray *image = self.claim.images;
        self.image1.contentMode = UIViewContentModeScaleAspectFill;
        self.image1.clipsToBounds = YES;
        self.image1.image = image[0];

        self.image2.contentMode = UIViewContentModeScaleAspectFill;
        self.image2.clipsToBounds = YES;
        self.image2.image = image[1];

        self.image3.contentMode = UIViewContentModeScaleAspectFill;
        self.image3.clipsToBounds = YES;
        self.image3.image = image[2];

        self.image4.contentMode = UIViewContentModeScaleAspectFill;
        self.image4.clipsToBounds = YES;
        self.image4.image = image[3];

        self.damageDescription.text = self.claim.damageDescription;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self performSegueWithIdentifier:@"TakePhotoSegue" sender:tapGestureRecognizer];
}

- (IBAction)onSubmitTapped:(UIButton *)sender {
    if ([self isClaimReadyToPush]) {
        QuikClaim *claim = [QuikClaim new];
        claim.carWithDamage = self.car.vin;
        claim.images = [NSMutableArray arrayWithObjects:self.image1.image, self.image2.image, self.image3.image, self.image4.image, nil];
        claim.damageDescription = self.damageDescription.text;
        claim.ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
        [self addClaimToDatabase:claim];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)isClaimReadyToPush{
    if (self.damageDescription.text.length == 0) {
        self.damageDescription.textColor = [UIColor redColor];
        self.damageDescription.text = @"Cannot be empty";
        return false;
    }
    else if ([self.damageDescription.text isEqualToString:@"Cannot be empty"]) {
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

    if([self.title isEqualToString:@"Edit Damage"]){
        NSString *urlForEdit = [NSString stringWithFormat:@"https://beefstagram.firebaseio.com/claims/%@", self.claim.claimID];
        [claimDict setObject:self.claim.claimID forKey:@"claimID"];
        Firebase *ref2 = [[Firebase alloc] initWithUrl:urlForEdit];
        [claimDict setObject:self.claim.claimID forKey:@"claimID"];
        [ref2 setValue: claimDict];
    }
    else{
        [ref setValue: claimDict];
    }

}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Cannot be empty"]) {
        textView.text = @"";
        self.damageDescription.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITapGestureRecognizer *)sender{
    QuikUserImagePickerVC *dest = segue.destinationViewController;
    dest.imageViewFromPreviousVC = (UIImageView *)[sender view];
}

@end
