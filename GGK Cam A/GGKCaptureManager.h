//
//  GGKCaptureManager.h
//  Mercy Camera
//
//  Created by Geoff Hom on 4/14/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

// This manages a capture session for taking photos from the rear camera: Input is the rear camera; output is a still image.

#import <AVFoundation/AVFoundation.h>

extern BOOL GGKDebugCamera;

// The combined status of the camera's focus and exposure. The assumption is that both are continuously adjusting, both are in the process of locking (one may be locked, and the other may be locking), or both are locked.
typedef enum {
    
    GGKCaptureManagerFocusAndExposureStatusContinuous,
    GGKCaptureManagerFocusAndExposureStatusLocking,
    GGKCaptureManagerFocusAndExposureStatusLocked
} GGKCaptureManagerFocusAndExposureStatus;

@protocol GGKCaptureManagerDelegate

// Sent after a photo was taken and saved (to the camera roll). If a photo couldn't be taken (e.g., no camera), this is still sent.
- (void)captureManagerDidTakePhoto:(id)sender;

@end

@interface GGKCaptureManager : NSObject

//temp moved
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *session;




@property (weak, nonatomic) id <GGKCaptureManagerDelegate> delegate;

// The input capture device. I.e., the rear camera.
@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic, assign) GGKCaptureManagerFocusAndExposureStatus focusAndExposureStatus;
// Add a video preview, with tap-to-focus, to the given view.
- (void)addPreviewLayerToView:(UIView *)theView;
// Rotate the video preview to the status-bar orientation. Resize for the given view.
- (void)correctThePreviewOrientation:(UIView *)theView;
// Override.
// For removing observers.
- (void)dealloc;
// Remove current session from memory.
- (void)destroySession;
// Focus at the given point (in device space). Also lock exposure.
- (void)focusAtPoint:(CGPoint)thePoint;

// Designated initializer.
- (id)init;
// Create and assign the capture session.
- (void)setUpSession;
// Start the session. Asychronous.
- (void)startSession;
// Stop the capture session.
- (void)stopSession;
// Take a photo.
- (void)takePhoto;

// Return the capture-video orientation that matches the current interface orientation.
- (AVCaptureVideoOrientation)theCorrectCaptureVideoOrientation;

// Set focus, exposure and white balance to be continuous. (And reset points of interest.)
- (void)unlockFocus;


//testing
//- (void)addPreviewLayerToViewTesting:(UIView *)theView;
//- (void)removePreviewLayer;
//- (void)replacePreviewLayerWithNewOneToView:(UIView *)theView;
//- (void)testAddPreviewLayerToLayer:(CALayer *)theLayer;
@end
