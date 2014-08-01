//
//  Created by Geoff Hom on 2/7/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKDelayedPhotosViewController.h"

#import "GGKDelayedPhotosModel.h"
#import "GGKMercyCamAppDelegate.h"
#import "NSNumber+GGKAdditions.h"
#import "NSString+GGKAdditions.h"
#import "UIView+GGKAdditions.h"

@implementation GGKDelayedPhotosViewController
- (void)takePhotoModelDidTakePhoto:(id)sender {
    [super takePhotoModelDidTakePhoto:sender];
    // If all photos taken, stop. Else, if still in shooting mode, take another photo. So, we can stop photo taking by changing the mode.
    if (self.delayedPhotosModel.numberOfPhotosTakenInteger >= self.delayedPhotosModel.numberOfPhotosToTakeInteger) {
        self.model.appMode = GGKAppModePlanning;
        [self updateUI];
    } else if (self.model.appMode == GGKAppModeShooting) {
        [self takePhoto];
    }
}
- (IBAction)handleCancelTimerTapped {
    [self stopOneSecondRepeatingTimer];
    self.model.appMode = GGKAppModePlanning;
    [self updateUI];
}
- (void)handleOneSecondTimerFired {
    // Each tick of this timer is 1 sec, so we can use that to show how many seconds have passed and determine if enough seconds have passed.
    self.delayedPhotosModel.numberOfSecondsWaitedInteger++;
    NSInteger theNumberOfSecondsWaitedInteger = self.delayedPhotosModel.numberOfSecondsWaitedInteger;
    self.numberOfSecondsWaitedLabel.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfSecondsWaitedInteger];
    [self.numberOfSecondsWaitedLabel setNeedsDisplay];
    if (theNumberOfSecondsWaitedInteger == self.delayedPhotosModel.numberOfSecondsToWaitInteger) {
        [self stopOneSecondRepeatingTimer];
        [self takePhoto];
    }
}
- (IBAction)handleTriggerButtonTapped:(id)sender {
    [super handleTriggerButtonTapped:sender];
    self.model.appMode = GGKAppModeShooting;
    self.delayedPhotosModel.numberOfPhotosTakenInteger = 0;
    [self updateUI];
    if (self.delayedPhotosModel.numberOfSecondsToWaitInteger == 0) {
        [self takePhoto];
    } else {
        [self startTimer];
    }
}
- (void)handleViewDidDisappearFromUser {
    [super handleViewDidDisappearFromUser];
    [self stopOneSecondRepeatingTimer];
    // Will stop photo taking.
    self.model.appMode = GGKAppModePlanning;
}
- (void)startTimer {
    self.delayedPhotosModel.numberOfSecondsWaitedInteger = 0;
    // Start a timer to count seconds.
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleOneSecondTimerFired) userInfo:nil repeats:YES];
    self.delayedPhotosModel.oneSecondRepeatingTimer = aTimer;
}
- (void)stopOneSecondRepeatingTimer {
    [self.delayedPhotosModel.oneSecondRepeatingTimer invalidate];
    self.delayedPhotosModel.oneSecondRepeatingTimer = nil;
}
- (void)takePhoto {
    [super takePhoto];
    self.delayedPhotosModel.numberOfPhotosTakenInteger++;
    NSInteger theNumberOfPhotosTakenInteger = self.delayedPhotosModel.numberOfPhotosTakenInteger;
    self.numberOfPhotosTakenLabel.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfPhotosTakenInteger];
    [self.numberOfPhotosTakenLabel setNeedsDisplay];
}
- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    // Ensure we have a valid value. Update model. Update view.
    NSInteger anOkayInteger;
    NSInteger theCurrentInteger = [theTextField.text integerValue];
    if (theTextField == self.numberOfSecondsToWaitTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:0 maximum:99];
        self.delayedPhotosModel.numberOfSecondsToWaitInteger = anOkayInteger;
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:1 maximum:99];
        self.delayedPhotosModel.numberOfPhotosToTakeInteger = anOkayInteger;
    }
    [self updateUI];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)updateUI {
    [super updateUI];
    // "Wait X second(s), then take"
    NSInteger theNumberOfSecondsToWaitInteger = self.delayedPhotosModel.numberOfSecondsToWaitInteger;
    self.numberOfSecondsToWaitTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfSecondsToWaitInteger];
    NSString *aSecondsString = [@"seconds" ggk_stringPerhapsWithoutS:theNumberOfSecondsToWaitInteger];
    self.secondsLabel.text = [NSString stringWithFormat:@"%@, then take", aSecondsString];
    //  "Y photo(s)."
    NSInteger theNumberOfPhotosToTakeInteger = self.delayedPhotosModel.numberOfPhotosToTakeInteger;
    self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfPhotosToTakeInteger];
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theNumberOfPhotosToTakeInteger];
    self.photosLabel.text = [NSString stringWithFormat:@"%@.", aPhotosString];
    // Update UI for current mode.
    NSArray *aTriggerButtonArray = @[self.bottomTriggerButton, self.leftTriggerButton, self.rightTriggerButton];
    NSArray *aTextFieldArray = @[self.numberOfPhotosToTakeTextField, self.numberOfSecondsToWaitTextField];
    if (self.model.appMode == GGKAppModePlanning) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = YES;
        }
        self.cancelTimerButton.enabled = NO;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = YES;
        }
        self.numberOfSecondsWaitedLabel.hidden = YES;
        self.numberOfPhotosTakenLabel.hidden = YES;
    } else if (self.model.appMode == GGKAppModeShooting) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = NO;
        }
        self.cancelTimerButton.enabled = YES;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = NO;
        }
        self.numberOfSecondsWaitedLabel.hidden = NO;
        self.numberOfSecondsWaitedLabel.text = @"0";
        self.numberOfPhotosTakenLabel.hidden = NO;
        self.numberOfPhotosTakenLabel.text = @"";
    }
}
- (void)updateLayoutForLandscape {
    [super updateLayoutForLandscape];
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 212;
}
- (void)updateLayoutForPortrait {
    [super updateLayoutForPortrait];
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 70;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    GGKMercyCamAppDelegate *theAppDelegate = (GGKMercyCamAppDelegate *)[UIApplication sharedApplication].delegate;
    self.delayedPhotosModel = theAppDelegate.delayedPhotosModel;
    self.model.appMode = GGKAppModePlanning;
    // Orientation-specific layout constraints.
    self.portraitOnlyLayoutConstraintArray = @[self.proxyRightTriggerButtonTopGapPortraitLayoutConstraint, self.tipLabelRightGapPortraitLayoutConstraint];
    // Proxy right button's top neighbor: top layout guide.
    NSDictionary *aDictionary = @{@"topGuide":self.topLayoutGuide, @"rightProxy":self.proxyRightTriggerButton, @"tipLabel":self.tipLabel};
    NSArray *anArray1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[rightProxy]" options:0 metrics:nil views:aDictionary];
    // Tip label's right neighbor: right proxy button.
    NSArray *anArray2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[tipLabel]-[rightProxy]" options:0 metrics:nil views:aDictionary];
    self.landscapeOnlyLayoutConstraintArray = @[anArray1[0], anArray2[0]];
}
@end