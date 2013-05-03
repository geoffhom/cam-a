//
//  GGKMercyCameraViewController.m
//  GGK Cam A
//
//  Created by Geoff Hom on 2/5/13.
//  Copyright (c) 2013 Geoff Hom. All rights reserved.
//

#import "GGKMercyCameraViewController.h"
#import "GGKTakeDelayedPhotosViewController.h"

//BOOL GGKCreateLaunchImages = YES;
BOOL GGKCreateLaunchImages = NO;

@interface GGKMercyCameraViewController ()

// Story: The overall orientation (device/status-bar) is checked against the orientation of this app's UI. The user sees the UI in the correct orientation.
// Whether the landscape view is currently showing.
@property (nonatomic, assign) BOOL isShowingLandscapeView;

// For playing sound.
@property (strong, nonatomic) GGKSoundModel *soundModel;

// UIViewController override.
- (void)awakeFromNib;

// Story: When the user should see the UI in landscape, she does.
- (void)updateLayoutForLandscape;

// Story: When the user should see the UI in portrait, she does.
- (void)updateLayoutForPortrait;

// UIViewController override.
- (void)viewDidLoad;

// UIViewController override.
- (void)viewWillAppear:(BOOL)animated;

// UIViewController override.
// Story: Whether user rotates device in the app, or from the home screen, this method will be called. User sees UI in correct orientation.
- (void)viewWillLayoutSubviews;

@end

@implementation GGKMercyCameraViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    NSLog(@"MCVC aFN");
    self.isShowingLandscapeView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonSound
{
    [self.soundModel playButtonTapSound];
}

- (IBAction)rateOrReview
{
    NSLog(@"rateOrReview");
    
    // Go to the App Store, to this app and the section for "Ratings and Reviews." Note that the app ID won't work prior to the app's first release, but one can test by using the ID of an app that has already been released.
    // App ID for Color Fever: 585564245
    // App ID for Mercy Camera!: 637772676
    // App ID for Perfect Potty: 615088461
    // App ID for Text Memory: 490464898
    NSString *theAppIDString = @"637772676";
    NSString *theITunesURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", theAppIDString];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:theITunesURL]];
}

- (void)updateLayoutForLandscape
{
    CGSize aSize = self.hiLabel.frame.size;
    self.hiLabel.frame = CGRectMake(92, 30, aSize.width, aSize.height);
    
    CGFloat anX1 = 20;
    aSize = self.takeAPhotoButton.frame.size;
    self.takeAPhotoButton.frame = CGRectMake(anX1, 101, aSize.width, aSize.height);
    
    aSize = self.exampleLabel.frame.size;
    self.exampleLabel.frame = CGRectMake(472, 131, aSize.width, aSize.height);
    
    CGFloat anX2 = 353;
    aSize = self.takeAPhotoExampleLabel.frame.size;
    self.takeAPhotoExampleLabel.frame = CGRectMake(anX2, 166, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosButton.frame.size;
    self.takeDelayedPhotosButton.frame = CGRectMake(anX1, 331, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosExampleLabel.frame.size;
    self.takeDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 363, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosButton.frame.size;
    self.takeAdvancedDelayedPhotosButton.frame = CGRectMake(anX1, 501, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosExampleLabel.frame.size;
    self.takeAdvancedDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 511, aSize.width, aSize.height);
    
    UIFont *aFont = [UIFont boldSystemFontOfSize:12];
    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.rateThisAppButton.titleLabel.attributedText];
    [aMutableAttributedString removeAttribute:NSFontAttributeName range:NSMakeRange(0, aMutableAttributedString.length)];
    [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
    self.rateThisAppButton.titleLabel.attributedText = aMutableAttributedString;
//    self.rateThisAppButton.titleLabel.font = aFont;
    CGFloat anX3 = 831;
    aSize = CGSizeMake(183, 60);
    self.rateThisAppButton.frame = CGRectMake(anX3, 516, aSize.width, aSize.height);
    
    self.helpTheCreatorsButton.titleLabel.font = aFont;
    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 615, aSize.width, aSize.height);
    
    
//    UIFont *aFont = [UIFont boldSystemFontOfSize:18];
//    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.rateThisAppButton.titleLabel.attributedText];
//    [aMutableAttributedString removeAttribute:NSFontAttributeName range:NSMakeRange(0, aMutableAttributedString.length)];
//    [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
//    self.rateThisAppButton.titleLabel.attributedText = aMutableAttributedString;
//    CGFloat anX3 = 511;
//    aSize = CGSizeMake(237, 60);
//    self.rateThisAppButton.frame = CGRectMake(anX3, 743, aSize.width, aSize.height);
//    
//    self.helpTheCreatorsButton.titleLabel.font = aFont;
//    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 851, aSize.width, aSize.height);
}

- (void)updateLayoutForPortrait
{
    CGSize aSize = self.hiLabel.frame.size;
    self.hiLabel.frame = CGRectMake(92, 50, aSize.width, aSize.height);
    
    CGFloat anX1 = 20;
    aSize = self.takeAPhotoButton.frame.size;
    self.takeAPhotoButton.frame = CGRectMake(anX1, 120, aSize.width, aSize.height);
    
    aSize = self.exampleLabel.frame.size;
    self.exampleLabel.frame = CGRectMake(472, 151, aSize.width, aSize.height);
    
    CGFloat anX2 = 353;
    aSize = self.takeAPhotoExampleLabel.frame.size;
    self.takeAPhotoExampleLabel.frame = CGRectMake(anX2, 186, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosButton.frame.size;
    self.takeDelayedPhotosButton.frame = CGRectMake(anX1, 350, aSize.width, aSize.height);
    
    aSize = self.takeDelayedPhotosExampleLabel.frame.size;
    self.takeDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 382, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosButton.frame.size;
    self.takeAdvancedDelayedPhotosButton.frame = CGRectMake(anX1, 520, aSize.width, aSize.height);
    
    aSize = self.takeAdvancedDelayedPhotosExampleLabel.frame.size;
    self.takeAdvancedDelayedPhotosExampleLabel.frame = CGRectMake(anX2, 530, aSize.width, aSize.height);
    
    UIFont *aFont = [UIFont boldSystemFontOfSize:32];
    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.rateThisAppButton.titleLabel.attributedText];
    [aMutableAttributedString removeAttribute:NSFontAttributeName range:NSMakeRange(0, aMutableAttributedString.length)];
    [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
    self.rateThisAppButton.titleLabel.attributedText = [aMutableAttributedString copy];
    CGFloat anX3 = 511;
    aSize = CGSizeMake(237, 60);
    
    // rotate back and forth: this doesn't update right
//    self.rateThisAppButton.titleLabel.attributedText = [aMutableAttributedString copy];
////    self.rateThisAppButton.frame = CGRectMake(anX3, 743, aSize.width, aSize.height);
//    self.rateThisAppButton.frame = CGRectMake(511, 743, 237, 60);
    
    // rotate back and forth: this updates right; why?
//    self.rateThisAppButton.frame = CGRectMake(anX3, 743, aSize.width, aSize.height);
    self.rateThisAppButton.frame = CGRectMake(511, 743, 237, 60);
    self.rateThisAppButton.titleLabel.attributedText = [aMutableAttributedString copy];
    
    
    self.helpTheCreatorsButton.titleLabel.font = aFont;
    self.helpTheCreatorsButton.frame = CGRectMake(anX3, 851, aSize.width, aSize.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"MCVC vdL");
    
    // Make UI blank so we can make launch images via screenshot.
    if (GGKCreateLaunchImages) {
        
        self.navigationItem.title = @"";
        for (UIView *aSubView in self.view.subviews) {
            
            aSubView.hidden = YES;
        }
    } else {
        
        self.soundModel = [[GGKSoundModel alloc] init];
        [self updateLayoutForPortrait];
    }
}

//testing; do I need to do my rotation changes in didlayoutsubviews vs willlayoutsubviews?
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    NSLog(@"viewDidLayoutSubviews");
    
    // Using status-bar orientation, not device orientation. Seems to work.
    UIInterfaceOrientation theInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(theInterfaceOrientation) && !self.isShowingLandscapeView) {
        
        [self updateLayoutForLandscape];
        self.isShowingLandscapeView = YES;
    } else if (UIInterfaceOrientationIsPortrait(theInterfaceOrientation) && self.isShowingLandscapeView) {
        
        [self updateLayoutForPortrait];
        self.isShowingLandscapeView = NO;
        
        //testing
//        UIFont *aFont = [UIFont boldSystemFontOfSize:8];
//        NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.rateThisAppButton.titleLabel.attributedText];
//        [aMutableAttributedString removeAttribute:NSFontAttributeName range:NSMakeRange(0, aMutableAttributedString.length)];
//        [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
//        self.rateThisAppButton.titleLabel.attributedText = [aMutableAttributedString copy];
//        CGFloat anX3 = 511;
//        CGSize aSize = CGSizeMake(237, 60);
//        self.rateThisAppButton.frame = CGRectMake(anX3, 743, aSize.width, aSize.height);
    }
    
//    //testing
//    UIFont *aFont = [UIFont boldSystemFontOfSize:8];
//    NSMutableAttributedString *aMutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.rateThisAppButton.titleLabel.attributedText];
//    [aMutableAttributedString removeAttribute:NSFontAttributeName range:NSMakeRange(0, aMutableAttributedString.length)];
//    [aMutableAttributedString addAttribute:NSFontAttributeName value:aFont range:NSMakeRange(0, aMutableAttributedString.length)];
//    self.rateThisAppButton.titleLabel.attributedText = [aMutableAttributedString copy];
//    CGFloat anX3 = 511;
//    CGSize aSize = CGSizeMake(237, 60);
//    self.rateThisAppButton.frame = CGRectMake(anX3, 743, aSize.width, aSize.height);
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    
    // move to sub-method
    // Update labels in case they changed.
    
    NSNumber *takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber = [[NSUserDefaults standardUserDefaults] objectForKey:GGKTakeDelayedPhotosNumberOfSecondsToInitiallyWaitKeyString];
    if (takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber == nil) {
        
        takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber = @(GGKTakeDelayedPhotosDefaultNumberOfSecondsToInitiallyWaitInteger);
    }
    NSNumber *takeDelayedPhotosNumberOfPhotosNumber = [[NSUserDefaults standardUserDefaults] objectForKey:GGKTakeDelayedPhotosNumberOfPhotosKeyString];
    if (takeDelayedPhotosNumberOfPhotosNumber == nil) {
        
        takeDelayedPhotosNumberOfPhotosNumber = @(GGKTakeDelayedPhotosDefaultNumberOfPhotosInteger);
    }
    
    NSString *aSecondsString = @"seconds";
    if ([takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber intValue] == 1) {
        
        aSecondsString = @"second";
    }
    NSString *aPhotosString = @"photos";
    if ([takeDelayedPhotosNumberOfPhotosNumber intValue] == 1) {
        
        aPhotosString = @"photo";
    }
    self.takeDelayedPhotosExampleLabel.text = [NSString stringWithFormat:@"\"Wait %@ %@,\nthen take %@ %@.\"", takeDelayedPhotosNumberOfSecondsToInitiallyWaitNumber, aSecondsString, takeDelayedPhotosNumberOfPhotosNumber, aPhotosString];
}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    
//    //    NSLog(@"MCVC vWLS");
//    
//    // Using status-bar orientation, not device orientation. Seems to work. 
//    UIInterfaceOrientation theInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (UIInterfaceOrientationIsLandscape(theInterfaceOrientation) && !self.isShowingLandscapeView) {
//        
////        NSLog(@"MCVC vWLS theInterfaceOrientation set things to landscape");
//        [self updateLayoutForLandscape];
//        self.isShowingLandscapeView = YES;
//    } else if (UIInterfaceOrientationIsPortrait(theInterfaceOrientation) && self.isShowingLandscapeView) {
//        
////        NSLog(@"MCVC vWLS theInterfaceOrientation set things to portrait");
//        [self updateLayoutForPortrait];
//        self.isShowingLandscapeView = NO;
//    }
//}

@end
