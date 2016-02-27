//
//  QuikAddCarVC.m
//  QuikFix
//
//  Created by Sean Barry on 2/17/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikAddCarVC.h"
#import "QuikCar.h"
#import "QuikUser.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "Firebase/Firebase.h"
#import <QuartzCore/QuartzCore.h>

@interface QuikAddCarVC() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *vinTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *makeTextField;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *bodyTextField;
@property (weak, nonatomic) IBOutlet UITextField *colorTextField;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property QuikCar *carToAdd;


@end

@implementation QuikAddCarVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.vinTextField.delegate = self;
    self.yearTextField.delegate = self;
    self.makeTextField.delegate = self;
    self.modelTextField.delegate = self;
    self.bodyTextField.delegate = self;
    self.colorTextField.delegate = self;
    self.textField.delegate = self;

    [self hideFormToAddCar];

    UIColor *white50 = [UIColor colorWithRed:255 green:255 blue:255 alpha:.5];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"🔍Search by VIN Number"
                                                                           attributes:@{NSForegroundColorAttributeName: white50}];
    self.textField.layer.cornerRadius = 3;
    self.textField.clipsToBounds = YES;
}

- (void)onSearchByVinPressReturn{
    NSString *urlFromTextField = [NSString stringWithFormat:@"http://www.vin-decoder.org/details?vin=%@",self.textField.text];
    NSURL *targetURL = [NSURL URLWithString:urlFromTextField];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table [@class='tvin2']"];
    if (elements.count > 0) {
        TFHppleElement *element = [elements objectAtIndex:0];
        NSString *dataString = [element content];
        NSString *noTabString = [dataString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSCharacterSet *newlineSet = [NSCharacterSet newlineCharacterSet];
        NSPredicate *noNewLines = [NSPredicate predicateWithFormat:@"SELF != ''"];
        NSArray *parts = [noTabString componentsSeparatedByCharactersInSet:newlineSet];
        NSArray *filteredArray = [parts filteredArrayUsingPredicate:noNewLines];
        NSString *cleanString = [filteredArray componentsJoinedByString:@"\n"];

        NSArray *listItems = [cleanString componentsSeparatedByString:@"\n"];
        self.vinTextField.text = listItems[[listItems indexOfObject:@"VIN"] + 1];
        self.yearTextField.text = listItems[[listItems indexOfObject:@"Model Year"] + 1];
        self.makeTextField.text = listItems[[listItems indexOfObject:@"Make"] + 1];
        self.modelTextField.text = listItems[[listItems indexOfObject:@"Model"] + 1];
        self.bodyTextField.text = listItems[[listItems indexOfObject:@"Body"] + 1];

        [self showFormToAddCar];
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Could not find VIN"
                                                                                 message:@"Please enter vehicle details manually."
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *goHomeButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                             }];

        [alertController addAction: goHomeButton];

        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [textView becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    if(textField.tag == 999){
        [self onSearchByVinPressReturn];
    }

    [textField resignFirstResponder];
    return YES;
}

-(void)hideFormToAddCar{
    self.vinTextField.hidden = YES;
    self.yearTextField.hidden = YES;
    self.makeTextField.hidden = YES;
    self.modelTextField.hidden = YES;
    self.bodyTextField.hidden = YES;
    self.colorTextField.hidden = YES;
}

-(void)showFormToAddCar{
    self.vinTextField.hidden = NO;
    self.yearTextField.hidden = NO;
    self.makeTextField.hidden = NO;
    self.modelTextField.hidden = NO;
    self.bodyTextField.hidden = NO;
    self.colorTextField.hidden = NO;
}

- (IBAction)onEnterManuallyTapped:(id)sender {
    [self showFormToAddCar];
}

- (IBAction)onAddCarTapped:(UIButton *)sender {
    [self showFormToAddCar];
    if ([self areTextFieldsFilled]) {
        self.carToAdd = [QuikCar new];
        self.carToAdd.vin = self.vinTextField.text;
        self.carToAdd.year = self.yearTextField.text;
        self.carToAdd.make = self.makeTextField.text;
        self.carToAdd.model = self.modelTextField.text;
        self.carToAdd.body = self.bodyTextField.text;
        self.carToAdd.color = self.colorTextField.text;
        self.carToAdd.owner = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        [self sendCarToDataBase:self.carToAdd];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)areTextFieldsFilled{
    UIColor *red50 = [UIColor colorWithRed:255 green:0 blue:0 alpha:.5];
    NSAttributedString *requiredString = [[NSAttributedString alloc] initWithString:@"Required" attributes:@{NSForegroundColorAttributeName: red50}];
    if (self.vinTextField.text.length != 17) {
        self.vinTextField.textColor = red50;
        self.vinTextField.attributedPlaceholder = requiredString;
        return false;
    }
    else if (self.yearTextField.text.length != 4) {
        self.yearTextField.attributedPlaceholder = requiredString;
        return false;
    }
    else if (self.makeTextField.text.length == 0) {
        self.makeTextField.attributedPlaceholder = requiredString;
        return false;
    }
    else if (self.modelTextField.text.length == 0) {
        self.modelTextField.attributedPlaceholder = requiredString;
        return false;
    }
    else if (self.bodyTextField.text.length == 0) {
        self.bodyTextField.attributedPlaceholder = requiredString;
        return false;
    }
    else if (self.colorTextField.text.length == 0) {
        self.colorTextField.attributedPlaceholder = requiredString;
        return false;
    }
    return true;
}

-(void)sendCarToDataBase:(QuikCar *) car{
    NSDictionary *carDict = @{@"vin":car.vin,
                              @"year":car.year,
                              @"make":car.make,
                              @"model":car.model,
                              @"body":car.body,
                              @"color":car.color,
                              @"owner":car.owner};

    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/cars"];
    [[ref childByAppendingPath:car.vin] setValue:carDict];
}

@end
