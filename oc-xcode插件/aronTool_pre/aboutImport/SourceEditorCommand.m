//
//  SourceEditorCommand.m
//  aboutImport
//
//  Created by Aron Ruan on 2022/5/7.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
//    XCSourceTextBuffer *buffer = invocation.buffer;
    
    NSString* commandIdentifier = invocation.commandIdentifier;
//    [NSFileManager defaultManager]
    
    if([commandIdentifier  isEqual: @"sortImport"])
    {
        NSLog(@"sortImport");//import排序+去重
        [self sortImport:invocation completionHandler:completionHandler];
    }
    else if ([commandIdentifier isEqual:@"deduplicationBlankLine"])
    {
        NSLog(@"deduplicationBlankLine");//去多余的空格（不出现连续两个空行）
        [self deduplicationBlankLine:invocation completionHandler:completionHandler ];
    }
    else if ([commandIdentifier isEqual:@"python"]){
        //存入temp.m
        [self saveToFile:invocation completionHandler:completionHandler];
        //执行batchformat.py 进行format
        NSString *pyPath = [[NSBundle mainBundle] pathForResource:@"batchformat" ofType:@".py"];
//        NSString *directory = NSHomeDirectory();
//        NSString *pyPath = [NSString stringWithFormat:@"%@/batchformat.py",directory];
        [self InvokingPythonScriptAtPath:pyPath];
        
//        取出temp.m到当前刷新
        [self getFromFile:invocation completionHandler:completionHandler];
        
    }
    
    completionHandler(nil);
}

-(void)sortImport:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSMutableArray<NSString *> *linesToSortInit = invocation.buffer.lines;
    
    // 提取到  linesToSort
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
    
    NSInteger n=[linesToSort count];
    if(n<=0){
        completionHandler(nil);
        NSLog(@"return");
        return;
    }
    
    //delete import lines
    NSMutableArray<NSString*>* linesToDeleteImport = [[NSMutableArray alloc]init];
    for(NSString * line in linesToSortInit)
    {
        BOOL flag = [line hasPrefix:@"#import"];
        if(flag){
            [linesToDeleteImport addObject:@""];
        }
        else{
            [linesToDeleteImport addObject:line];
        }
    }
//    NSLog(@"linesToDeleteImport = %@",linesToDeleteImport);
    
    NSInteger firstLineIndex = [linesToSortInit indexOfObject:linesToSort[0]];
//    NSLog(@" firstLineIndex = %ld",firstLineIndex);
    
    if(firstLineIndex <= 0)
    {
        completionHandler(nil);
        return;
    }
    
    //import 排序
    [linesToSort sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *str1=(NSString *)obj1;
        NSString *str2=(NSString *)obj2;
        return [str1 compare:str2];
    }];
//    NSLog(@"linesToSort = %@",linesToSort);
    
    //import 去重
    NSMutableArray<NSString*>*linesToDeduplicated = [[NSMutableArray alloc]init];
    [linesToDeduplicated addObject:linesToSort[0]];
    for(NSInteger i=0;i<[linesToSort count];i++)
    {
        if(i>=1){
            BOOL flag = [linesToSort[i] isEqual:linesToSort[i-1]];
            if(!flag){
                [linesToDeduplicated addObject:linesToSort[i]];
            }
            else{
                [linesToDeduplicated addObject:@""];
            }
        }
    }
//    NSLog(@"linesToDeduplicated = %@",linesToDeduplicated);
    
    //归总lines
    for(NSInteger i=0;i<[linesToDeleteImport count];i++)
    {
        [linesToSortInit replaceObjectAtIndex:i withObject:linesToDeleteImport[i]];
    }
    
    for(NSInteger i=0;i<[linesToDeduplicated count];i++)
    {
        [linesToSortInit replaceObjectAtIndex:firstLineIndex+i withObject:linesToDeduplicated[i]];
    }
    
//    NSLog(@"linesToSortInit = %@",linesToSortInit);
    [invocation.buffer.lines setArray:linesToSortInit];
}

-(void)deduplicationBlankLine:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSMutableArray<NSString *> *linesInit = invocation.buffer.lines;
    
    NSMutableArray<NSString *>* lines=[[NSMutableArray alloc]init];
    for(NSString * line in linesInit)
    {
        BOOL flag = [line isEqual:@"\n"];
        if(!flag){
            [lines addObject:line];
        }
    }
//    NSLog(@"lines = %@",lines);
    for(NSUInteger i=0;i<[lines count];i++)
    {
        [linesInit replaceObjectAtIndex:i withObject:lines[i]];
    }
    NSInteger n=[linesInit count];
    NSInteger m=[lines count];
    for(NSUInteger i=m;i<n;i++)
    {
        [linesInit removeObjectAtIndex:m];
    }
}

-(void)saveToFile:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSMutableArray<NSString*>* lines = invocation.buffer.lines;
    
    NSMutableString*str=[[NSMutableString alloc]init];
    
    for(NSString* line in lines){
        [str appendString:line];
    }
    
    NSError *error;
    
//    NSString *pyPath = [[NSBundle mainBundle] pathForResource:@"batchformat" ofType:@".py"];
//    NSLog(@"pyPath = %@",pyPath);
    
    BOOL success = [str writeToFile:@"temp.m" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if(success){
        NSLog(@"done wirting ");
    }else{
        NSLog(@"writing failed = %@",[error localizedDescription]);
    }
//    //获取沙盒根目录
//    NSString *directory = NSHomeDirectory();
//    NSLog(@"directory:%@", directory);
//    NSString *pyPath = [[NSBundle mainBundle] pathForResource:@"cool" ofType:@".txt"];
//    NSLog(@"pyPath = %@",pyPath);
    
}

-(id) InvokingPythonScriptAtPath :(NSString*) pyScriptPath
{
    //获取沙盒根目录
    NSString *directory = NSHomeDirectory();
    NSLog(@"directory:%@", directory);
//    NSString *file=@"temp.m";
    // 创建task
    NSTask *pythonTask = [[NSTask alloc]init];
    [pythonTask setLaunchPath:@"/bin/bash"];
//    NSString *pyStr = [NSString stringWithFormat:@"python3 %@ %@/temp.m",pyScriptPath,directory];
    NSString *batchformatPath = [[NSBundle mainBundle] pathForResource:@"batchformat" ofType:@".py"];
    NSLog(@"batchformatPath = %@",batchformatPath);
    NSString *pyStr = [NSString stringWithFormat:@"python3 %@ ./temp.m %@",pyScriptPath,batchformatPath];
    NSLog(@"pyStr = %@",pyStr);
    [pythonTask setArguments:[NSArray arrayWithObjects:@"-c",pyStr, nil]];
    
    //创建输出管道
    NSPipe *pipe = [[NSPipe alloc]init];
    [pythonTask setStandardOutput:pipe];
    
    // 开启task
    [pythonTask launch];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data =[file readDataToEndOfFile];
    NSString *strReturnFromPython = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"The return content from python script is: %@",strReturnFromPython);
    
    return strReturnFromPython;
    ///Users/AronRuan/Desktop/test1.py
}

-(void)getFromFile:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSMutableArray<NSString*>* lines = invocation.buffer.lines;

    [lines removeAllObjects];
    
    //获取沙盒根目录
    NSString *directory = NSHomeDirectory();
    NSLog(@"directory:%@", directory);
    NSString *file = [NSString stringWithFormat:@"%@/temp.m",directory];
    NSString *fileContext=[NSString stringWithContentsOfFile :file encoding:NSUTF8StringEncoding error:nil];
//           NSLog(@"%@",fileContext);
//    NSMutableArray<NSString*>* newLine = invocation.buffer.lines;
    
    [lines addObject:fileContext];
}

@end
