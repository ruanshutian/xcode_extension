//
//  SourceEditorCommand.m
//  XTComment
//
//  Created by Aron Ruan on 2022/4/14.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
    NSMutableArray *lineIndexs=[[NSMutableArray alloc]init];
    
    NSMutableArray<NSString *> *lines=invocation.buffer.lines;
    
    NSMutableArray<XCSourceTextRange *> *s = invocation.buffer.selections;
    
    for(XCSourceTextRange *range in s)
    {
        XCSourceTextPosition start = range.start;
        XCSourceTextPosition end = range.end;
//        NSLog(@"s = %@",lineIndexs[10]);
//        NSLog(@"start = %d , end = %d",start,end);
        for(NSInteger i=start.line;i<=end.line;i++)
        {
            NSLog(@"i = %ld",i);
            [lineIndexs addObject:[NSNumber numberWithInteger:i]];
        }

    }
    NSLog(@"lineIndexs = %@",lineIndexs);
    for(NSNumber* lineNumber in lineIndexs)
    {
        NSInteger lineNumberInt=[lineNumber integerValue];
        NSString *commentLine=[[NSString alloc]init];
        commentLine = lines[lineNumberInt];
        NSLog(@"commentLine = %@",commentLine);
        NSMutableString *commentLine1=[[NSMutableString alloc]initWithString:commentLine];
        [commentLine1 insertString:@"//" atIndex:0];
        NSLog(@"lineNumber = %@",lineNumber);
        [invocation.buffer.lines replaceObjectAtIndex:lineNumberInt withObject:commentLine1];
        
    }
    
    completionHandler(nil);
}



@end
