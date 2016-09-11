//
//  AppDelegate.m
//  ClickCounter
//
//  Created by Bastien on 5/3/14.
//  Copyright (c) 2014 Bastien. All rights reserved.
//

#import "AppDelegate.h"

#import "LaunchAtLoginController.h"
#import "class/UserDefaultsWrapper.h"

@interface AppDelegate ()
                                        // Private methods

typedef NS_ENUM(int, iconState) {
    iconState_Waiting  = 0,
    iconState_Clicked  = 1,
    iconState_Disabled = 2
};

@end

@implementation AppDelegate

BOOL m_AccessibilityEnabled;
NSEvent* m_EventMonitor;
NSStatusItem* m_StatusItem;
PreferencesWindowController* m_Pwc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    m_StatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    m_StatusItem.menu = self.theMenu;
    
    // Test accessibility
    // Only change when the app is restarted ??
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    m_AccessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    
    [self setBackgroundIcon:iconState_Waiting];
    
                                        // Add local monitors
    m_EventMonitor =
        [NSEvent addLocalMonitorForEventsMatchingMask:(NSLeftMouseDownMask)
                                              handler:^(NSEvent *incomingEvent) {
                                                  [self onLeftMouseDown:incomingEvent];
                                                  return incomingEvent;
                                              }];
    m_EventMonitor =
        [NSEvent addLocalMonitorForEventsMatchingMask:(NSRightMouseDownMask /*| NSOtherMouseDownMask*/)
                                              handler:^(NSEvent *incomingEvent) {
                                                  [self onRightMouseDown:incomingEvent];
                                                  return incomingEvent;
                                              }];
    m_EventMonitor =
        [NSEvent addLocalMonitorForEventsMatchingMask:(NSKeyDownMask)
                                              handler:^(NSEvent *incomingEvent) {
                                                  [self onKeyDown:incomingEvent];
                                                  return incomingEvent;
                                              }];
                                        // Add global monitors
    m_EventMonitor =
        [NSEvent addGlobalMonitorForEventsMatchingMask:(NSLeftMouseDownMask)
                                               handler:^(NSEvent *incomingEvent) {
                                                   [self onLeftMouseDown:incomingEvent];
                                               }];
    m_EventMonitor =
        [NSEvent addGlobalMonitorForEventsMatchingMask:(NSRightMouseDownMask /*| NSOtherMouseDownMask*/)
                                               handler:^(NSEvent *incomingEvent) {
                                                   [self onRightMouseDown:incomingEvent];
                                               }];
    m_EventMonitor =
        [NSEvent addGlobalMonitorForEventsMatchingMask:(NSKeyDownMask)
                                               handler:^(NSEvent *incomingEvent) {
                                                   [self onKeyDown:incomingEvent];
                                               }];

                                        // Init interface
    [self updateValues];
}


-(void)onKeyDown:(NSEvent*)incomingEvent {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    [udw incrementKeyCountsByOne];
    
    [self setBackgroundIcon:iconState_Clicked];
    [self updateValues];
}

-(void)onLeftMouseDown:(NSEvent*)incomingEvent {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    [udw incrementLeftCountsByOne];
    
    [self setBackgroundIcon:iconState_Clicked];
    [self updateValues];
}

-(void)onRightMouseDown:(NSEvent*)incomingEvent {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    [udw incrementRightCountsByOne];
    
    [self setBackgroundIcon:iconState_Clicked];
    [self updateValues];
}
    //NSString *daemonPath = [[NSBundle mainBundle] pathForResource:@"relaunch" ofType:nil];
    
    /*[NSTask launchedTaskWithLaunchPath:daemonPath
                             arguments:[NSArray arrayWithObjects:
                                        [[NSBundle mainBundle] bundlePath],
                                        [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]],
                                        nil]];
    */
- (void)relaunchAfterDelay:(float)seconds {
    NSTask *task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-c"];
    [args addObject:[NSString stringWithFormat:@"sleep %f; open \"%@\"", seconds, [[NSBundle mainBundle] bundlePath]]];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
        
    [NSApp terminate:nil];
}

-(void)setBackgroundWaiting {
    [self setBackgroundIcon:iconState_Waiting];
}

-(void)setBackgroundIcon:(iconState)state {
    switch (state) {
        case iconState_Waiting: {
            
            //  TODO : invert the test
            if (m_AccessibilityEnabled) {
                m_StatusItem.image = [NSImage imageNamed:@"bat_waiting.png"];
            } else {
                m_StatusItem.image = [NSImage imageNamed:@"bat_no_access.png"];
            }
            
            break;
        }
        case iconState_Clicked: {
            m_StatusItem.image = [NSImage imageNamed:@"bat_clicked.png"];
            
            // Go back to Waiting state after 0.1 second
            [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(setBackgroundWaiting)
                                           userInfo:nil
                                            repeats:NO];
            
            break;
        }
        case iconState_Disabled: {
            m_StatusItem.image = [NSImage imageNamed:@"bat_disabled.png"];
            break;
        }
        default:
            break;
    }
}

-(IBAction)showPreferencesWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    if (m_Pwc == nil) {
        m_Pwc = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindow"];
    }
    [m_Pwc showWindow:self];
}

-(void)updateValues {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    NSString *keyTitle;
    NSString *leftTitle;
    NSString *rightTitle;
    
    if ([udw getDisplayGlobal]) {
        keyTitle = [NSString stringWithFormat:@"Key: %@", [udw getCountAsStringFor:counter_GlobalKey]];
        leftTitle = [NSString stringWithFormat:@"Left: %@", [udw getCountAsStringFor:counter_GlobalLeft]];
        rightTitle = [NSString stringWithFormat:@"Right: %@",[udw getCountAsStringFor:counter_GlobalRight]];
    } else {
        keyTitle = [NSString stringWithFormat:@"Key: %@", [udw getCountAsStringFor:counter_SessionKey]];
        leftTitle = [NSString stringWithFormat:@"Left: %@", [udw getCountAsStringFor:counter_SessionLeft]];
        rightTitle = [NSString stringWithFormat:@"Right: %@", [udw getCountAsStringFor:counter_SessionRight]];
    }

    [_theMenuKeyCounter setTitle:keyTitle];
    [_theMenuLeftClickCounter setTitle:leftTitle];
    [_theMenuRightClickCounter setTitle:rightTitle];

    [m_Pwc updatePreferencesValues];
}

@end
