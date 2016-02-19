//
//  QuikVendorCliamDescriptionVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/16/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikVendorCliamDescriptionVC.h"

@interface QuikVendorCliamDescriptionVC ()
@property (weak, nonatomic) IBOutlet UITextView *claimDescriptionTextView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *imageButtons;

@end

@implementation QuikVendorCliamDescriptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSendEstimateTapped:(UIButton *)sender {
}
- (IBAction)onImageButtonsTapped:(UIButton *)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
