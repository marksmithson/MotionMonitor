/*
This file is part of MotionMonitor.

MotionMonitor is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MotionMonitor is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MotionMonitor.  If not, see <http://www.gnu.org/licenses/>.
*/
//
//  MotionMonitorViewController.h
//  MotionMonitor
//
//  Created by Mark Smithson on 13/08/2011.
//  Copyright 2011,2012 Digital Morphosis Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionService.h"
#import "DropBoxUploader.h"

@interface MotionMonitorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,DBLoginControllerDelegate> {
    UISwitch *augmentedSwitch;
    UILabel *capabilitiesLabel;
    UIButton *startRecordingButton;
    UITableView *fileTable;
    MotionService *motionService;
    NSTimer *fileRefreshTimer;
    DropBoxUploader *uploader;
}

@property (nonatomic, retain) IBOutlet UITableView *fileTable;

@property (nonatomic, retain) IBOutlet UISwitch *augmentedSwitch;

@property (nonatomic, retain) IBOutlet UILabel *capabilitiesLabel;
@property (nonatomic, retain) IBOutlet UIButton *startRecordingButton;
- (IBAction)testEvent:(id)sender;
- (IBAction)sendData:(id)sender;
- (IBAction)startRecording:(id)sender;
- (IBAction)resetLogs:(id)sender;
@end
