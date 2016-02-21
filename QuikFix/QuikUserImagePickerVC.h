//
//  QuikUserImagePickerVC.h
//  QuikFix
//
//  Created by Sean Barry on 2/20/16.
//  Copyright © 2016 Susan Salas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuikUserImagePickerVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *onLibraryTapped;
@property (weak, nonatomic) IBOutlet UIButton *onCameraTapped;

@end
