//
//  AppDelegate.h
//  ClickCounter
//
//  Created by Bastien on 5/3/14.
//  Copyright (c) 2014 Bastien. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "PreferencesWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet NSMenu* theMenu;
@property (strong) IBOutlet NSMenuItem* theMenuLeftClickCounter;
@property (strong) IBOutlet NSMenuItem* theMenuRightClickCounter;
@property (strong) IBOutlet NSMenuItem* theMenuKeyCounter;

-(IBAction)showPreferencesWindow:(id)sender;

@end
