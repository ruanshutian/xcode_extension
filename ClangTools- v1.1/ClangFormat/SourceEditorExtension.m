//
//  SourceEditorExtension.m
//  ClangFormat
//
//  Created by Aron Ruan on 2022/6/20.
//

#import "SourceEditorExtension.h"

@implementation SourceEditorExtension

/*
- (void)extensionDidFinishLaunching
{
    // If your extension needs to do any work at launch, implement this optional
method.
}
*/

- (NSArray<NSDictionary<XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions {
  // If your extension needs to return a collection of command definitions that
  // differs from those in its Info.plist, implement this optional property
  // getter.
  //    return @[];
  NSArray<NSDictionary<XCSourceEditorCommandDefinitionKey, id> *> *res = @[
    @{
      XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
      XCSourceEditorCommandIdentifierKey : @"FormatFile",
      XCSourceEditorCommandNameKey : @"Format Entire File"
    },
    @{
      XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
      XCSourceEditorCommandIdentifierKey : @"FormatSelection",
      XCSourceEditorCommandNameKey : @"Format Selection"
    }
  ];

  return res;
}

@end
