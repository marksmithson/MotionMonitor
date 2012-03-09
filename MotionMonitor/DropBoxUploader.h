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
//  DropBoxUploader.h
//  MotionMonitor
//
//  Created by Mark Smithson on 14/08/2011.
//  Copyright 2011,2012 Digital Morphosis Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DropboxSDK.h"

@interface DropBoxUploader : NSObject <DBRestClientDelegate>{
    DBRestClient* restClient;
}

- (void) uploadFile: (NSString *) name toPath:(NSString *) toPath fromPath:(NSString *) fromPath;

@end
