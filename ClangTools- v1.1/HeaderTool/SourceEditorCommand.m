//
//  SourceEditorCommand.m
//  HeaderTool
//
//  Created by Aron Ruan on 2022/6/20.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation
                   completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler {
  // Implement your command here, invoking the completion handler when done. Pass it nil on success,
  // and an NSError on failure.

  NSString *commandIdentifier = invocation.commandIdentifier;
  if ([commandIdentifier isEqual:@"importSort"]) {
    [self importSort:invocation completionHandler:completionHandler];
  }

  completionHandler(nil);
}

- (void)importSort:(XCSourceEditorCommandInvocation *)invocation
    completionHandler:(void (^)(NSError *_Nullable nilOrError))completionHandler {
  NSMutableArray<NSString *> *linesInput = invocation.buffer.lines;
  NSMutableArray<NSString *> *linesToSort = [NSMutableArray array];
  NSMutableArray<NSString *> *linesNormal = [NSMutableArray array];
  for (NSString *line in linesInput) {
    BOOL f1 = [line hasPrefix:@"#import"];
    BOOL f2 = [line hasPrefix:@"#include"];
    if (f1 || f2) {
      [linesToSort addObject:line];
    } else {
      [linesNormal addObject:line];
    }
  }

  NSInteger n = [linesToSort count];
  if (n <= 0) {
    NSLog(@"header is not found！");
    return;
  }

  //排序
  [linesToSort sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
    NSString *str1 = (NSString *)obj1;
    NSString *str2 = (NSString *)obj2;
    return [str1 compare:str2];
  }];

  //去重
  NSMutableArray<NSString *> *linesToSortUpdated = [NSMutableArray array];
  for (NSString *line in linesToSort) {
    if (![linesToSortUpdated containsObject:line]) {
      [linesToSortUpdated addObject:line];
    }
  }

  [linesToSortUpdated addObjectsFromArray:linesNormal];
  [invocation.buffer.lines setArray:linesToSortUpdated];
}

@end
