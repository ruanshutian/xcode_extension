//
//  AppDelegate.m
//  aronTool
//
//  Created by Aron Ruan on 2022/5/7.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property(weak) IBOutlet NSWindow *window;

@property(weak) IBOutlet NSButton *llvmStyle;
@property(weak) IBOutlet NSButton *googleStyle;
@property(weak) IBOutlet NSButton *chromiumStyle;
@property(weak) IBOutlet NSButton *mozillaStyle;
@property(weak) IBOutlet NSButton *webkitStyle;
@property(weak) IBOutlet NSButton *customStyle;

@property(weak) IBOutlet NSPathControl *primaryPathControl;
@property(weak) IBOutlet NSPathControl *secondaryPathControl;

@end

@implementation AppDelegate

NSUserDefaults* defaults = nil;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
//    NSLog(@" applicationDidFinishLaunching ");
    
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"XcodeClangFormat"];
    NSString* style = [defaults stringForKey:@"style"];
    NSLog(@" style = %@",style);
    if (!style) {
        style = @"llvm";
    }
    if ([style isEqualToString:@"custom"]) {
        self.customStyle.state = NSControlStateValueOn;
    } else if ([style isEqualToString:@"google"]) {
        self.googleStyle.state = NSControlStateValueOn;
    } else if ([style isEqualToString:@"chromium"]) {
        self.chromiumStyle.state = NSControlStateValueOn;
    } else if ([style isEqualToString:@"mozilla"]) {
        self.mozillaStyle.state = NSControlStateValueOn;
    } else if ([style isEqualToString:@"webkit"]) {
        self.webkitStyle.state = NSControlStateValueOn;
    } else {
        self.llvmStyle.state = NSControlStateValueOn;
    }
    
    NSData* bookmark = [defaults dataForKey:@"file"];
    NSLog(@" bookmark = %@",bookmark);
    if (bookmark) {
        NSError* error = nil;
        BOOL stale = NO;
        NSURL* url = [NSURL URLByResolvingBookmarkData:bookmark options:NSURLBookmarkResolutionWithSecurityScope | NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&stale error:&error];
        
        if (url) {
            // Regenerate the bookmark, so that the extension can read a valid bookmark after a
            // system restart.
            [url startAccessingSecurityScopedResource];
            NSData* regularBookmark = [url bookmarkDataWithOptions:0 includingResourceValuesForKeys:nil relativeToURL:nil error:nil];
            [url stopAccessingSecurityScopedResource];
            [defaults setObject:regularBookmark forKey:@"regularBookmark"];

            self.primaryPathControl.URL = url;
            self.secondaryPathControl.URL = url;
        } else {
            // Remove the bookmark value from the storage
            [defaults setNilValueForKey:@"regularBookmark"];
        }
        [defaults synchronize];
    }
//    NSString* book = [defaults stringForKey:@"regularBookmark"];
//    NSLog(@"book = %@",book);
}

- (BOOL)application:(NSApplication*)application openFile:(NSString*)filename {
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", filename]];
    return [self selectURL:url];
//    return YES;
}

- (IBAction)chooseStyle:(id)sender {
//    NSLog(@" chooseStyle ");
    NSString *style = nil;
    if (sender == self.customStyle) {
        NSLog(@" custom ");
        style = @"custom";
    } else if (sender == self.googleStyle) {
        NSLog(@" google ");
        style = @"google";
    } else if (sender == self.chromiumStyle) {
        NSLog(@" chromium ");
        style = @"chromium";
    } else if (sender == self.mozillaStyle) {
        NSLog(@" mozilla ");
        style = @"mozilla";
    } else if (sender == self.webkitStyle) {
        NSLog(@" webkit ");
        style = @"webkit";
    } else {
        NSLog(@" llvm ");
        style = @"llvm";
    }
  [defaults setValue:@"1" forKey:@"ismodify"];
  [defaults setValue:style forKey:@"style"];
  [defaults synchronize];
}

- (void)pathControl:(NSPathControl *)pathControl
    willDisplayOpenPanel:(NSOpenPanel *)openPanel {
    NSLog(@"pathControl 1");
  openPanel.title = @"Choose custom .clang-format file";
  openPanel.canChooseFiles = YES;
  openPanel.canChooseDirectories = YES;
  openPanel.showsHiddenFiles = YES;
  openPanel.treatsFilePackagesAsDirectories = YES;
  openPanel.allowsMultipleSelection = NO;
}

- (NSURL *)findClangFormatFileFromURL:(NSURL *)url {
  NSNumber *isDirectory;
  BOOL success = [url getResourceValue:&isDirectory
                                forKey:NSURLIsDirectoryKey
                                 error:nil];
//    NSLog(@"isDirectory = %ld",isDirectory);
  if (success && [isDirectory boolValue]) {
    return [url URLByAppendingPathComponent:@".clang-format"];
  } else {
    return url;
  }
}

- (NSData *)tryCreateBookmarkFromURL:(NSURL *)url {
  // Create a bookmark and store into defaults.
  NSError *error = nil;
  return [url bookmarkDataWithOptions:
                  NSURLBookmarkCreationWithSecurityScope |
                  NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess
       includingResourceValuesForKeys:nil
                        relativeToURL:nil
                                error:&error];
}

- (NSDragOperation)pathControl:(NSPathControl *)pathControl
                  validateDrop:(id<NSDraggingInfo>)info {
    NSLog(@"pathControl 2");
  NSPasteboard *pastboard = [info draggingPasteboard];
  NSURL *url =
      [self findClangFormatFileFromURL:[NSURL URLFromPasteboard:pastboard]];
  NSData *bookmark = [self tryCreateBookmarkFromURL:url];
  if (bookmark) {
    return NSDragOperationCopy;
  } else {
    return NSDragOperationNone;
  }
}

- (IBAction)selectFile:(id)sender {
    NSURL* url = [self findClangFormatFileFromURL:self.primaryPathControl.URL];
    NSLog(@"url = %@",url);
    [self selectURL:url];
    //
    NSString*urlString = [url absoluteString];
    [defaults setValue:urlString forKey:@"urlString"];
    [defaults setValue:@"1" forKey:@"ismodify"];
    [defaults synchronize];
    
}

- (BOOL)selectURL:(NSURL*)url {
    NSData* bookmark = [self tryCreateBookmarkFromURL:url];

    if (bookmark == nil) {
        return NO;
    } else {
        self.primaryPathControl.URL = url;
        self.secondaryPathControl.URL = url;
        self.customStyle.state = NSControlStateValueOn;

        [defaults setValue:@"custom" forKey:@"style"];
        [defaults setObject:bookmark forKey:@"file"];

        NSData* regularBookmark = [url bookmarkDataWithOptions:0
                                includingResourceValuesForKeys:nil
                                                 relativeToURL:nil
                                                         error:nil];
        [defaults setObject:regularBookmark forKey:@"regularBookmark"];
        [defaults synchronize];
        return YES;
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
//    NSLog(@" applicationWillTerminate ");
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
//    NSLog(@" applicationSupportsSecureRestorableState ");
  return YES;
}


@end
