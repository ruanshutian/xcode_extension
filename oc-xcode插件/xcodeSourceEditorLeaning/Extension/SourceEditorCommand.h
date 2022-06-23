//
//  SourceEditorCommand.h
//  Extension
//
//  Created by Aron Ruan on 2022/4/14.
//

#import <XcodeKit/XcodeKit.h>
//Equatable
@interface UTI :NSObject

@property(nonatomic)NSString *value;

@end

@interface SweetSourceEditorCommand : NSObject<XCSourceEditorCommand>

-(NSString *)commandName;

-(NSString*)commandIdentifier;

-(BOOL)performImpl:(XCSourceTextBuffer*)textBuffer;

-(NSDictionary <XCSourceEditorCommandDefinitionKey, NSString*> *)commandDefinition;

@end

@interface PasteboardOutputCommand : SweetSourceEditorCommand
@end
@interface PasteboardInputCommand : SweetSourceEditorCommand
@end
@interface OpenAppCommand : SweetSourceEditorCommand
@end
@interface URLSchemeCommand : SweetSourceEditorCommand
@end
@interface LocalCommandCommand : SweetSourceEditorCommand
@end
@interface NetworkCommand : SweetSourceEditorCommand
@end
@interface ToDesktopCommand1 : SweetSourceEditorCommand
@end
@interface ToDesktopCommand2 : SweetSourceEditorCommand
@end
@interface FileSelectionCommand : SweetSourceEditorCommand
@end


@interface SourceEditorCommand : SweetSourceEditorCommand
@end

@interface XCSourceTextBuffer ()
-(UTI*)typedContentUTI;

@end
