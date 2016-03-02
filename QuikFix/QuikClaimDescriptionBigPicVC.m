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
@property CGPoint currentTranslation;
@property CGFloat currentScale;

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

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void) setupGesture
{
    UILongPressGestureRecognizer *lpHandler = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHoldGesture:)];
    lpHandler.minimumPressDuration = 1; //seconds
    lpHandler.delegate = self;
    UIPinchGestureRecognizer *pinchHandler = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinchHandler.delegate = self;
    UIPanGestureRecognizer *panHelper = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panHelper.delegate = self;

    [self.imageView addGestureRecognizer:panHelper];
    [self.imageView addGestureRecognizer:lpHandler];
    [self.imageView addGestureRecognizer:pinchHandler];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

    CGPoint translation = [recognizer translationInView:self.imageView];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    float MINIMUM_SCALE = .99;
    float MAXIMUM_SCALE = 3.0;
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateChanged) {
        NSLog(@"gesture.scale = %f", gesture.scale);

        CGFloat currentScale = self.imageView.frame.size.width / self.imageView.bounds.size.width;
        CGFloat newScale = currentScale * gesture.scale;

        if (newScale < MINIMUM_SCALE) {
            newScale = MINIMUM_SCALE;
        }
        if (newScale > MAXIMUM_SCALE) {
            newScale = MAXIMUM_SCALE;
        }

        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        self.imageView.transform = transform;
        gesture.scale = 1;
    }
}

- (void) handleHoldGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Image"
                                                                       message:@"Flag as inappropriate."
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Flag"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

                                                              }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               }];
        
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (IBAction)onCancelButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
