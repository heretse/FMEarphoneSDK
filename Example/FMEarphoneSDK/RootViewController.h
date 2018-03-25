//
//  RootViewController.h
//  FMEarphoneSDK
//
//  Created by winston_hsieh@gemteks.com on 11/08/2017.
//  Copyright (c) 2017 heretse@gmail.com. All rights reserved.
//

@import UIKit;

@interface RootViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *powerUpButton;
@property (weak, nonatomic) IBOutlet UIButton *powerDownButton;
@property (weak, nonatomic) IBOutlet UIButton *seekForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *seekBackwardButton;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property(nonatomic) uint32_t totalBytesRead;
@property(nonatomic, strong) IBOutlet UILabel *receivedBytesCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *receivedBytesTextView;

@end
