//
//  SourceEditorExtension.m
//  Extension
//
//  Created by Aron Ruan on 2022/4/14.
//

#import "SourceEditorExtension.h"
#import "SourceEditorCommand.h"

@implementation SourceEditorExtension


//- (void)extensionDidFinishLaunching
//{
//    // If your extension needs to do any work at launch, implement this optional method.
//
//}


- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions
{
//    // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
    //    NSDictionary <XCSourceEditorCommandDefinitionKey, id> * res=
    //        @{XCSourceEditorCommandClassNameKey:@"SourceEditorCommand",
    //        XCSourceEditorCommandIdentifierKey:self.className,
    //        XCSourceEditorCommandNameKey:@"xxx"};
    NSDictionary <XCSourceEditorCommandDefinitionKey, id> *pasteboardOutputCommand=[[[PasteboardOutputCommand alloc]init] commandDefinition];
    NSDictionary <XCSourceEditorCommandDefinitionKey, id>
        *pasteboardInputCommand = [[[PasteboardInputCommand alloc]init ] commandDefinition];
    NSDictionary<XCSourceEditorCommandDefinitionKey,id>
        *openAppCommand = [[[OpenAppCommand alloc]init ] commandDefinition];
    NSDictionary<XCSourceEditorCommandDefinitionKey,id>
        *uRLSchemeCommand = [[[URLSchemeCommand alloc]init ] commandDefinition];
    NSDictionary<XCSourceEditorCommandDefinitionKey,id>
        *localCommandCommand = [[[LocalCommandCommand alloc]init ] commandDefinition];
    NSDictionary<XCSourceEditorCommandDefinitionKey,id>
        *networkCommand = [[[NetworkCommand alloc]init ] commandDefinition];
    NSDictionary<XCSourceEditorCommandDefinitionKey,id>
        *toDesktopCommand1 = [[[ToDesktopCommand1 alloc]init ] commandDefinition];
    NSDictionary<XCSourceEditorCommandDefinitionKey,id>
        *toDesktopComman2 = [[[ToDesktopCommand2 alloc]init ] commandDefinition];
    NSDictionary<XCSourceEditorCommandDefinitionKey,id>
        *fileSelectionCommand = [[[FileSelectionCommand alloc]init ] commandDefinition];
    return @[ pasteboardOutputCommand,pasteboardInputCommand,openAppCommand ,uRLSchemeCommand,localCommandCommand,networkCommand,toDesktopCommand1,toDesktopComman2,fileSelectionCommand];
}

@end
