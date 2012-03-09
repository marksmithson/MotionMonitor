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
//  MotionService.m
//  MotionMonitor
//
//  Created by Mark Smithson on 14/08/2011.
//  Copyright 2011,2012 Digital Morphosis Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MotionService.h"
#import "MetricsLog.h"

// interface for 'private' methods
@interface MotionService()
    - (NSString *) logPath: (NSString *) name;
    - (void) logTime;
@end

@implementation MotionService

- (id)init
{
    self = [super init];
    if (self) {
        timeLog = [[MetricsLog alloc]initWithName:@"time.log"];
        accelerometerLog = [[MetricsLog alloc]initWithName:@"accelerometer.log"];
        gyroLog = [[MetricsLog alloc]initWithName:@"gyro.log"];
        attitudeLog = [[MetricsLog alloc]initWithName:@"attitude.log"];
        rotationLog = [[MetricsLog alloc]initWithName:@"rotation.log"];
        userAccelerationLog = [[MetricsLog alloc]initWithName:@"userAcceleration.log"];
        locationLog = [[MetricsLog alloc]initWithName:@"location.log"];
        headingLog = [[MetricsLog alloc]initWithName:@"heading.log"];
        
        motionManager = [[CMMotionManager alloc] init];
        motionManager.accelerometerUpdateInterval = 1.0/10.0;
        motionManager.gyroUpdateInterval = 1.0/10.0;
        motionManager.deviceMotionUpdateInterval = 1.0/10.0;
        locationManager = [[CLLocationManager alloc]init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.headingFilter = kCLHeadingFilterNone;
        //kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self;
        queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void) dealloc {
    [self stopLogging];
    [timeLog release];
    [accelerometerLog release];
    [gyroLog release];
    [attitudeLog release];
    [rotationLog release];
    [userAccelerationLog release];
    [locationLog release];
    [headingLog release];
    [motionManager release];
    [locationManager release];
    [queue release];
    [timeLogTimer release];
    [super dealloc];
}

#pragma mark - MotionService implementation
- (NSString *) capabilitiesAsString {
    NSMutableString *capabilities = [NSMutableString stringWithString:@"Location"];
    if (motionManager.accelerometerAvailable){
        [capabilities appendString:@", Accelerometer"];
    }
    if (motionManager.gyroAvailable){
        [capabilities appendString:@", Gyro"];
    }
    if (motionManager.deviceMotionAvailable){
        [capabilities appendString:@", Motion"];
    }
    if ([CLLocationManager headingAvailable]){
        [capabilities appendString:@", Heading"];
    }
    return [capabilities stringByAppendingString:@""];    
}

- (void) logTime {
    CFTimeInterval preTime = CACurrentMediaTime();
    NSDate *date = [NSDate date];
    CFTimeInterval time = CACurrentMediaTime();
    NSArray *data = [NSArray arrayWithObjects:
        [NSString stringWithFormat:@"%F", date.timeIntervalSinceReferenceDate],
        [NSString stringWithFormat:@"%F", preTime],
        [NSString stringWithFormat:@"%F", time],
        nil
    ];
    [timeLog logData:data];
}

- (void) startLoggingWithLocationAugmentaion: (BOOL) augmentation {
    [self logTime];
    
    // timer for logging time
    timeLogTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(logTime) userInfo:nil repeats:YES];
    [timeLogTimer retain];
    
    locationManager.desiredAccuracy = augmentation ? kCLLocationAccuracyBestForNavigation : kCLLocationAccuracyBest;
    if (motionManager.accelerometerAvailable){
        NSLog(@"Starting accelerometer");
        [motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
            if (error){
                NSLog(@"Accelerometer encountered an error %@", error);
                [motionManager stopAccelerometerUpdates];
            }
            else {
                NSArray *data = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%F", accelerometerData.timestamp],
                    [NSString stringWithFormat:@"%F", accelerometerData.acceleration.x],
                    [NSString stringWithFormat:@"%F", accelerometerData.acceleration.y],
                    [NSString stringWithFormat:@"%F", accelerometerData.acceleration.z],
                    nil
                ];
                [accelerometerLog logData:data];
            }
        }];   
    }
    if (motionManager.gyroAvailable) {
        NSLog(@"Starting gyro"); 
        [motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData *gyroData, NSError *error){
            if (error){
                NSLog(@"Gryo encountered an error %@", error); 
                [motionManager stopGyroUpdates];
            }
            else {
                NSArray *data = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%F", gyroData.timestamp],
                    [NSString stringWithFormat:@"%F", gyroData.rotationRate.x],
                    [NSString stringWithFormat:@"%F", gyroData.rotationRate.y],
                    [NSString stringWithFormat:@"%F", gyroData.rotationRate.z],
                    nil
                ];
                [gyroLog logData:data]; 
            }
        }];
    }

    if (motionManager.deviceMotionAvailable){
        NSLog(@"Starting motion");
        [motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion *motion, NSError *error){
            if (error){
                NSLog(@"Device Motion encountered an error %@", error);
                [motionManager stopDeviceMotionUpdates];
            }
            else {
                NSArray *attitudeData = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%F", motion.timestamp],
                    [NSString stringWithFormat:@"%F", motion.attitude.roll],
                    [NSString stringWithFormat:@"%F", motion.attitude.pitch],
                    [NSString stringWithFormat:@"%F", motion.attitude.yaw],
                    nil
                ];
                [attitudeLog logData:attitudeData];
                
                NSArray *rotationData = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%F", motion.timestamp],
                    [NSString stringWithFormat:@"%F", motion.rotationRate.x],
                    [NSString stringWithFormat:@"%F", motion.rotationRate.y],
                    [NSString stringWithFormat:@"%F", motion.rotationRate.z],
                    nil
                ];
                [rotationLog logData:rotationData];
                
                NSArray *userAccelerationData = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"%F", motion.timestamp],
                    [NSString stringWithFormat:@"%F", motion.userAcceleration.x],
                    [NSString stringWithFormat:@"%F", motion.userAcceleration.y],
                    [NSString stringWithFormat:@"%F", motion.userAcceleration.z],
                    nil
                ];
                [userAccelerationLog logData:userAccelerationData];
            }
        }];
    }
    
    NSLog(@"Starting Location Updates");
    [locationManager startUpdatingLocation];
    if ([CLLocationManager headingAvailable]){
        NSLog(@"Starting Heading Updates");
        [locationManager startUpdatingHeading];
    }
    
}
         
-(void) stopLogging {
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    [motionManager stopAccelerometerUpdates];
    [motionManager stopDeviceMotionUpdates];
    [motionManager stopGyroUpdates];
    [accelerometerLog flush];
    [gyroLog flush];
    [attitudeLog flush];
    [rotationLog flush];
    [userAccelerationLog flush];
    [locationLog flush];
    [headingLog flush];
    [timeLog flush];
    [timeLogTimer invalidate];
    [timeLogTimer release];
    timeLogTimer = nil;
}

- (MetricsLog *) getLogForIndex:(NSUInteger) index {
    switch (index) {
        case 0:
            return accelerometerLog;
        case 1:
            return gyroLog;
        case 2:
            return attitudeLog;
        case 3:
            return rotationLog;
        case 4:
            return userAccelerationLog;
        case 5:
            return locationLog;
        case 6:
            return headingLog;
        case 7:
            return timeLog;
        default:
            return nil;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *) newLocation fromLocation:(CLLocation *) oldLocation {
    if (newLocation){
    NSArray *locationData = [NSArray arrayWithObjects:
        [NSString stringWithFormat:@"%F", newLocation.timestamp.timeIntervalSinceReferenceDate],
        [NSString stringWithFormat:@"%F", newLocation.coordinate.latitude],
        [NSString stringWithFormat:@"%F", newLocation.coordinate.longitude],
        [NSString stringWithFormat:@"%F", newLocation.altitude],
        [NSString stringWithFormat:@"%F", newLocation.horizontalAccuracy],
        [NSString stringWithFormat:@"%F", newLocation.verticalAccuracy],
        [NSString stringWithFormat:@"%F", newLocation.speed],
        [NSString stringWithFormat:@"%F", newLocation.course],
        nil
    ];
    [locationLog logData:locationData];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading){
    NSArray *headingData = [NSArray arrayWithObjects:
        [NSString stringWithFormat:@"%F", newHeading.timestamp.timeIntervalSinceReferenceDate],
        [NSString stringWithFormat:@"%F", newHeading.magneticHeading],
        [NSString stringWithFormat:@"%F", newHeading.trueHeading],
        [NSString stringWithFormat:@"%F", newHeading.headingAccuracy],
        [NSString stringWithFormat:@"%F", newHeading.x],
        [NSString stringWithFormat:@"%F", newHeading.y],
        [NSString stringWithFormat:@"%F", newHeading.z],
        nil
    ];
    [headingLog logData:headingData];
    }
}
- (void) resetLogs {
    for (int i=0; i<8;i++){
        MetricsLog *log = [self getLogForIndex:i];
        [log reset];
    }
}

#pragma mark - Utility Functions
- (NSString *) logPath: (NSString *) logName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:logName];
}

@end
