//
//  QuikClaimDescriptionBigPicVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/24/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikClaimDescriptionBigPicVC.h"
#import <QuartzCore/QuartzCore.h>


@interface QuikClaimDescriptionBigPicVC () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation QuikClaimDescriptionBigPicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.currentImage;
    self.imageView.userInteractionEnabled = YES;
    self.closeButton.layer.cornerRadius = 3;
    self.closeButton.clipsToBounds = YES;
    [self setupGesture];
}

-(void) setupGesture
{
    UILongPressGestureRecognizer *lpHandler = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHoldGesture:)];
    lpHandler.minimumPressDuration = 1; //seconds
    lpHandler.delegate = self;
    [self.imageView addGestureRecognizer:lpHandler];
}

- (void) handleHoldGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Image"
                                                                       message:@"Flag as inappropriate."
                                                                preferredStyle:UIAlertControllerStyleActionSheet]; // 1
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Flag"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

                                                              }]; // 2
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               }]; // 3
        
        [alert addAction:firstAction]; // 4
        [alert addAction:secondAction]; // 5
        
        [self presentViewController:alert animated:YES completion:nil]; // 6
    }

}

- (IBAction)onCancelButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
