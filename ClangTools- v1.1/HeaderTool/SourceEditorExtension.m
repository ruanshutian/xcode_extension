//
//  SourceEditorExtension.m
//  HeaderTool
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

- (NSArray<NSDictionary<XCSourceEditorCommandDefinitionKey, id> *> *)
    commandDefinitions {
      NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *
      res=@[
          @{
              XCSourceEditorCommandClassNameKey:@"SourceEditorCommand",
              XCSourceEditorCommandIdentifierKey:@"importSort",
              XCSourceEditorCommandNameKey:@"importSort"
          }
      ];
  
      return res;
}

@end
