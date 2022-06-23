//
//  SourceEditorCommand.m
//  aboutImport
//
//  Created by Aron Ruan on 2022/5/7.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

NSErrorDomain errorDomain = @"ClangFormatError";

NSUserDefaults* defaults = nil;

- (NSData*)getCustomStyle {
    // First, read the regular bookmark because it could've been changed by the wrapper app.
    NSData* regularBookmark = [defaults dataForKey:@"regularBookmark"];
    NSURL* regularURL = nil;
    BOOL regularStale = NO;
    if (regularBookmark) {
        regularURL = [NSURL URLByResolvingBookmarkData:regularBookmark
                                               options:NSURLBookmarkResolutionWithoutUI
                                         relativeToURL:nil
                                   bookmarkDataIsStale:&regularStale
                                                 error:nil];
    }

    if (!regularURL) {
        return nil;
    }

    // Then read the security URL, which is the URL we're actually going to use to access the file.
    NSData* securityBookmark = [defaults dataForKey:@"securityBookmark"];
    NSURL* securityURL = nil;
    BOOL securityStale = NO;
    if (securityBookmark) {
        securityURL = [NSURL URLByResolvingBookmarkData:securityBookmark
                                                options:NSURLBookmarkResolutionWithSecurityScope |
                                                        NSURLBookmarkResolutionWithoutUI
                                          relativeToURL:nil
                                    bookmarkDataIsStale:&securityStale
                                                  error:nil];
    }

    // Clear out the security URL if it's no longer matching the regular URL.
    if (securityStale == YES ||
        (securityURL && ![[securityURL path] isEqualToString:[regularURL path]])) {
        securityURL = nil;
    }

    if (!securityURL && regularStale == NO) {
        // Attempt to create new security URL from the regular URL to persist across system reboots.
        NSError* error = nil;
        securityBookmark = [regularURL
                   bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope |
                                           NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess
            includingResourceValuesForKeys:nil
                             relativeToURL:nil
                                     error:&error];
        [defaults setObject:securityBookmark forKey:@"securityBookmark"];
        securityURL = regularURL;
    }

    if (securityURL) {
        // Finally, attempt to read the .clang-format file
        NSError* error = nil;
        [securityURL startAccessingSecurityScopedResource];
        NSData* data = [NSData dataWithContentsOfURL:securityURL options:0 error:&error];
        [securityURL stopAccessingSecurityScopedResource];
        if (error) {
            NSLog(@"Error loading from security bookmark: %@", error);
        } else if (data) {
            return data;
        }
    }

    return nil;
}

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    if (!defaults) {
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"XcodeClangFormat"];
    }
    NSString* ismodify = [defaults stringForKey:@"ismodify"];
    
    NSString *directory = NSHomeDirectory();
    NSString *filePath = [directory stringByAppendingPathComponent:@".clang-format"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
//    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    
    //检查配置是否更新以及.clang-format配置文件是否存在
    if([ismodify isEqual:@"1"]||(!result))
    {
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"XcodeClangFormat"];
        NSData* config = [self getCustomStyle];
        NSLog(@"config = %@",config);
        [self saveConfigClangFormat:config];
        [defaults setValue:@"0" forKey:@"ismodify"];
    }
    NSString* style = [defaults stringForKey:@"style"];
    if (!style) {
        style = @"llvm";
    }
    NSLog(@"style = %@",style);
    
    NSString* commandIdentifier = invocation.commandIdentifier;
    if ([commandIdentifier isEqual:@"FormatFile"]){
        //存入temp.m
        [self saveToFile:invocation completionHandler:completionHandler];
        //执行format
        NSString *pyPath = [[NSBundle mainBundle] pathForResource:@"clang-format" ofType:@""];
        [self InvokingPythonScriptAtPath:pyPath];
        //取出temp.m到当前刷新
        [self getFromFile:invocation completionHandler:completionHandler];
        //删除temp.m or 清空temp.m
        [self deleteTemp];
        
    }else if ([commandIdentifier isEqual:@"FormatSelection"]){
        [self saveSelectionToFile:invocation completionHandler:completionHandler];
        NSString *pyPath = [[NSBundle mainBundle] pathForResource:@"clang-format" ofType:@""];
        [self InvokingPythonScriptAtPath:pyPath];
        [self getSelectionFromFile:invocation completionHandler:completionHandler];
        [self deleteTemp];
    }else if ([commandIdentifier isEqual:@"clangTest"])
    {
        NSLog(@"clangTest");
        //存入temp.m
        [self saveToFile:invocation completionHandler:completionHandler];

        NSString *pyScriptPath = @"temp.m";
        [self clangAST :pyScriptPath];
    }
    
    completionHandler(nil);
}
-(void)clangAST:(NSString*) pyScriptPath
{
    NSString *cmd = [NSString stringWithFormat:@"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -fmodules -fsyntax-only -Xclang -ast-dump %@",pyScriptPath];
    NSString *output = [NSString string];
     //这个对中文有问题

     //FILE *pipe = popen([cmd cStringUsingEncoding: NSASCIIStringEncoding], "r+");
     FILE *pipe = popen([cmd UTF8String], "r");
     if (!pipe)
         return ;
     char buf[1024];
     while(fgets(buf, 1024, pipe)) {
         output = [output stringByAppendingFormat: @"%s", buf];
     }
    NSLog(@"output = %@",output);
     pclose(pipe);
//    NSTask *pythonTask = [[NSTask alloc]init];
//    [pythonTask setLaunchPath:@"/bin/sh"];
//
//    NSString *pyStr = [NSString stringWithFormat:@"clang -fmodules -fsyntax-only -Xclang -ast-dump %@",pyScriptPath];
//
//    NSLog(@"pyStr = %@",pyStr);
//    [pythonTask setArguments:[NSArray arrayWithObjects:@"-c",pyStr, nil]];
//
//    //创建输出管道
//    NSPipe *pipe = [[NSPipe alloc]init];
//    [pythonTask setStandardOutput:pipe];
//
//    // 开启task
//    [pythonTask launch];
//
//    NSFileHandle *file = [pipe fileHandleForReading];
//    NSLog(@"file = %@",file);
//    NSData *data =[file readDataToEndOfFile];
//    NSString *strReturnFromPython = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"The return content from python script is: %@",strReturnFromPython);
}

//-------------------------------------------
//保存自定义配置文件  .clang-format
-(void)saveConfigClangFormat:(NSData*)config
{
    NSError *error;
    BOOL success = [config writeToFile:@".clang-format" atomically:YES];
    if(success){
        NSLog(@".clang-format file done wirting ");
    }else{
        NSLog(@"writing failed = %@",[error localizedDescription]);
    }
}

//FormatFile format整个源文件
-(void)saveToFile:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSMutableArray<NSString*>* lines = invocation.buffer.lines;
    
    NSMutableString*str=[[NSMutableString alloc]init];
    
    for(NSString* line in lines){
        [str appendString:line];
    }
    
    NSError *error;
    
    BOOL success = [str writeToFile:@"temp.m" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if(success){
        NSLog(@"saveToFile done wirting ");
    }else{
        NSLog(@"writing failed = %@",[error localizedDescription]);
    }
}

-(id) InvokingPythonScriptAtPath :(NSString*) pyScriptPath
{
    // 创建task
    NSTask *pythonTask = [[NSTask alloc]init];
    [pythonTask setLaunchPath:@"/bin/bash"];
    
    if (!defaults) {
        defaults = [[NSUserDefaults alloc] initWithSuiteName:@"XcodeClangFormat"];
    }
    NSString* style = [defaults stringForKey:@"style"];
    NSString *pyStr = [NSString stringWithFormat:@"%@ -style=%@ -i ./temp.m ",pyScriptPath,style];
    if([style isEqual:@"custom"]){
        pyStr = [NSString stringWithFormat:@"%@ -style=file -i ./temp.m ",pyScriptPath];
    }
    
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
}

-(void)getFromFile:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSMutableArray<NSString*>* lines = invocation.buffer.lines;
    [lines removeAllObjects];
    //获取沙盒根目录
//    NSString *directory = NSHomeDirectory();
//    NSString *file = [NSString stringWithFormat:@"%@/temp.m",directory];
//    NSString *fileContext=[NSString stringWithContentsOfFile :file encoding:NSUTF8StringEncoding error:nil];
    NSString *fileContext=[NSString stringWithContentsOfFile :@"./temp.m" encoding:NSUTF8StringEncoding error:nil];
    [lines addObject:fileContext];
}

//-------------------------------------------
//FormatSelection format选择部分内容
-(void)saveSelectionToFile:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSMutableArray<NSString*>* lines = invocation.buffer.lines;
    NSMutableString*str=[[NSMutableString alloc]init];
    NSMutableArray<XCSourceTextRange *> * selection = invocation.buffer.selections;
    NSInteger start = selection[0].start.line;
    NSInteger end = selection[0].end.line;
    for(NSInteger i =start;i<=end;i++)
    {
        [str appendString:lines[i]];
    }
    
    NSError *error;
    
    BOOL success = [str writeToFile:@"temp.m" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if(success){
        NSLog(@"saveSelectionToFile done wirting ");
    }else{
        NSLog(@"writing failed = %@",[error localizedDescription]);
    }
}

-(void)getSelectionFromFile:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSMutableArray<NSString*>* lines = invocation.buffer.lines;
    NSMutableArray<XCSourceTextRange *> * selection = invocation.buffer.selections;
    NSInteger start = selection[0].start.line;
    NSInteger end = selection[0].end.line;
    NSMutableString*str=[[NSMutableString alloc]init];
    
    for(NSInteger i=0;i<start;i++)
    {
        [str appendString:lines[i]];
    }
    
    
//    //获取沙盒根目录
//    NSString *directory = NSHomeDirectory();
//    NSString *file = [NSString stringWithFormat:@"./temp.m"];
//    NSString *file = [NSString stringWithFormat:@"%@/temp.m",directory];
    NSString *fileContext=[NSString stringWithContentsOfFile :@"./temp.m" encoding:NSUTF8StringEncoding error:nil];
    [str appendString:fileContext];
    
    for(NSInteger i=end;i<[lines count];i++)
    {
        [str appendString:lines[i]];
    }
    [lines removeAllObjects];
    [lines addObject:str];
    
}
//-------------------------------------------
//处理temp.m文件

-(void)deleteTemp
{
    NSFileManager *FileManager=[NSFileManager defaultManager];
    BOOL f=[FileManager removeItemAtPath:@"./temp.m" error:nil];
    if (f==YES)
    {
        NSLog(@"删除成功");
    }
}

@end
