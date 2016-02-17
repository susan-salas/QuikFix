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

@interface QuikAddCarVC ()
@property (weak, nonatomic) IBOutlet UITextField *vinTextField;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *makeTextField;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *bodyTextField;
@property (weak, nonatomic) IBOutlet UITextField *colorTextField;
@property (weak, nonatomic) IBOutlet UITextField *licenseTextField;
@property (weak, nonatomic) IBOutlet UITextField *textField;


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

        NSLog(@"List Items: %@", listItems);
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
        QuikCar *car = [QuikCar new];
        car.vin = self.vinTextField.text;
        car.year = self.yearTextField.text;
        car.make = self.makeTextField.text;
        car.model = self.modelTextField.text;
        car.body = self.bodyTextField.text;
//        NSString *str = self.colorTextField.text;
//        SEL labelColor = NSSelectorFromString(str);
   //     UIColor *color = [UIColor performSelector:labelColor];
        //car.color = color;
        car.license = self.licenseTextField.text;
        [car addCarToDatabase];
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


@end
