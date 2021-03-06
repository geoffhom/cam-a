//
//  GGKSavedPhotosManager.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/29/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

@interface GGKSavedPhotosManager : NSObject <UIImagePickerControllerDelegate>
// Show most-recent photo from camera roll on the given button.
- (void)showMostRecentPhotoOnButton:(UIButton *)theButton;
@end
