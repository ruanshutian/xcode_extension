//
//  SourceEditorCommand.m
//  ClangFormat
//
//  Created by Aron Ruan on 2022/6/20.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

NSErrorDomain errorDomain = @"ClangFormatError";

NSUserDefaults *defaults = nil;

- (NSData *)getCustomStyle {
  NSData *regularBookmark = [defaults dataForKey:@"regularBookmark"];
  NSURL *regularURL = nil;
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

  NSData *securityBookmark = [defaults dataForKey:@"securityBookmark"];
  NSURL *securityURL = nil;
  BOOL securityStale = NO;
  if (securityBookmark) {
    securityURL = [NSURL URLByResolvingBookmarkData:securityBookmark
                                            options:NSURLBookmarkResolutionWithSecurityScope |
                                                    NSURLBookmarkResolutionWithoutUI
                                      relativeToURL:nil
                                bookmarkDataIsStale:&securityStale
                                              error:nil];
  }

  if (securityStale == YES ||
      (securityURL && ![[securityURL path] isEqualToString:[regularURL path]])) {
    securityURL = nil;
  }

  if (!securityURL && regularStale == NO) {
    NSError *error = nil;
    securityBookmark =
        [regularURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope |
                                            NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess
             includingResourceValuesForKeys:nil
                              relativeToURL:nil
                                      error:&error];
    [defaults setObject:securityBookmark forKey:@"securityBookmark"];
    securityURL = regularURL;
  }

  if (securityURL) {
    NSError *error = nil;
    [securityURL startAccessingSecurityScopedResource];
    NSData *data = [NSData dataWithContentsOfURL:securityURL options:0 error:&error];
    [securityURL stopAccessingSecurityScopedResource];
    if (error) {
      NSLog(@"Error loading from security bookmark: %@", error);
    } else if (data) {
      return data;
    }
  }

  return nil;
}

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation
                   completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler {
  if (!defaults) {
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"XcodeClangFormat"];
  }
  NSString *ismodify = [defaults stringForKey:@"ismodify"];

  NSString *directory = NSHomeDirectory();
  NSString *filePath = [directory stringByAppendingPathComponent:@".clang-format"];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL result = [fileManager fileExistsAtPath:filePath];
  if ([ismodify isEqual:@"1"] || (!result)) {
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"XcodeClangFormat"];
    NSData *config = [self getCustomStyle];
    NSLog(@"config = %@", config);
    [self saveConfigClangFormat:config];
    [defaults setValue:@"0" forKey:@"ismodify"];
  }
  NSString *style = [defaults stringForKey:@"style"];
  if (!style) {
    style = @"llvm";
  }

  NSString *commandIdentifier = invocation.commandIdentifier;
  if ([commandIdentifier isEqual:@"FormatFile"]) {
    [self saveToFile:invocation completionHandler:completionHandler];
    NSString *pyPath = [[[NSBundle mainBundle] resourcePath]
        stringByAppendingString:@"/formattest/tools/clang-format/clang-format"];

    [self InvokingPythonScriptAtPath:pyPath];

    [self getFromFile:invocation completionHandler:completionHandler];

    [self deleteTemp];

  } else if ([commandIdentifier isEqual:@"FormatSelection"]) {
    [self saveSelectionToFile:invocation completionHandler:completionHandler];
    NSString *pyPath = [[NSBundle mainBundle] pathForResource:@"clang-format" ofType:@""];
    [self InvokingPythonScriptAtPath:pyPath];
    [self getSelectionFromFile:invocation completionHandler:completionHandler];
    [self deleteTemp];
  }

  completionHandler(nil);
}

- (void)saveConfigClangFormat:(NSData *)config {
  NSError *error;
  BOOL success = [config writeToFile:@".clang-format" atomically:YES];
  if (success) {
    NSLog(@".clang-format file done wirting ");
  } else {
    NSLog(@"writing failed = %@", [error localizedDescription]);
  }
}

- (void)saveToFile:(XCSourceEditorCommandInvocation *)invocation
    completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler {
  NSMutableArray<NSString *> *lines = invocation.buffer.lines;

  NSMutableString *str = [[NSMutableString alloc] init];

  for (NSString *line in lines) {
    [str appendString:line];
  }

  NSError *error;

  BOOL success = [str writeToFile:@"temp.m"
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:&error];

  if (success) {
    NSLog(@"saveToFile done wirting ");
  } else {
    NSLog(@"writing failed = %@", [error localizedDescription]);
  }
}

- (id)InvokingPythonScriptAtPath:(NSString *)pyScriptPath {
  NSTask *pythonTask = [[NSTask alloc] init];
  [pythonTask setLaunchPath:@"/bin/bash"];

  if (!defaults) {
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"XcodeClangFormat"];
  }
  NSString *style = [defaults stringForKey:@"style"];
  NSString *pyStr = [NSString stringWithFormat:@"%@ -style=%@ -i ./temp.m ", pyScriptPath, style];
  if ([style isEqual:@"custom"]) {
    pyStr = [NSString stringWithFormat:@"%@ -style=file -i ./temp.m ", pyScriptPath];
  }

  NSLog(@"pyStr = %@", pyStr);
  [pythonTask setArguments:[NSArray arrayWithObjects:@"-c", pyStr, nil]];

  NSPipe *pipe = [[NSPipe alloc] init];
  [pythonTask setStandardOutput:pipe];

  [pythonTask launch];

  NSFileHandle *file = [pipe fileHandleForReading];
  NSData *data = [file readDataToEndOfFile];
  NSString *strReturnFromPython = [[NSString alloc] initWithData:data
                                                        encoding:NSUTF8StringEncoding];
  //  NSLog(@"The return content from python script is: %@", strReturnFromPython);

  return strReturnFromPython;
}

- (void)getFromFile:(XCSourceEditorCommandInvocation *)invocation
    completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler {
  NSMutableArray<NSString *> *lines = invocation.buffer.lines;
  [lines removeAllObjects];

  NSString *fileContext = [NSString stringWithContentsOfFile:@"./temp.m"
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
  [lines addObject:fileContext];
}

- (void)saveSelectionToFile:(XCSourceEditorCommandInvocation *)invocation
          completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler {
  NSMutableArray<NSString *> *lines = invocation.buffer.lines;
  NSMutableString *str = [[NSMutableString alloc] init];
  NSMutableArray<XCSourceTextRange *> *selection = invocation.buffer.selections;
  NSInteger start = selection[0].start.line;
  NSInteger end = selection[0].end.line;
  for (NSInteger i = start; i <= end; i++) {
    [str appendString:lines[i]];
  }

  NSError *error;

  BOOL success = [str writeToFile:@"temp.m"
                       atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:&error];

  if (success) {
    NSLog(@"saveSelectionToFile done wirting ");
  } else {
    NSLog(@"writing failed = %@", [error localizedDescription]);
  }
}

- (void)getSelectionFromFile:(XCSourceEditorCommandInvocation *)invocation
           completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler {
  NSMutableArray<NSString *> *lines = invocation.buffer.lines;
  NSMutableArray<XCSourceTextRange *> *selection = invocation.buffer.selections;
  NSInteger start = selection[0].start.line;
  NSInteger end = selection[0].end.line;
  NSMutableString *str = [[NSMutableString alloc] init];

  for (NSInteger i = 0; i < start; i++) {
    [str appendString:lines[i]];
  }
  NSString *fileContext = [NSString stringWithContentsOfFile:@"./temp.m"
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
  [str appendString:fileContext];

  for (NSInteger i = end; i < [lines count]; i++) {
    [str appendString:lines[i]];
  }
  [lines removeAllObjects];
  [lines addObject:str];
}

- (void)deleteTemp {
  NSFileManager *FileManager = [NSFileManager defaultManager];
  BOOL f = [FileManager removeItemAtPath:@"./temp.m" error:nil];
  if (f == YES) {
    NSLog(@"删除成功");
  }
}

@end
