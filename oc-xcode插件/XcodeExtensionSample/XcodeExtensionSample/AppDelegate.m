//
//  AppDelegate.m
//  XcodeExtensionSample
//
//  Created by Aron Ruan on 2022/4/14.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSLog(@"applicationDidFinishLaunching");
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
    NSLog(@"applicationWillTerminate");
    
}


@end
