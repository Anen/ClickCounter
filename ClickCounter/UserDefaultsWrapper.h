//
//  UserDefaultsWrapper.h
//  ClickCounter
//
//  Created by Bastien on 1/1/16.
//  Copyright © 2016 Bastien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsWrapper : NSObject

+(id)sharedWrapper;

// Getters
-(NSString*)getCountAsStringFor:(int)counter;
-(BOOL)getDisplayGlobal;
-(BOOL)getLaunchAtStartup;
-(NSString*)getResetDateAsString;

// Setters
-(void)incrementLeftCountsByOne;
-(void)incrementRightCountsByOne;
-(void)incrementKeyCountsByOne;
-(void)setDisplayGlobal:(BOOL)state ;
-(void)setLaunchAtStartup:(BOOL)state;
-(void)setResetDateAsToday;
-(void)setSessionCountsToZero;

// Enum
typedef NS_ENUM(int, counter) {
    counter_SessionLeft  = 0,
    counter_SessionRight = 1,
    counter_SessionKey   = 2,
    counter_GlobalLeft   = 3,
    counter_GlobalRight  = 4,
    counter_GlobalKey    = 5
};

@end

