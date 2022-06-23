//
//  SourceEditorCommand.m
//  ZExtension
//  将import 排序
//
//  Created by Aron Ruan on 2022/4/15.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
    NSMutableArray<NSString *> *linesToSortInit = invocation.buffer.lines;
    NSInteger n=[linesToSortInit count];
//    NSLog(@"[linesToSort count] = %ld",n);
    NSMutableArray<NSString *> *linesToSort = [[NSMutableArray alloc]init];
    for(NSString *line in linesToSortInit)
    {
        [linesToSort addObject:line];
    }
    [linesToSort filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * line, NSDictionary<NSString *,NSString *> *bindings){
        BOOL f= [line hasPrefix:@"#import"];
        if(!f){
            return NO;
        }
        return YES;
    }
    ]];
//    NSLog(@"linesToSortInit= %@",linesToSortInit);
    NSLog(@"linesToSort = %@",linesToSort);
    
    if(n<=0){
        completionHandler(nil);
        return;
    }

    NSInteger firstLineIndex = [linesToSortInit indexOfObject:linesToSort[0]];
    NSLog(@" firstLineIndex = %ld",firstLineIndex);
    if(firstLineIndex <= 0)
    {
        completionHandler(nil);
        return;
    }
    [linesToSort sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *str1=(NSString *)obj1;
        NSString *str2=(NSString *)obj2;
        return [str1 compare:str2];
    }];
    NSLog(@"linesToSort = %@",linesToSort);
//    NSMutableArray *linesSorted = [[NSMutableArray alloc]init];

    
//    linesSorted.reversed().forEach { (line) in
//        invocation.buffer.lines.insert(line, at: firstLineIndex)
//    }
//    NSArray *linesSorted=[[linesToSort reverseObjectEnumerator] allObjects];
//    NSLog(@"linesSorted = %@",linesSorted);
    for(NSInteger i=0;i<[linesToSort count];i++)
    {
        [linesToSortInit replaceObjectAtIndex:firstLineIndex+i withObject:linesToSort[i]];
    }
    NSLog(@"linesToSortInit = %@",linesToSortInit);
    
//    NSMutableArray <XCSourceTextRange *>* selectionsUpdated =[[NSMutableArray alloc]init];
    
//    let selectionsUpdated: [XCSourceTextRange] = (0..<linesSorted.count).map { (index) in
//        let lineIndex = firstLineIndex + index
//        let endColumn = linesSorted[index].count - 1
//        return XCSourceTextRange(start: XCSourceTextPosition(line: lineIndex, column: 0), end: XCSourceTextPosition(line: lineIndex, column: endColumn))
//    }
//    invocation.buffer.selections.setArray(selectionsUpdated)
    [invocation.buffer.lines setArray:linesToSortInit];
    completionHandler(nil);
}

@end
