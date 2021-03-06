//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKDelayedSpacedPhotosViewController.h"

#import "GGKDelayedSpacedPhotosModel.h"
#import "GGKLongTermModel.h"
#import "GGKUtilities.h"
#import "NSDate+GGKAdditions.h"
#import "NSNumber+GGKAdditions.h"
#import "NSString+GGKAdditions.h"

@implementation GGKDelayedSpacedPhotosViewController
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (void)handleATapOnBrightScreen:(UIGestureRecognizer *)theGestureRecognizer {
    // Stop previous long-term timer.
    [self.longTermModel stopTimer];
    [self.longTermModel startTimer];
}
- (void)handleATapOnDimScreen:(UIGestureRecognizer *)theGestureRecognizer {
    [self undoScreenDim];
    self.overlayView.hidden = YES;
    [self.longTermModel startTimer];
    self.anyTapOnScreenGestureRecognizer.enabled = YES;
}
- (void)longTermModelTimerDidFire:(id)sender {
    UIScreen *aScreen = [UIScreen mainScreen];
    self.longTermModel.previousBrightnessFloat = aScreen.brightness;
    aScreen.brightness = 0.0;
    self.cameraPreviewView.hidden = YES;
    // Stop detecting taps for bright screen. Start detecting taps for dim screen.
    self.anyTapOnScreenGestureRecognizer.enabled = NO;
    CGSize theViewSize = self.view.frame.size;
    self.overlayView.frame = CGRectMake(0, 0, theViewSize.width, theViewSize.height);
    self.overlayView.hidden = NO;
}
- (GGKTakePhotoModel *)makeTakePhotoModel {
    GGKDelayedSpacedPhotosModel *theDelayedSpacedPhotosModel = [[GGKDelayedSpacedPhotosModel alloc] init];
    return theDelayedSpacedPhotosModel;
}
- (void)prepareForSegue:(UIStoryboardSegue *)theSegue sender:(id)theSender {
    if ([theSegue.identifier hasPrefix:@"ShowTimeUnitsSelector"]) {
        // Retain popover controller, to dismiss later.
        self.currentPopoverController = [(UIStoryboardPopoverSegue *)theSegue popoverController];
        GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)self.currentPopoverController.contentViewController;
        aTimeUnitsTableViewController.delegate = self;
        // Set the current time unit.
        GGKTimeUnit theCurrentTimeUnit;
        if (theSender == self.timeUnitToDelayButton) {
            theCurrentTimeUnit = self.delayedSpacedPhotosModel.delayTimeUnit;
        } else if (theSender == self.timeUnitToSpaceButton) {
            theCurrentTimeUnit = self.delayedSpacedPhotosModel.spaceTimeUnit;
        }
        aTimeUnitsTableViewController.currentTimeUnit = theCurrentTimeUnit;
        // Note which button was tapped, to update later.
        self.currentPopoverButton = theSender;
    } else {
        [super prepareForSegue:theSegue sender:theSender];
    }
}
- (void)takePhotoModelWillTakePhoto:(id)sender {
    [super takePhotoModelWillTakePhoto:sender];
    self.numberOfPhotosTakenLabel.text = [NSString stringWithFormat:@"%ld", (long)self.takePhotoModel.numberOfPhotosTakenInteger + 1];
    [self.numberOfPhotosTakenLabel setNeedsDisplay];
}
- (void)textFieldDidEndEditing:(UITextField *)theTextField {
    // Ensure we have a valid value. Update model. Update view.
    NSInteger anOkayInteger;
    NSInteger theCurrentInteger = [theTextField.text integerValue];
    if (theTextField == self.numberOfTimeUnitsToDelayTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:0 maximum:999];
        self.delayedSpacedPhotosModel.numberOfTimeUnitsToDelayInteger = anOkayInteger;
    } else if (theTextField == self.numberOfPhotosToTakeTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:1 maximum:999];
        self.delayedSpacedPhotosModel.numberOfPhotosToTakeInteger = anOkayInteger;
    } else if (theTextField == self.numberOfTimeUnitsToSpaceTextField) {
        anOkayInteger = [NSNumber ggk_integerBoundedByRange:theCurrentInteger minimum:0 maximum:999];
        self.delayedSpacedPhotosModel.numberOfTimeUnitsToSpaceInteger = anOkayInteger;
    }
    [self updateUI];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender {
    // Set time unit.
    GGKTimeUnitsTableViewController *aTimeUnitsTableViewController = (GGKTimeUnitsTableViewController *)sender;
    GGKTimeUnit theCurrentTimeUnit = aTimeUnitsTableViewController.currentTimeUnit;
    if (self.currentPopoverButton == self.timeUnitToDelayButton) {
        self.delayedSpacedPhotosModel.delayTimeUnit = theCurrentTimeUnit;
    } else if (self.currentPopoverButton == self.timeUnitToSpaceButton) {
        self.delayedSpacedPhotosModel.spaceTimeUnit = theCurrentTimeUnit;
    }
    [self updateUI];
    [self.currentPopoverController dismissPopoverAnimated:YES];
}
- (void)undoScreenDim {
    self.cameraPreviewView.hidden = NO;
    [UIScreen mainScreen].brightness = self.longTermModel.previousBrightnessFloat;
}
- (void)updateLayoutForLandscape {
    [super updateLayoutForLandscape];
    self.cancelTimerButtonWidthLayoutConstraint.constant = 174;
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 217;
}
- (void)updateLayoutForPortrait {
    [super updateLayoutForPortrait];
    self.cancelTimerButtonWidthLayoutConstraint.constant = 66;
    self.proxyRightTriggerButtonWidthLayoutConstraint.constant = 80;
}
- (void)updateTimerUI {
    [super updateTimerUI];
    NSString *aString;
    // It's usually space waited, unless 0 photos taken and delay > 0.
    if (self.takePhotoModel.numberOfPhotosTakenInteger == 0 && self.delayedSpacedPhotosModel.numberOfTimeUnitsToDelayInteger > 0) {
        if (self.delayedSpacedPhotosModel.delayTimeUnit == GGKTimeUnitSeconds) {
            aString = [NSString stringWithFormat:@"%ld", (long)self.takePhotoModel.numberOfSecondsWaitedInteger];
        } else {
            CGFloat theNumberOfTimeUnitsWaitedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.takePhotoModel.numberOfSecondsWaitedInteger timeUnit:self.delayedSpacedPhotosModel.delayTimeUnit];
            aString = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsWaitedFloat];
        }
        self.numberOfTimeUnitsDelayedLabel.text = aString;
    } else {
        if (self.delayedSpacedPhotosModel.spaceTimeUnit == GGKTimeUnitSeconds) {
            aString = [NSString stringWithFormat:@"%ld", (long)self.takePhotoModel.numberOfSecondsWaitedInteger];
        } else {
            CGFloat theNumberOfTimeUnitsWaitedFloat = [GGKTimeUnits numberOfTimeUnitsInTimeInterval:self.takePhotoModel.numberOfSecondsWaitedInteger timeUnit:self.delayedSpacedPhotosModel.spaceTimeUnit];
            aString = [NSString stringWithFormat:@"%.1f", theNumberOfTimeUnitsWaitedFloat];
        }
        self.numberOfTimeUnitsSpacedLabel.text = aString;
    }
    // Countdown label.
    // Time-to-wait may be 0, in which time passed will be greater.
    NSInteger theNumberOfSecondsUntilNextPhotoInteger = MAX([self.takePhotoModel numberOfSecondsToWaitInteger], self.takePhotoModel.numberOfSecondsWaitedInteger) - self.takePhotoModel.numberOfSecondsWaitedInteger;
    aString = [NSDate ggk_dayHourMinuteSecondStringForTimeInterval:theNumberOfSecondsUntilNextPhotoInteger];
    self.timeUntilNextPhotoLabel.text = [NSString stringWithFormat:@"Next photo: %@", aString];
}
- (void)updateUI {
    [super updateUI];
    // Wait __, then take"
    NSInteger theNumberOfTimeUnitsToDelayInteger = self.delayedSpacedPhotosModel.numberOfTimeUnitsToDelayInteger;
    self.numberOfTimeUnitsToDelayTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfTimeUnitsToDelayInteger];
    [GGKTimeUnits setTitleForButton:self.timeUnitToDelayButton withTimeUnit:self.delayedSpacedPhotosModel.delayTimeUnit ofPlurality:self.delayedSpacedPhotosModel.numberOfTimeUnitsToDelayInteger];
    // "__ photos, with"
    NSInteger theNumberOfPhotosToTakeInteger = self.delayedSpacedPhotosModel.numberOfPhotosToTakeInteger;
    self.numberOfPhotosToTakeTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfPhotosToTakeInteger];
    NSString *aPhotosString = [@"photos" ggk_stringPerhapsWithoutS:theNumberOfPhotosToTakeInteger];
    self.photosLabel.text = [NSString stringWithFormat:@"%@ with", aPhotosString];
    // "__ between each photo."
    NSInteger theNumberOfTimeUnitsToSpaceInteger = self.delayedSpacedPhotosModel.numberOfTimeUnitsToSpaceInteger;
    self.numberOfTimeUnitsToSpaceTextField.text = [NSString stringWithFormat:@"%ld", (long)theNumberOfTimeUnitsToSpaceInteger];
    [GGKTimeUnits setTitleForButton:self.timeUnitToSpaceButton withTimeUnit:self.delayedSpacedPhotosModel.spaceTimeUnit ofPlurality:self.delayedSpacedPhotosModel.numberOfTimeUnitsToSpaceInteger];
    // Update UI for current mode.
    NSArray *aTriggerButtonArray = @[self.bottomTriggerButton, self.leftTriggerButton, self.rightTriggerButton];
    NSArray *aTextFieldArray = @[self.numberOfPhotosToTakeTextField, self.numberOfTimeUnitsToDelayTextField, self.numberOfTimeUnitsToSpaceTextField];
    NSArray *aTimeUnitButtonArray = @[self.timeUnitToDelayButton, self.timeUnitToSpaceButton];
    NSArray *aLabelArray = @[self.numberOfPhotosTakenLabel, self.numberOfTimeUnitsDelayedLabel, self.numberOfTimeUnitsSpacedLabel, self.timeUntilNextPhotoLabel];
    if (self.takePhotoModel.mode == GGKTakePhotoModelModePlanning) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = YES;
        }
        self.cancelTimerButton.enabled = NO;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = YES;
        }
        for (UIButton *aButton in aTimeUnitButtonArray) {
            aButton.enabled = YES;
        }
        for (UILabel *aLabel in aLabelArray) {
            aLabel.hidden = YES;
        }
        // Disable long-term dimming.
        if (self.cameraPreviewView.hidden) {
            [self undoScreenDim];
        }
        self.anyTapOnScreenGestureRecognizer.enabled = NO;
        [self.longTermModel stopTimer];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    } else if (self.takePhotoModel.mode == GGKTakePhotoModelModeShooting) {
        for (UIButton *aButton in aTriggerButtonArray) {
            aButton.enabled = NO;
        }
        self.cancelTimerButton.enabled = YES;
        for (UITextField *aTextField in aTextFieldArray) {
            aTextField.enabled = NO;
        }
        for (UIButton *aButton in aTimeUnitButtonArray) {
            aButton.enabled = NO;
        }
        for (UILabel *aLabel in aLabelArray) {
            aLabel.hidden = NO;
        }
        self.numberOfTimeUnitsDelayedLabel.text = @"0";
        self.numberOfPhotosTakenLabel.text = @"0";
        self.numberOfTimeUnitsSpacedLabel.text = @"0";
        self.timeUntilNextPhotoLabel.text = @"Next photo:";
        // Enable long-term dimming.
        // Detect taps to reset long-term timer but also allow those taps through.
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [self.longTermModel startTimer];
        self.anyTapOnScreenGestureRecognizer.enabled = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delayedSpacedPhotosModel = (GGKDelayedSpacedPhotosModel *)self.takePhotoModel;
    self.longTermModel = [[GGKLongTermModel alloc] init];
    self.longTermModel.delegate = self;
    // Orientation-specific layout constraints.
    self.portraitOnlyLayoutConstraintArray = @[self.cameraRollButtonTopGapPortraitLayoutConstraint, self.timerSettingsViewLeftGapPortraitLayoutConstraint];
    // Camera roll's top neighbor: top layout guide.
    NSDictionary *aDictionary = @{@"topGuide":self.topLayoutGuide, @"cameraRollButton":self.cameraRollButton, @"timerSettingsView":self.timerSettingsView};
    NSArray *anArray1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[cameraRollButton]" options:0 metrics:nil views:aDictionary];
    // Camera roll's right neighbor: timer-settings view.
    NSArray *anArray2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[cameraRollButton]-[timerSettingsView]" options:0 metrics:nil views:aDictionary];
    self.landscapeOnlyLayoutConstraintArray = @[anArray1[0], anArray2[0]];
    // Add gesture recognizer to reset long-term timer when screen tapped. Disabled for now.
    UITapGestureRecognizer *aTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleATapOnBrightScreen:)];
    aTapGestureRecognizer.cancelsTouchesInView = NO;
    aTapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:aTapGestureRecognizer];
    aTapGestureRecognizer.delegate = self;
    self.anyTapOnScreenGestureRecognizer = aTapGestureRecognizer;
    // Add overlay view, inactive/hidden for now.
    UIView *anOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
    aTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleATapOnDimScreen:)];
    [anOverlayView addGestureRecognizer:aTapGestureRecognizer];
    anOverlayView.hidden = YES;
    [self.view addSubview:anOverlayView];
    self.overlayView = anOverlayView;
}
@end
