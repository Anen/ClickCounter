//
//  PreferencesWindowController.m
//  ClickCounter
//
//  Created by Bastien on 10/4/15.
//  Copyright © 2015 Bastien. All rights reserved.
//

#import "PreferencesWindowController.h"

#import "LaunchAtLoginController.h"
#import "UserDefaultsWrapper.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (void)awakeFromNib {
    NSLog(@"%s", __FUNCTION__);
    
    // Test accessibility
    // Only change when the app is restarted ??
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    
                   //  TODO : invert the test
    if (!accessibilityEnabled) {
        [_thePreferencesSessionKeyCounter setTextColor:[NSColor redColor]];
        [_thePreferencesGlobalKeyCounter setTextColor:[NSColor redColor]];
        
        NSString* const help = @"To enable key counters, Click Counter needs to be allowed to control your computer. Please add Click Counter in the Accessibility list under System Preferences > Security & Privacy. Then restart Click Counter.";
        [_thePreferencesSessionKeyCounter setToolTip:help];
        [_thePreferencesGlobalKeyCounter setToolTip:help];
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Warning"
                                         defaultButton:@"Open System Preferences"
                                       alternateButton:@"Ok"
                                           otherButton:nil
                             informativeTextWithFormat:help];
         
         [alert beginSheetModalForWindow:[self window]
                           modalDelegate:self
                          didEndSelector:@selector(toggleEnableKeyCountDidEnd:returnCode:contextInfo:)
                             contextInfo:nil];
    }
    
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    [_thePreferencesLaunchAtStartup setState:[udw getLaunchAtStartup]];
    
    if ([udw getDisplayGlobal]) {
        [_thePreferencesDisplay selectCellAtRow:1 column:0];
    } else {
        [_thePreferencesDisplay selectCellAtRow:0 column:0];
    }

    [self updatePreferencesValues];
    [self updateResetDate];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSLog(@"%s", __FUNCTION__);
}

//
// resetSession
//
//
-(IBAction)resetSession:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Alert"
                                     defaultButton:@"Reset"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"This will reset session counts."];
    
    [alert beginSheetModalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:@selector(resetSessionDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

-(void)resetSessionDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    switch (returnCode) {
        case NSOKButton: {
            UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
            [udw setResetDateAsToday];
            [udw setSessionCountsToZero];
            
            [self updatePreferencesValues];
            [self updateResetDate];
            break;
        }
        case NSCancelButton: {
            NSLog(@"Cancel");
            break;
        }
        default:
            break;
    }
}

-(IBAction)toogleDisplayGlobal:(id)sender {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    [udw setDisplayGlobal:YES];
}

-(IBAction)toogleDisplaySession:(id)sender {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    [udw setDisplayGlobal:NO];
}

- (void)toggleEnableKeyCountDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    switch (returnCode) {
        case NSOKButton: {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:@"/System/Library/PreferencePanes/Security.prefPane"]];
            break;
        }
        case NSCancelButton: {
            NSLog(@"Ok");
            break;
        }
        default:
            break;
    }
}

-(IBAction)toggleLanchAtStartup:(id)sender {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    [udw setLaunchAtStartup:[sender state]];
    
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:[sender state]];
}

-(void)updatePreferencesValues {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    
    [_thePreferencesSessionLeftClickCounter setStringValue:[NSString stringWithFormat:@"Left: %@", [udw getCountAsStringFor:counter_SessionLeft]]];
    [_thePreferencesSessionRightClickCounter setStringValue:[NSString stringWithFormat:@"Right: %@", [udw getCountAsStringFor:counter_SessionRight]]];
    [_thePreferencesSessionKeyCounter setStringValue:[NSString stringWithFormat:@"Key: %@" , [udw getCountAsStringFor:counter_SessionKey]]];
    
    [_thePreferencesGlobalLeftClickCounter setStringValue:[NSString stringWithFormat:@"Left: %@", [udw getCountAsStringFor:counter_GlobalLeft]]];
    [_thePreferencesGlobalRightClickCounter setStringValue:[NSString stringWithFormat:@"Right: %@", [udw getCountAsStringFor:counter_GlobalRight]]];
    [_thePreferencesGlobalKeyCounter setStringValue:[NSString stringWithFormat:@"Key: %@" , [udw getCountAsStringFor:counter_GlobalKey]]];
}

-(void)updateResetDate {
    UserDefaultsWrapper *udw = [UserDefaultsWrapper sharedWrapper];
    [_thePreferencesResetDate setStringValue:[NSString stringWithFormat:@"Last reset on: %@", [udw getResetDateAsString]]];
}


@end
