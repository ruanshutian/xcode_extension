//
//  SourceEditorCommand.m
//  EC
//
//  Created by Aron Ruan on 2022/4/18.
//

#import "SourceEditorCommand.h"
#import "EasyCodeManager.h"
#import <AppKit/NSWorkspace.h>

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    if ([invocation.commandIdentifier isEqualToString:@"easycode.insertcode"]) {
        [[EasyCodeManager sharedInstance] handleInvocation:invocation];
        
    }
    else if ([invocation.commandIdentifier isEqualToString:@"easycode.editmapping"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:@"/Applications/EasyCode.app"]];
    }
    
    
    completionHandler(nil);
}

@end
