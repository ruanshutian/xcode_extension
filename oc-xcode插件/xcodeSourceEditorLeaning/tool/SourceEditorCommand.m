//
//  SourceEditorCommand.m
//  tool
//
//  Created by Aron Ruan on 2022/4/19.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    //特殊xcode实例
//    class SourceEditorCommand: NSObject, XCSourceEditorCommand {
//        func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
//            // Retrieve the contents of the current source editor.
//            let lines = invocation.buffer.lines
//            // Reverse the order of the lines in a copy.
//            let updatedText = Array(lines.reversed())
//            lines.removeAllObjects()
//            lines.addObjects(from: updatedText)
//            // Signal to Xcode that the command has completed.
//            completionHandler(nil)
//        }
//    }
    NSLog(@"invocation = %@",invocation);
    NSLog(@"invocation.buffer = %@",invocation.buffer);
    NSLog(@"invocation.commandIdentifier = %@",invocation.commandIdentifier);
    NSLog(@"invocation.cancellationHandler = %@",invocation.cancellationHandler);
//    2022-04-20 11:19:53.026832+0800 tool[80672:1734264] invocation = <XCSourceEditorCommandInvocation: 0x13711ea20 'Big-Nerd-Ranch.xcodeSourceEditorLeaning.tool.SourceEditorCommand' in flight>
//    2022-04-20 11:19:53.026923+0800 tool[80672:1734264] invocation.buffer = <XCSourceTextBuffer: 0x1371062e0 'public.objective-c-source' (4/4/spaces) 16 lines, 1 selected ranges, 0 changes>
//    2022-04-20 11:19:53.026950+0800 tool[80672:1734264] invocation.commandIdentifier = Big-Nerd-Ranch.xcodeSourceEditorLeaning.tool.SourceEditorCommand
//    2022-04-20 11:19:53.026971+0800 tool[80672:1734264] invocation.cancellationHandler = (null)
    
    NSLog(@"invocation.buffer.completeBuffer = %@",invocation.buffer.completeBuffer);
    NSLog(@"invocation.buffer.contentUTI = %@",invocation.buffer.contentUTI);
    
    NSLog(@"invocation.buffer.lines = %@",invocation.buffer.lines);
    NSLog(@"invocation.buffer.selections = %@",invocation.buffer.selections);
    
    NSLog(@"invocation.buffer.indentationWidth = %ld",invocation.buffer.indentationWidth);
    NSLog(@"invocation.buffer.usesTabsForIndentation = %d",invocation.buffer.usesTabsForIndentation);
    NSLog(@"invocation.buffer.tabWidth = %ld",invocation.buffer.tabWidth);
    
    XCSourceTextPosition position = XCSourceTextPositionMake(0, 0);
    XCSourceTextPosition position2 = XCSourceTextPositionMake(10, 0);
    NSLog(@"position.column = %ld",position.column);
    NSLog(@"position.line = %ld",position.line);
    
    XCSourceTextRange *textRange = [[XCSourceTextRange alloc]initWithStart:position end:position2];
    
    NSLog(@" textRange = %@",textRange);
//    NSLog(@" textRange.start = %d",textRange.start);
//    NSLog(@" textRange.end = %d",textRange.end);
    
    NSLog(@"XCXcodeKitVersionNumber = %f",XCXcodeKitVersionNumber);
    NSLog(@"XCXcodeKitVersionNumber_Xcode_8_0 = %f",XCXcodeKitVersionNumber_Xcode_8_0);
    
    NSMutableArray<NSString *> *lines= invocation.buffer.lines;
    NSArray<NSString *> *updatedText=[[lines reverseObjectEnumerator] allObjects];
    [lines removeAllObjects];
    for(NSString* NSArray_i in updatedText)
    {
        [lines addObject:NSArray_i];
    }

    completionHandler(nil);
}

@end
