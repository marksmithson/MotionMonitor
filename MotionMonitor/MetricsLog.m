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
//  MetricsLog.m
//  MotionMonitor
//
//  Created by Mark Smithson on 13/08/2011.
//  Copyright 2011,2012 Digital Morphosis Limited. All rights reserved.
//

#import "MetricsLog.h"

// interface for 'private' methods
@interface MetricsLog()
- (NSString *) logPath: (NSString *) name;
- (NSString *) stringFromFileSize:(unsigned long long)theSize;
@end

@implementation MetricsLog

@synthesize logName;

- (id) initWithName: (NSString *) name {
    self = [super init];

    if (self){
        self.logName = name;
        NSString *path = [self logPath:name];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]){
            if ([fileManager createFileAtPath:path contents:nil attributes:nil] == NO){
                NSLog(@"could not create file at path %@", path);
            }
        }
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        [fileHandle retain];
        [fileHandle seekToEndOfFile];
    }
    return self;
}

- (void) logData: (NSArray *)values {
    NSMutableString *stringData = [[NSMutableString alloc] init];
    
    for (NSString *element in values) {
        [stringData appendFormat:@"%@,", element];
    }
    
    [stringData deleteCharactersInRange:NSMakeRange([stringData length]-1, 1 )];  
    [stringData appendString:@"\n"];
    [fileHandle writeData:[stringData dataUsingEncoding: NSUTF8StringEncoding]];
    
    [stringData release];
}

- (void) flush {
    [fileHandle synchronizeFile];
}
- (void) reset {
    [fileHandle truncateFileAtOffset:0];
}

- (NSString *) logSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self logPath:self.logName];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:nil];
    if (attributes){
        unsigned long long size = [attributes fileSize];
        return [self stringFromFileSize: size];
    }
    return [NSString stringWithString: @"n/a"];
}

- (NSString *) filePath {
   return [self logPath:self.logName];
}

- (NSString *) stringFromFileSize:(unsigned long long) theSize
{
    if (theSize < 1023) {
        return([NSString stringWithFormat:@"%u bytes",theSize]);
    }
    float floatSize = theSize / 1024.0;
    if (floatSize < 1023){
        return([NSString stringWithFormat:@"%.2f Kb",floatSize]);
    }
    floatSize = floatSize / 1024;
    return([NSString stringWithFormat:@"%.2f Mb",floatSize]);
}

- (void) dealloc {
    [fileHandle closeFile];
    [fileHandle release];
    [logName release];
    [super dealloc];
}

#pragma mark - Utility Functions
- (NSString *) logPath: (NSString *) name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:name];
}

@end
