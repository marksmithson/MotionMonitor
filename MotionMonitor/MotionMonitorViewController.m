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
//  MotionMonitorViewController.m
//  MotionMonitor
//
//  Created by Mark Smithson on 13/08/2011.
//  Copyright 2011,2012 Digital Morphosis Limited. All rights reserved.
//

#import "MotionMonitorViewController.h"
#import "DropboxSDK.h"
#import "DropBoxUploader.h"
@interface MotionMonitorViewController()
- (void) uploadFiles;
@end
@implementation MotionMonitorViewController
@synthesize fileTable;
@synthesize augmentedSwitch;
@synthesize capabilitiesLabel;
@synthesize startRecordingButton;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Table View Data Source Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"TableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil){
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:tableIdentifier ]autorelease];
    }
    
    NSUInteger row = [indexPath row];
    MetricsLog *log = [motionService getLogForIndex: row];
    
    if (log){
        cell.textLabel.text = [NSString stringWithFormat:@"%@", log.logName];
        cell.detailTextLabel.text = [log logSize];
    }
    
    return cell;
}

- (void) refreshFiles {
    [fileTable reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"View Load");
    [super viewDidLoad];
    motionService = [[MotionService alloc]init];
    uploader = [[DropBoxUploader alloc]init];
    capabilitiesLabel.text = [NSString stringWithFormat:@"Capabilities: %@",[motionService capabilitiesAsString]];
}

- (void)viewDidUnload
{
    [self setCapabilitiesLabel:nil];
    [self setAugmentedSwitch:nil];
    [self setFileTable:nil];
    [self setStartRecordingButton:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated{
    fileRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshFiles) userInfo:nil repeats:YES];
    [fileRefreshTimer retain];
    [super viewWillAppear:animated];
}
- (void) viewWillDisappear:(BOOL)animated {
    [fileRefreshTimer release];
    fileRefreshTimer = nil;
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [fileRefreshTimer release];
    [capabilitiesLabel release];
    [augmentedSwitch release];
    [fileTable release];
    [motionService release];
    [uploader release];
    [startRecordingButton release];
    [super dealloc];
}
- (IBAction)testEvent:(id)sender {
}

- (IBAction)sendData:(id)sender {
    // dropbox login
    DBSession *dbSession = [DBSession sharedSession];
    if (![dbSession isLinked]){
        DBLoginController *controller = [[DBLoginController new] autorelease];
        controller.delegate = self;
        [controller presentFromController:self];    
    }
    else {
        [self uploadFiles];
    }
}
- (void)loginControllerDidLogin:(DBLoginController*)controller{
    [self uploadFiles];
}
- (void)loginControllerDidCancel:(DBLoginController*)controller{
    NSLog(@"Dropbox Login was cancelled");
}
- (void) uploadFiles {
    //upload a file
    for (int i=0; i<8; i++) {
        MetricsLog *log = [motionService getLogForIndex:i];
        NSString *name = log.logName;
        NSLog(@"Starting upload of %@", name);
        NSString *toPath = [NSString stringWithFormat:@"/MotionMonitor", name];
        [uploader uploadFile:name toPath:toPath fromPath:log.filePath];
    }
}

- (IBAction)startRecording:(id)sender {
    NSString *label = [startRecordingButton titleForState:UIControlStateNormal];
    if ([label isEqualToString: @"Record"]){
        NSLog(@"Start Recording");
        [motionService startLoggingWithLocationAugmentaion: augmentedSwitch.selected];
        [startRecordingButton setTitle:@"Stop" forState:UIControlStateNormal];
        augmentedSwitch.enabled = NO;
    }
    else {
        NSLog(@"Stop Recording");
        [motionService stopLogging];
        [startRecordingButton setTitle:@"Record" forState:UIControlStateNormal];    
        augmentedSwitch.enabled = YES;
    }
}

- (IBAction)resetLogs:(id)sender {
    [motionService resetLogs];
}

@end
