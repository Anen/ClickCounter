//
//  PreferencesWindowController.h
//  ClickCounter
//
//  Created by Bastien on 10/4/15.
//  Copyright © 2015 Bastien. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController

@property (strong) IBOutlet NSTextField* thePreferencesGlobalLeftClickCounter;
@property (strong) IBOutlet NSTextField* thePreferencesGlobalRightClickCounter;
@property (strong) IBOutlet NSTextField* thePreferencesGlobalKeyCounter;
@property (strong) IBOutlet NSTextField* thePreferencesSessionLeftClickCounter;
@property (strong) IBOutlet NSTextField* thePreferencesSessionRightClickCounter;
@property (strong) IBOutlet NSTextField* thePreferencesSessionKeyCounter;
@property (strong) IBOutlet NSTextField* thePreferencesResetDate;

@property (strong) IBOutlet NSButton* thePreferencesLaunchAtStartup;
@property (strong) IBOutlet NSButton* thePreferencesResetSession;
@property (strong) IBOutlet NSMatrix* thePreferencesDisplay;

-(IBAction)resetSession:(id)sender;
-(IBAction)toogleDisplaySession:(id)sender;
-(IBAction)toggleLanchAtStartup:(id)sender;

-(void)updatePreferencesValues;

@end
