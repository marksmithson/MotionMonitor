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
//  DropBoxUploader.m
//  MotionMonitor
//
//  Created by Mark Smithson on 14/08/2011.
//  Copyright 2011,2012 Digital Morphosis Limited. All rights reserved.
//

#import "DropBoxUploader.h"

@interface DropBoxUploader()
- (DBRestClient *) restClient;
@end
@implementation DropBoxUploader

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (void) uploadFile: (NSString *) name toPath:(NSString *) toPath fromPath:(NSString *) fromPath{
    [[self restClient] uploadFile:name toPath:toPath fromPath:fromPath];
}

- (DBRestClient*) restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath {
    NSLog(@"Upload completed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Uploaded" message:[NSString stringWithFormat: @"File Uploaded %@", destPath] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress 
           forFile:(NSString*)destPath from:(NSString*)srcPath{
    NSLog(@"Upload progress %f", progress);
    
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error{
    NSLog(@"Upload failed with error %@", error.description);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error" message:@"There was a problem uploading the file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
