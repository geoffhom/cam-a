//
//  GGKTakePhotoAbstractViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 5/9/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakePhotoAbstractViewController.h"

#import "GGKSavedPhotoViewController.h"
#import "GGKSavedPhotosManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

NSString *GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString = @"captureManager.focusAndExposureStatus";

@interface GGKTakePhotoAbstractViewController ()

// For dismissing the current popover. Would name "popoverController," but UIViewController already has a private variable named that.
@property (nonatomic, strong) UIPopoverController *currentPopoverController;

@end

@implementation GGKTakePhotoAbstractViewController

- (void)captureManagerDidTakePhoto:(id)sender
{
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
}
- (void)dealloc {
//    NSLog(@"TPAVC dealloc1");
    [self.captureManager stopSession];
    [self removeObserver:self forKeyPath:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString];
}
- (void)handleViewDidDisappearFromUser {
    [super handleViewDidDisappearFromUser];
    [self.captureManager stopSession];
    
    //testing
//    [self.captureManager removePreviewLayer];

}
- (void)handleViewWillAppearToUser {
    [super handleViewWillAppearToUser];
    [self.savedPhotosManager showMostRecentPhotoOnButton:self.cameraRollButton];
    
    //testing
//    [self.captureManager replacePreviewLayerWithNewOneToView:self.videoPreviewView];
    [self.captureManager startSession];
}
- (void)imagePickerController:(UIImagePickerController *)theImagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)theInfoDictionary {
    // An image picker controller is also a navigation controller. So, we'll push a view controller with the image onto the image picker controller.
    // Was going to use a push segue in the storyboard, for clarity. However, this VC is abstract and not instantiated from the storyboard, so that doesn't work.
    // Note that the image picker is assumed to be 320 x 480, as set in the storyboard.
    
    GGKSavedPhotoViewController *aSavedPhotoViewController = (GGKSavedPhotoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SavedPhotoViewController"];
    UIImage *anImage = theInfoDictionary[UIImagePickerControllerOriginalImage];
    
    // If we set the image before pushing the view controller, it doesn't work.
    [theImagePickerController pushViewController:aSavedPhotoViewController animated:YES];
    aSavedPhotoViewController.imageView.image = anImage;
}
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)theOperation fromViewController:(UIViewController *)theFromVC toViewController:(UIViewController *)theToVC {
    if ((theOperation == UINavigationControllerOperationPop) && (theFromVC == self)) {
        self.navigationController.delegate = nil;
    }
    if ((theOperation == UINavigationControllerOperationPush) && (theFromVC == self)) {
        NSLog(@"about to push onto self: destroy session");
        [self.captureManager destroySession];
    }
    if ((theOperation == UINavigationControllerOperationPop) && (theToVC == self)) {
        NSLog(@"about to pop to self: create session");
        [self.captureManager setUpSession];
    }
    
    return nil;
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"TPAVC nC dSVC a");
}
- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString]) {
        
// Template for subclasses.
//        switch (self.captureManager.focusAndExposureStatus) {
//                
//            case GGKCaptureManagerFocusAndExposureStatusContinuous:
//                break;
//                
//            case GGKCaptureManagerFocusAndExposureStatusLocking:
//                break;
//                
//            case GGKCaptureManagerFocusAndExposureStatusLocked:
//                break;
//                
//            default:
//                break;
//        }
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)theSender
{
    if ([theSegue.identifier hasPrefix:@"ShowSavedPhotos"]) {
        
        // Story: User took photos. User viewed photos. User decided to delete some photos.
        // So, let the user view the taken photos and (optionally) remove them.
        // (Oops: Can't delete saved photos like in Apple's camera app. Apple doesn't allow.)
        // New story: User took photos. User can view thumbnails quickly.
                
        // Retain popover controller, to dismiss later.
        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        
        // Set up the image picker controller.
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            
            UIImagePickerController *anImagePickerController = (UIImagePickerController *)theSegue.destinationViewController;
            anImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            anImagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            anImagePickerController.delegate = self;
            anImagePickerController.allowsEditing = NO;
        }
    } else {
        
        [super prepareForSegue:theSegue sender:theSender];
    }
}
- (IBAction)takePhoto
{
    [self playButtonSound];
    [self.captureManager takePhoto];
    
    // Give visual feedback that photo was taken: Flash the screen.
    UIView *aFlashView = [[UIView alloc] initWithFrame:self.videoPreviewView.frame];
    aFlashView.backgroundColor = [UIColor whiteColor];
    aFlashView.alpha = 0.8f;
    [self.view addSubview:aFlashView];
    [UIView animateWithDuration:0.6f animations:^{
        
        aFlashView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
        [aFlashView removeFromSuperview];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.savedPhotosManager = [[GGKSavedPhotosManager alloc] init];
    // Report focus (and exposure) status in real time.
    [self addObserver:self forKeyPath:GGKObserveCaptureManagerFocusAndExposureStatusKeyPathString options:NSKeyValueObservingOptionNew context:nil];
    // Set up the camera.
    GGKCaptureManager *theCaptureManager = [[GGKCaptureManager alloc] init];
    theCaptureManager.delegate = self;
    [theCaptureManager setUpSession];
    [theCaptureManager addPreviewLayerToView:self.videoPreviewView];
    self.captureManager = theCaptureManager;
    // Watch for push onto this VC. If so, capture session will snapshot (undesired).
    self.navigationController.delegate = self;
}

// testing
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [self.captureManager stopSession];
////    [self.captureManager removePreviewLayer];
//}
@end
