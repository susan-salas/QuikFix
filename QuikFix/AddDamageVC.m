//
//  AddDamageVC.m
//  QuikFix
//
//  Created by Sean Barry on 2/18/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//
//  comment

#import "AddDamageVC.h"
#import "QuikClaim.h"
#import "QuikCar.h"
#import "QuikClaim.h"
#import "Firebase/Firebase.h"
#import "QuikUserImagePickerVC.h"
#import "QuikClaim.h"
#import <QuartzCore/QuartzCore.h>

@interface AddDamageVC () <UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *panelTextField;
@property (weak, nonatomic) IBOutlet UITextField *damageTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *damageDescription;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property UITapGestureRecognizer *tapRecognizer;

@end

@implementation AddDamageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self toDismissKeyboard];

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

    self.image1.userInteractionEnabled = YES;
    self.image2.userInteractionEnabled = YES;
    self.image3.userInteractionEnabled = YES;
    self.image4.userInteractionEnabled = YES;

    [self.image1 addGestureRecognizer:tap1];
    [self.image2 addGestureRecognizer:tap2];
    [self.image3 addGestureRecognizer:tap3];
    [self.image4 addGestureRecognizer:tap4];

    self.image1.layer.cornerRadius = 3;
    self.image2.layer.cornerRadius = 3;
    self.image3.layer.cornerRadius = 3;
    self.image4.layer.cornerRadius = 3;
    self.submitButton.layer.cornerRadius = 3;

    self.image1.clipsToBounds = YES;
    self.image2.clipsToBounds = YES;
    self.image3.clipsToBounds = YES;
    self.image4.clipsToBounds = YES;
    self.submitButton.clipsToBounds = YES;

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

        self.panelTextField.text = self.claim.panel;
        self.damageTypeTextField.text = self.claim.damageType;
        self.damageDescription.text = self.claim.damageDescription;

        [self.submitButton setTitle:@"Save" forState:UIControlStateNormal];
    }

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self performSegueWithIdentifier:@"TakePhotoSegue" sender:tapGestureRecognizer];
}

- (IBAction)onSubmitTapped:(UIButton *)sender {
    if ([self isClaimReadyToPush]) {
        QuikClaim *claim = [QuikClaim new];
        float latitude = self.locationManager.location.coordinate.latitude;
        float longitude = self.locationManager.location.coordinate.longitude;

        claim.carWithDamage = self.car.vin;
        claim.claimLocation = @{@"latitude":[NSNumber numberWithFloat:latitude], @"longitude":[NSNumber numberWithFloat:longitude]};
        claim.images = [NSMutableArray arrayWithObjects:self.image1.image, self.image2.image, self.image3.image, self.image4.image, nil];
        claim.damageDescription = self.damageDescription.text;
        claim.ownerID = [[NSUserDefaults standardUserDefaults] valueForKey:@"uid"];
        claim.username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        claim.panel = self.panelTextField.text;
        claim.damageType = self.damageTypeTextField.text;
        claim.carDetail = self.car.detail;
        [self addClaimToDatabase:claim];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)isClaimReadyToPush{
    if (self.panelTextField.text.length == 0) {
        self.panelTextField.placeholder = @"Panel Required";
        return false;
    }
    else if (self.damageTypeTextField.text.length == 0) {
        self.damageTypeTextField.placeholder = @"Type Required";
        return false;
    }
    else if (self.damageDescription.text.length == 0) {
        self.damageDescription.placeholder = @"Description Required";
        return false;
    }
    return true;
}


-(void) addClaimToDatabase:(QuikClaim *)claim{
    Firebase *ref = [[[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/claims"] childByAutoId];
    NSMutableDictionary *claimDict = [NSMutableDictionary new];

    [claimDict setObject:[ref key] forKey:@"claimID"];
    [claimDict setObject:claim.carWithDamage forKey:@"carWithDamage"];
    [claimDict setObject:claim.panel forKey:@"panel"];
    [claimDict setObject:claim.damageType forKey:@"damageType"];
    [claimDict setObject:claim.damageDescription forKey:@"damageDescription"];
    [claimDict setObject:claim.ownerID forKey:@"owner"];
    [claimDict setObject:claim.username forKey:@"username"];
    [claimDict setObject:claim.claimLocation forKey:@"location"];
    [claimDict setObject:claim.carDetail forKey:@"carDetail"];

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
        [claimDict setObject:self.claim.offersDictionary forKey:@"offers"];
        [claimDict setObject:self.claim.claimID forKey:@"claimID"];
        Firebase *ref2 = [[Firebase alloc] initWithUrl:urlForEdit];
        [ref2 setValue: claimDict];
    }
    else{
        [ref setValue: claimDict];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITapGestureRecognizer *)sender{
    QuikUserImagePickerVC *dest = segue.destinationViewController;
    dest.imageViewFromPreviousVC = (UIImageView *)[sender view];
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
    [self.panelTextField resignFirstResponder];
    [self.damageTypeTextField resignFirstResponder];
    [self.damageDescription resignFirstResponder];
}


@end
