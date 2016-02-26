//
//  QuikClaimDescriptionBigPicVC.m
//  QuikFix
//
//  Created by Sujin Oh on 2/24/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import "QuikClaimDescriptionBigPicVC.h"

@interface QuikClaimDescriptionBigPicVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation QuikClaimDescriptionBigPicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.currentImage;
    // Do any additional setup after loading the view.
}
- (IBAction)onCancelButtonTapped:(UIButton *)sender {
   [self dismissViewControllerAnimated:YES completion:nil];
}


@end
