//
//  GGKSimpleDelayedPhotoViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKTakeDelayedPhotosViewController.h"

#import "GGKTimeUnits.h"
#import "NSString+GGKAdditions.h"

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger = 3;

const NSInteger GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger = 2;

NSString *GGKTakeDelayedPhotosNumberOfPhotosKeyString = @"Take delayed photos: number of photos";

NSString *GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString = @"Take delayed photos: number of seconds to initially wait";

@interface GGKTakeDelayedPhotosViewController ()

// Number of photos to take for a given push of the shutter.
@property (nonatomic, assign) NSInteger numberOfPhotosRemainingToTake;

// Number of seconds to wait before taking first photo.
@property (nonatomic, assign) CGFloat numberOfSecondsToInitiallyWait;


// So, show the user how many seconds have passed. If enough have passed, start taking photos.
//- (void)handleOneSecondTimerFired;


// Start taking photos, immediately.
//- (void)startTakingPhotos;


@end

@implementation GGKTakeDelayedPhotosViewController

//- (void)captureManagerDidTakePhoto:(id)sender
//{
//    [super captureManagerDidTakePhoto:sender];
//    
//    if (self.numberOfPhotosRemainingToTake > 0) {
//        
//        [self takePhoto];
//    }
//}

- (void)getSavedTimerSettings
{
    [super getSavedTimerSettings];

    self.numberOfTimeUnitsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
    self.timeUnitForTheInitialWaitTimeUnit = GGKTimeUnitSeconds;
    self.numberOfPhotosToTakeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfPhotosToTakeKeyString];
    self.numberOfTimeUnitsBetweenPhotosInteger = 0;
    self.timeUnitBetweenPhotosTimeUnit = GGKTimeUnitSeconds;
}

//- (void)handleOneSecondTimerFired
//{
//    [super handleOneSecondTimerFired];
//    
////    // Initial wait: Show how many seconds have passed.
////    NSInteger theNumberOfSecondsToInitiallyWaitInteger = [[NSUserDefaults standardUserDefaults] integerForKey:self.numberOfTimeUnitsToInitiallyWaitKeyString];
////    NSInteger theNumberOfSecondsAlreadyWaitedInteger;
////    if (self.initialWaitTimer == nil) {
////        
////        theNumberOfSecondsAlreadyWaitedInteger = theNumberOfSecondsToInitiallyWaitInteger;
////    } else {
////        
////        CGFloat theNumberOfSecondsRemainingFloat = [self.initialWaitTimer.fireDate timeIntervalSinceNow];
////        theNumberOfSecondsAlreadyWaitedInteger = theNumberOfSecondsToInitiallyWaitInteger - theNumberOfSecondsRemainingFloat;
////    }
////    self.numberOfTimeUnitsInitiallyWaitedLabel.text = [NSString stringWithFormat:@"%d", theNumberOfSecondsAlreadyWaitedInteger];
//}


//- (void)handleOneSecondTimerFired
//{
//    NSNumber *theSecondsWaitedNumber = @([self.numberOfTimeUnitsInitiallyWaitedLabel.text integerValue] + 1);
//    self.numberOfTimeUnitsInitiallyWaitedLabel.text = [theSecondsWaitedNumber stringValue];
//    if ([theSecondsWaitedNumber floatValue] >= self.numberOfSecondsToInitiallyWait) {
//        
//        [self.oneSecondRepeatingTimer invalidate];
//        self.oneSecondRepeatingTimer = nil;
//        [self startTakingPhotos];
//    }
//}

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosNumberOfTimeUnitsToInitiallyWaitKeyPathString]) {
        
        self.numberOfTimeUnitsToInitiallyWaitTextField.text = [NSString stringWithFormat:@"%d", self.numberOfTimeUnitsToInitiallyWaitInteger];
        
        // "second(s), then take"
        NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:self.numberOfTimeUnitsToInitiallyWaitInteger];
        self.secondsLabel.text = [NSString stringWithFormat:@"%@, then take", aSecondsString];
    } else if ([theKeyPath isEqualToString:GGKTakeDelayedPhotosNumberOfPhotosToTakeKeyPathString]) {
        
        self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%d", self.numberOfPhotosToTakeInteger];
        
        // "photo(s)."
        NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:self.numberOfPhotosToTakeInteger];
        self.afterNumberOfPhotosTextFieldLabel.text = [NSString stringWithFormat:@"%@.", aPhotosString];
    } else {
        
        [super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    }
}

//- (void)startTakingPhotos
//{
//    if (self.numberOfPhotosRemainingToTake > 0) {
//        
//        [self takePhoto];
//    }
//}

//- (void)takePhoto
//{
//    [super takePhoto];
//    
////    NSLog(@"TDPVC takePhoto called");
//    self.numberOfPhotosRemainingToTake -= 1;
//    
//    // Show number of photos taken.
//    if (self.numberOfPhotosTakenLabel.hidden) {
//        
//        self.numberOfPhotosTakenLabel.text = @"0";
//        self.numberOfPhotosTakenLabel.hidden = NO;
//    }
//    NSNumber *theNumberOfPhotosTakenNumber = @([self.numberOfPhotosTakenLabel.text integerValue] + 1);
//    self.numberOfPhotosTakenLabel.text = [theNumberOfPhotosTakenNumber stringValue];
//}

- (void)updateLayoutForLandscape
{
    [super updateLayoutForLandscape];
    
    CGPoint aPoint = self.videoPreviewView.frame.origin;
    self.videoPreviewView.frame = CGRectMake(aPoint.x, aPoint.y, 804, 603);
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    self.focusLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.focusLabel.frame = CGRectMake(765, 8, 113, 50);
    
    CGFloat anX1 = 886;
    CGFloat aWidth = 130;
    self.startTimerButton.frame = CGRectMake(anX1, 8, aWidth, 451);
    
    self.cancelTimerButton.frame = CGRectMake(916, 466, 100, 60);
    
    self.cameraRollButton.frame = CGRectMake(anX1, 566, aWidth, aWidth);
}

- (void)updateLayoutForPortrait
{
    [super updateLayoutForPortrait];
    
    CGPoint aPoint = self.videoPreviewView.frame.origin;
    self.videoPreviewView.frame = CGRectMake(aPoint.x, aPoint.y, 644, 859);
    [self.captureManager correctThePreviewOrientation:self.videoPreviewView];
    
    self.focusLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.focusLabel.frame = CGRectMake(659, 8, 94, 38);
    
    CGFloat anX1 = 652;
    CGFloat aWidth = 108;
    self.startTimerButton.frame = CGRectMake(anX1, 54, aWidth, 674);
    
    self.cancelTimerButton.frame = CGRectMake(672, 735, 88, 60);
    
    self.cameraRollButton.frame = CGRectMake(anX1, 844, aWidth, aWidth);
}

//- (void)updateTimerLabels
//{
//    // Super doesn't help here, so won't call it.
//
//    // Initial wait: Show how many seconds have passed.
////    self.numberOfTimeUnitsInitiallyWaitedLabel.text = [NSString stringWithFormat:@"%d", self.numberOfSecondsPassedInteger];
//}

- (void)viewDidLoad
{    
    [super viewDidLoad];
        
    self.maximumNumberOfTimeUnitsToInitiallyWaitInteger = 99;
    self.maximumNumberOfPhotosInteger = 99;
    self.maximumNumberOfTimeUnitsBetweenPhotosInteger = 99;
    
    // Set keys.
    self.numberOfTimeUnitsToInitiallyWaitKeyString = GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString;
    self.timeUnitForInitialWaitKeyString = nil;
    self.numberOfPhotosToTakeKeyString = GGKTakeDelayedPhotosNumberOfPhotosKeyString;
    self.numberOfTimeUnitsBetweenPhotosKeyString = nil;
    self.timeUnitBetweenPhotosKeyString = nil;
    
    [self getSavedTimerSettings];
}

@end
