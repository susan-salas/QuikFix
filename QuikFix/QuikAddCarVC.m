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

@interface QuikAddCarVC ()
@property (weak, nonatomic) IBOutlet UITextField *vinTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *makeTextField;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *bodyTextField;
@property (weak, nonatomic) IBOutlet UITextField *colorTextField;
@property (weak, nonatomic) IBOutlet UITextField *licenseTextField;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property QuikCar *carToAdd;


@end

@implementation QuikAddCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onSearchByVinTapped:(UIButton *)sender {
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

- (IBAction)onAddCarTapped:(UIButton *)sender {
    if ([self areTextFieldsFilled]) {
        self.carToAdd = [QuikCar new];
        self.carToAdd.vin = self.vinTextField.text;
        self.carToAdd.year = self.yearTextField.text;
        self.carToAdd.make = self.makeTextField.text;
        self.carToAdd.model = self.modelTextField.text;
        self.carToAdd.body = self.bodyTextField.text;
        self.carToAdd.color = self.colorTextField.text;
        self.carToAdd.license = self.licenseTextField.text;
        self.carToAdd.owner = [[NSUserDefaults standardUserDefaults] stringForKey:@"uid"];
        [self sendCarToDataBase:self.carToAdd];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)areTextFieldsFilled{
    if (self.vinTextField.text.length != 17) {
        return false;
    }
    else if (self.yearTextField.text.length != 4) {
        return false;
    }
    else if (self.makeTextField.text.length == 0) {
        return false;
    }
    else if (self.modelTextField.text.length == 0) {
        return false;
    }
    else if (self.bodyTextField.text.length == 0) {
        return false;
    }
    else if (self.colorTextField.text.length == 0) {
        return false;
    }
    else if (self.licenseTextField.text.length != 7) {
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
                              @"license":car.license,
                              @"owner":car.owner};

    Firebase *ref = [[Firebase alloc] initWithUrl:@"https://beefstagram.firebaseio.com/cars"];
    [[ref childByAppendingPath:car.vin] setValue:carDict];
}


@end
