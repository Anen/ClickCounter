//
//  UserDefaultsWrapper.m
//  ClickCounter
//
//  Created by Bastien on 1/1/16.
//  Copyright © 2016 Bastien. All rights reserved.
//

#import "UserDefaultsWrapper.h"

#import "LaunchAtLoginController.h"

@implementation UserDefaultsWrapper

NSUserDefaults* m_Prefs;
BOOL m_DisplayGlobal;
BOOL m_LaunchAtStartup;
NSDate* m_ResetDate;
NSNumber* m_SessionLeftCount;
NSNumber* m_SessionRightCount;
NSNumber* m_SessionKeyCount;
NSNumber* m_GlobalLeftCount;
NSNumber* m_GlobalRightCount;
NSNumber* m_GlobalKeyCount;

// Keys for NSUserDefaults
NSString* const k_DisplayGlobal           = @"DisplayGlobal";
NSString* const k_LaunchAtStartup         = @"LaunchAtStartup";
NSString* const k_OnKeyDown               = @"OnKeyDown";
NSString* const k_OnKeyDownSession        = @"OnKeyDownSession";
NSString* const k_OnLeftMouseDown         = @"OnLeftMouseDown";
NSString* const k_OnLeftMouseDownSession  = @"OnLeftMouseDownSession";
NSString* const k_OnRightMouseDown        = @"OnRightMouseDown";
NSString* const k_OnRightMouseDownSession = @"OnRightMouseDownSession";
NSString* const k_ResetDate               = @"ResetDate";

+(id)sharedWrapper {
    static UserDefaultsWrapper *sharedUserDefaultsWrapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUserDefaultsWrapper = [[self alloc] init];
    });
    return (sharedUserDefaultsWrapper);
}

-(id)init {
    if (self = [super init]) {
        m_Prefs = [NSUserDefaults standardUserDefaults];
        
        // Init user default
        NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInteger:0], k_OnKeyDown,
                                              [NSNumber numberWithInteger:0], k_OnLeftMouseDown,
                                              [NSNumber numberWithInteger:0], k_OnRightMouseDown,
                                              [NSNumber numberWithInteger:0], k_OnKeyDownSession,
                                              [NSNumber numberWithInteger:0], k_OnLeftMouseDownSession,
                                              [NSNumber numberWithInteger:0], k_OnRightMouseDownSession,
                                              @NO, k_DisplayGlobal,
                                              @NO, k_LaunchAtStartup,
                                              [NSDate date], k_ResetDate,
                                              nil];
        [m_Prefs registerDefaults:userDefaultsDefaults];
        
        m_DisplayGlobal = [m_Prefs boolForKey:k_DisplayGlobal];
        m_ResetDate     = [m_Prefs objectForKey:k_ResetDate];
        
        // Initialize with the real state, in case it was changed from outside the app.
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
        m_LaunchAtStartup = [launchController launchAtLogin];
        [m_Prefs setBool:m_LaunchAtStartup forKey:k_LaunchAtStartup];
        
        m_SessionLeftCount  = [m_Prefs objectForKey:k_OnLeftMouseDownSession];
        m_SessionRightCount = [m_Prefs objectForKey:k_OnRightMouseDownSession];
        m_SessionKeyCount   = [m_Prefs objectForKey:k_OnKeyDownSession];
        m_GlobalLeftCount   = [m_Prefs objectForKey:k_OnLeftMouseDown];
        m_GlobalRightCount  = [m_Prefs objectForKey:k_OnRightMouseDown];
        m_GlobalKeyCount    = [m_Prefs objectForKey:k_OnKeyDown];
    }
    
    return (self);
}

-(NSString*)getCountAsStringFor:(int)counter {
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    nf.numberStyle = NSNumberFormatterDecimalStyle;
    
    switch (counter) {
        case counter_SessionLeft: {
            return ([nf stringFromNumber:m_SessionLeftCount]);
        }
        case counter_SessionRight: {
            return ([nf stringFromNumber:m_SessionRightCount]);
        }
        case counter_SessionKey: {
            return ([nf stringFromNumber:m_SessionKeyCount]);
        }
        case counter_GlobalLeft: {
            return ([nf stringFromNumber:m_GlobalLeftCount]);
        }
        case counter_GlobalRight: {
            return ([nf stringFromNumber:m_GlobalRightCount]);
        }
        case counter_GlobalKey: {
            return ([nf stringFromNumber:m_GlobalKeyCount]);
        }
        default:
            break;
    }
    return (nil);
}

-(BOOL)getDisplayGlobal {
    return (m_DisplayGlobal);
}

-(BOOL)getLaunchAtStartup {
    return (m_LaunchAtStartup);
}

-(NSString*)getResetDateAsString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm:ss"];
    return ([dateFormatter stringFromDate:m_ResetDate]);
}

//
//
//
-(void)incrementLeftCountsByOne {
    m_SessionLeftCount = [NSNumber numberWithInt:[m_SessionLeftCount intValue] + 1];
    m_GlobalLeftCount = [NSNumber numberWithInt:[m_GlobalLeftCount intValue] + 1];
    
    [m_Prefs setObject:m_SessionLeftCount forKey:k_OnLeftMouseDownSession];
    [m_Prefs setObject:m_GlobalLeftCount forKey:k_OnLeftMouseDown];
}
//
//
//
-(void)incrementRightCountsByOne {
    m_SessionRightCount = [NSNumber numberWithInt:[m_SessionRightCount intValue] + 1];
    m_GlobalRightCount = [NSNumber numberWithInt:[m_GlobalRightCount intValue] + 1];
    
    [m_Prefs setObject:m_SessionRightCount forKey:k_OnRightMouseDownSession];
    [m_Prefs setObject:m_GlobalRightCount forKey:k_OnRightMouseDown];
}

//
//
//
-(void)incrementKeyCountsByOne {
    m_SessionKeyCount = [NSNumber numberWithInt:[m_SessionKeyCount intValue] + 1];
    m_GlobalKeyCount = [NSNumber numberWithInt:[m_GlobalKeyCount intValue] + 1];
    
    [m_Prefs setObject:m_SessionKeyCount forKey:k_OnKeyDownSession];
    [m_Prefs setObject:m_GlobalKeyCount forKey:k_OnKeyDown];
}

//
//
//
-(void)setDisplayGlobal:(BOOL)state {
    m_DisplayGlobal = state;
    [m_Prefs setBool:m_DisplayGlobal forKey:k_DisplayGlobal];
}

//
//
//
-(void)setLaunchAtStartup:(BOOL)state {
    m_LaunchAtStartup = state;
    [m_Prefs setBool:m_LaunchAtStartup forKey:k_LaunchAtStartup];
}

//
// Function: UserDefaultsWrapper::setResetDateAsToday
//
-(void)setResetDateAsToday {
    m_ResetDate = [NSDate date];
    [m_Prefs setObject:m_ResetDate forKey:k_ResetDate];
}

//
// Function: UserDefaultsWrapper::setSessionCountsToZero
//
-(void)setSessionCountsToZero {
    m_SessionLeftCount = [NSNumber numberWithInteger:0];
    m_SessionRightCount = [NSNumber numberWithInteger:0];
    m_SessionKeyCount = [NSNumber numberWithInteger:0];
    
    [m_Prefs setObject:m_SessionLeftCount forKey:k_OnLeftMouseDownSession];
    [m_Prefs setObject:m_SessionRightCount forKey:k_OnRightMouseDownSession];
    [m_Prefs setObject:m_SessionKeyCount forKey:k_OnKeyDownSession];
}

@end
