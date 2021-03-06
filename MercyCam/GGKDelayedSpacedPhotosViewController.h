//
//  Created by Geoff Hom on 5/6/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKAbstractPhotoViewController.h"

#import "GGKLongTermModel.h"
#import "GGKTimeUnitsTableViewController.h"

@class GGKDelayedSpacedPhotosModel, GGKLongTermModel;

@interface GGKDelayedSpacedPhotosViewController : GGKAbstractPhotoViewController <GGKLongTermModelDelegate, GGKTimeUnitsTableViewControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
// The gesture recognizer for detecting "when the user taps the screen" while allowing those taps through (e.g., on a button). (May not detect taps on the navigation bar or above.)
// To reset long-term timer.
@property (nonatomic, strong) UITapGestureRecognizer *anyTapOnScreenGestureRecognizer;
// Portrait-only constraint. Is set in storyboard to avoid compiler warnings.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraRollButtonTopGapPortraitLayoutConstraint;
// Width depends on device orientation/rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelTimerButtonWidthLayoutConstraint;
// User taps button. Popover appears. She selects item in popover and sees updated button.
// Button displaying the popover.
@property (nonatomic, strong) UIButton *currentPopoverButton;
// Same instance as in takePhotoModel. This way, we can access the subclass while maintaining type-checking.
@property (strong, nonatomic) GGKDelayedSpacedPhotosModel *delayedSpacedPhotosModel;
@property (strong, nonatomic) GGKLongTermModel *longTermModel;
// User taps trigger button. User sees label appear and increment with each photo taken. User implicitly understands when photos are taken, how many photos remain and how long it will take.
@property (nonatomic, weak) IBOutlet UILabel *numberOfPhotosTakenLabel;
// User taps trigger button. The number in the text field is how many photos are taken.
@property (weak, nonatomic) IBOutlet UITextField *numberOfPhotosToTakeTextField;
// User taps "Start timer." Sees label; it increments with each time unit. (If not seconds, increment to the tenth of a decimal.) User implicitly understands that the timer has started and can estimate when the first photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *numberOfTimeUnitsDelayedLabel;
// User taps "Start timer." Sees label; it increments with each time unit. (If not seconds, increment to the tenth of a decimal.) User implicitly understands that the timer has started and can estimate when the next photo (2nd–Nth) will be taken.
@property (nonatomic, weak) IBOutlet UILabel *numberOfTimeUnitsSpacedLabel;
// Number of time units to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToDelayTextField;
// Number of time units to wait between each photo.
@property (weak, nonatomic) IBOutlet UITextField *numberOfTimeUnitsToSpaceTextField;
// A transparent view for detecting "when the user taps the screen" but not letting those taps through.
// To undo the screen dim.
@property (nonatomic, strong) UIView *overlayView;
// In "Wait __, then take __ photo(s)," it's "photo(s)."
// Story: User sets number of photos. User may see "photo" or "photos."
@property (weak, nonatomic) IBOutlet UILabel *photosLabel;
// Width depends on device orientation/rotation.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proxyRightTriggerButtonWidthLayoutConstraint;
// User taps button. She can select seconds/minutes/hours/days/etc. from a popover. She taps selection and  button is updated.
// User sets number of time units to 1. She sees singular text for that time unit.
// The type of time unit to wait before taking the first photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitToDelayButton;
// User taps button. She can select seconds/minutes/hours/days/etc. from a popover. She taps selection and  button is updated.
// User sets number of time units to 1. She sees singular text for that time unit.
// The type of time unit to wait between each photo.
@property (weak, nonatomic) IBOutlet UIButton *timeUnitToSpaceButton;
// User taps "Start timer." Regardless of how long-term the timer parameters are, the user understands that the timer has started and is still working (because of the counter in seconds). She also understands when the next photo will be taken.
@property (nonatomic, weak) IBOutlet UILabel *timeUntilNextPhotoLabel;
// Portrait-only constraint. Is set in storyboard to avoid compiler warnings.
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerSettingsViewLeftGapPortraitLayoutConstraint;
// One of our gesture recognizers is for taps but also allows them through. Allow that recognizer to work with other recognizers (e.g., the tap-to-focus recognizer).
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
// Restart long-term timer.
- (void)handleATapOnBrightScreen:(UIGestureRecognizer *)theGestureRecognizer;
// Undo screen dim. Start new long-term timer.
- (void)handleATapOnDimScreen:(UIGestureRecognizer *)theGestureRecognizer;
// Dim the screen. 
- (void)longTermModelTimerDidFire:(id)sender;
// Override.
// Make a delayed, spaced-photos model.
- (GGKTakePhotoModel *)makeTakePhotoModel;
// Override.
// Prepare for time-unit selector.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
// Override.
// Now that we can: Show how many photos taken, including this one. Done here instead of takePhotoModelDidTakePhoto:, because latter didn't update screen in time.
- (void)takePhotoModelWillTakePhoto:(id)sender;
// Now that we can: Ensure we have a valid value.
- (void)textFieldDidEndEditing:(UITextField *)textField;
// Now that we can: Dismiss the keyboard.
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// Set the selected time unit, update UI and dismiss popover.
- (void)timeUnitsTableViewControllerDidSelectTimeUnit:(id)sender;
// Restore preview and screen brightness.
- (void)undoScreenDim;
// Override.
- (void)updateLayoutForLandscape;
// Override.
- (void)updateLayoutForPortrait;
// Override.
// Update delay waited or space waited. Update countdown label.
- (void)updateTimerUI;
// Override.
- (void)updateUI;
// Override.
- (void)viewDidLoad;
@end
