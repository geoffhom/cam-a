//
//  GGKTakePhotoViewController.m
//  Mercy Camera
//
//  Created by Geoff Hom on 4/12/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import "GGKCaptureManager.h"
#import "GGKTakePhotoViewController.h"

BOOL GGKDebugCamera = YES;
//BOOL GGKDebugCamera = NO;

@interface GGKTakePhotoViewController ()

// For removing the observer later.
@property (strong, nonatomic) id appWillEnterForegroundObserver;

@property (strong, nonatomic) GGKCaptureManager *captureManager;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

// For retaining the popover and its content view controller.
@property (strong, nonatomic) UIPopoverController *savedPhotosPopoverController;

// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// So, update the image in the button for showing the camera roll. If another photo is supposed to be taken, do it.

// Show most-recent photo from camera roll on button for viewing camera roll.
- (void)showMostRecentPhotoOnButton;

@end

@implementation GGKTakePhotoViewController

- (void)dealloc
{
    [self.captureManager.session stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{    
    [self showMostRecentPhotoOnButton];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)playButtonSound
{
    [self.soundModel playButtonTapSound];
}

- (void)showMostRecentPhotoOnButton
{    
    // Show thumbnail on button for showing camera roll.
    void (^showPhotoOnButton)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *photoAsset, NSUInteger index, BOOL *stop) {
        
        // End of enumeration is signalled by asset == nil.
        if (photoAsset == nil) {
            
            return;
        }
        
        CGImageRef aPhotoThumbnailImageRef = [photoAsset thumbnail];
        UIImage *aPhotoImage = [UIImage imageWithCGImage:aPhotoThumbnailImageRef];
        [self.cameraRollButton setImage:aPhotoImage forState:UIControlStateNormal];
        
        // If we don't the title to nil, it still shows along the edge.
        [self.cameraRollButton setTitle:nil forState:UIControlStateNormal];
    };
    
    // Show thumbnail of most-recent photo in group on button for showing camera roll.
    void (^showMostRecentPhotoInGroupOnButton)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        
        // If no photos, skip.
        [ group setAssetsFilter:[ALAssetsFilter allPhotos] ];
        NSInteger theNumberOfPhotos = [group numberOfAssets];
        if (theNumberOfPhotos < 1) {
            
            return;
        }
        
        NSIndexSet *theMostRecentPhotoIndexSet = [NSIndexSet indexSetWithIndex:(theNumberOfPhotos - 1)];
        [group enumerateAssetsAtIndexes:theMostRecentPhotoIndexSet options:0 usingBlock:showPhotoOnButton];
    };
    
    // If no photos, show this text.
    [self.cameraRollButton setTitle:@"Saved photos" forState:UIControlStateNormal];
    
    ALAssetsLibrary *theAssetsLibrary = [[ALAssetsLibrary alloc] init];
    [theAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:showMostRecentPhotoInGroupOnButton failureBlock:^(NSError *error) {
        
        NSLog(@"Warning: Couldn't see saved photos.");
    }];
}

- (IBAction)takePhoto
{    
//    NSLog(@"SDPVC takePhoto called");
    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.captureVideoPreviewLayer.session.outputs[0];
//    AVCaptureStillImageOutput *aCaptureStillImageOutput = (AVCaptureStillImageOutput *)self.captureSession.outputs[0];
    AVCaptureConnection *aCaptureConnection = [aCaptureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
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
    
    if (aCaptureConnection != nil) {
        
        [aCaptureStillImageOutput captureStillImageAsynchronouslyFromConnection:aCaptureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (imageDataSampleBuffer != NULL) {
                
                NSData *theImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *theImage = [[UIImage alloc] initWithData:theImageData];
                UIImageWriteToSavedPhotosAlbum(theImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }];
    } else {
        
        NSLog(@"GGK warning: aCaptureConnection nil");
        UIImageWriteToSavedPhotosAlbum(nil, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.soundModel = [[GGKSoundModel alloc] init];
    
    // Set up the camera.
    GGKCaptureManager *theCaptureManager = [[GGKCaptureManager alloc] init];
    [theCaptureManager setUpSession];
    self.captureManager = theCaptureManager;
        
    // Add camera preview.
    AVCaptureVideoPreviewLayer *aCaptureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureManager.session];
    aCaptureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
    aCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    CALayer *viewLayer = self.videoPreviewView.layer;
    [viewLayer addSublayer:aCaptureVideoPreviewLayer];
    self.captureVideoPreviewLayer = aCaptureVideoPreviewLayer;
    
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
    NSOperationQueue *anOperationQueue = [[NSOperationQueue alloc] init];
    [anOperationQueue addOperationWithBlock:^{
        [self.captureManager.session startRunning];
    }];
    
    // Story: User taps on object. Focus locks there. User taps again in view. Focus returns to continuous.
    UITapGestureRecognizer *aSingleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTappedInCameraView:)];
    aSingleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.videoPreviewView addGestureRecognizer:aSingleTapGestureRecognizer];
    
    // If not debugging, hide those labels. (They're shown by default so we can see them in the storyboard.) If debugging, set up KVO.
    if (!GGKDebugCamera) {
        
        self.focusModeLabel.hidden = YES;
        self.exposureModeLabel.hidden = YES;
        self.whiteBalanceModeLabel.hidden = YES;
        self.focusPointOfInterestLabel.hidden = YES;
        self.exposurePointOfInterestLabel.hidden = YES;
    } else {
        
        if (self.captureManager.device != nil) {
            
            [self updateCameraDebugLabels];
            
            // Tried adding observer to self.captureManager.device, but it didn't work.
            [self addObserver:self forKeyPath:@"captureManager.device.focusMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.exposureMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.whiteBalanceMode" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.focusPointOfInterest" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self forKeyPath:@"captureManager.device.exposurePointOfInterest" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"TPVC oVFKP");
    if ([theKeyPath isEqualToString:@"captureManager.device.focusMode"] || [theKeyPath isEqualToString:@"captureManager.device.exposureMode"] || [theKeyPath isEqualToString:@"captureManager.device.whiteBalanceMode"] || [theKeyPath isEqualToString:@"captureManager.device.focusPointOfInterest"] || [theKeyPath isEqualToString:@"captureManager.device.exposurePointOfInterest"]) {
        
        NSLog(@"TPVC oVFKP2");
        [self updateCameraDebugLabels];
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

// Story: User taps on object. Focus locks there. User taps again in view. Focus returns to continuous.
- (void)handleUserTappedInCameraView:(UITapGestureRecognizer *)theTapGestureRecognizer
{
    NSLog(@"TPVC handleUserTappedInCameraView");
    
    // If focus is locked, unlock. Else, focus and lock it.
    
    // could do this in the capture manager. just need the converted tap point.
    
    if (self.captureManager.device == nil) {
        
        NSLog(@"GGK warning: No capture-device input.");
        return;
    }
    
    AVCaptureDevice *aCaptureDevice = self.captureManager.device;
    if (aCaptureDevice.focusMode == AVCaptureFocusModeLocked) {
        
        NSError *anError;
        BOOL aDeviceMayBeConfigured = [aCaptureDevice lockForConfiguration:&anError];
        if (aDeviceMayBeConfigured) {
            
            NSLog(@"TPVC handleUserTappedInCameraView2");
            aCaptureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            [aCaptureDevice unlockForConfiguration];
        }
    } else {
        
        CGPoint theTapPoint = [theTapGestureRecognizer locationInView:self.videoPreviewView];
        CGPoint theConvertedTapPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:theTapPoint];        
        
        NSError *anError;
        BOOL aDeviceMayBeConfigured = [aCaptureDevice lockForConfiguration:&anError];
        if (aDeviceMayBeConfigured) {
            
            NSLog(@"TPVC handleUserTappedInCameraView3");
            aCaptureDevice.focusPointOfInterest = theConvertedTapPoint;
        // do focus scan after setting focal point?
            aCaptureDevice.focusMode = AVCaptureFocusModeAutoFocus;
            [aCaptureDevice unlockForConfiguration];
        }
    }
}

- (IBAction)viewPhotos
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        // UIImagePickerController browser on iPad must be presented in a popover.
        
        UIImagePickerController *anImagePickerController = [[UIImagePickerController alloc] init];
        anImagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        anImagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        anImagePickerController.delegate = self;
        anImagePickerController.allowsEditing = NO;
        
        UIPopoverController *aPopoverController = [[UIPopoverController alloc] initWithContentViewController:anImagePickerController];
        [aPopoverController presentPopoverFromRect:self.cameraRollButton.bounds inView:self.cameraRollButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.savedPhotosPopoverController = aPopoverController;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.appWillEnterForegroundObserver == nil) {
        
        self.appWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            [self viewWillAppear:animated];
        }];
    }
    
    [self showMostRecentPhotoOnButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.appWillEnterForegroundObserver != nil) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self.appWillEnterForegroundObserver name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

//temp
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
////    if (context == AVCamFocusModeObserverContext) {
//        // Update the focus UI overlay string when the focus mode changes
//		[focusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
////	} else {
////        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
////    }
//}

// (For testing.) Show the current camera settings.
- (void)updateCameraDebugLabels
{
    AVCaptureDevice *aCaptureDevice = self.captureManager.device;
    NSString *aString = @"";
    switch (aCaptureDevice.focusMode) {
            
        case AVCaptureFocusModeAutoFocus:
            aString = @"auto.";
            break;
            
        case AVCaptureFocusModeContinuousAutoFocus:
            aString = @"cont.";
            break;
            
        case AVCaptureFocusModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.focusModeLabel.text = [NSString stringWithFormat:@"Foc. mode: %@", aString];
    
    switch (aCaptureDevice.exposureMode) {
            
        case AVCaptureExposureModeAutoExpose:
            aString = @"auto.";
            break;
            
        case AVCaptureExposureModeContinuousAutoExposure:
            aString = @"cont.";
            break;
            
        case AVCaptureExposureModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.exposureModeLabel.text = [NSString stringWithFormat:@"Exp. mode: %@", aString];
    
    switch (aCaptureDevice.whiteBalanceMode) {
            
        case AVCaptureWhiteBalanceModeAutoWhiteBalance:
            aString = @"auto.";
            break;
            
        case AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance:
            aString = @"cont.";
            break;
            
        case AVCaptureWhiteBalanceModeLocked:
            aString = @"lock.";
            break;
            
        default:
            break;
    }
    self.whiteBalanceModeLabel.text = [NSString stringWithFormat:@"WB mode: %@", aString];
    
    // Show points of interest, rounded to decimal (0.1).
    CGPoint aPoint = aCaptureDevice.focusPointOfInterest;
    self.focusPointOfInterestLabel.text = [NSString stringWithFormat:@"Foc. POI: {%.1f, %.1f}", aPoint.x, aPoint.y];
    aPoint = aCaptureDevice.exposurePointOfInterest;
    self.exposurePointOfInterestLabel.text = [NSString stringWithFormat:@"Exp. POI: {%.1f, %.1f}", aPoint.x, aPoint.y];
}

@end
