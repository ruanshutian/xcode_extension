//
//  SourceEditorExtension.m
//  XTComment
//
//  Created by Aron Ruan on 2022/4/14.
//

#import "SourceEditorExtension.h"

@implementation SourceEditorExtension


- (void)extensionDidFinishLaunching
{
    // If your extension needs to do any work at launch, implement this optional method.
    NSLog(@"Extension launched...");
}


/*
 Xcode的启动时候会记载所有的extension，并保证它们的生命周期。当用户点击选择命令按钮后，Xcode会以invocation的形式通知到extension，extension做出相应的处理并把处理结果回调给Xcode。SourceEditorExtension.swift的方法extensionDidFinishLaunching在extension被加载时调用，可以在这里做一些初始化的工作。
 */
- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions
{
    // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
    
    NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> * res=@[
        @{XCSourceEditorCommandClassNameKey:@"SourceEditorCommand",
        XCSourceEditorCommandIdentifierKey:@"CustomIdentifier",
        XCSourceEditorCommandNameKey:@"CustomeName"}
    ];
    
    return res;
}

@end
