//
//  SourceEditorCommand.m
//  Extension
//
//  Created by Aron Ruan on 2022/4/14.
//

#import "SourceEditorCommand.h"
//Equatable


@implementation UTI


@end

@implementation SweetSourceEditorCommand

-(NSMutableArray< UTI *>*)validUTIs
{
    return nil;
}

-(NSString *)commandName{
    return self.className;
}

-(NSString*)commandIdentifier{
    NSString*bundleIdentifiler = [NSBundle.mainBundle bundleIdentifier];
    return  [[bundleIdentifiler stringByAppendingString:@"."] stringByAppendingString:self.className];
    
}

-(BOOL)performImpl:(XCSourceTextBuffer*)textBuffer
{
//    [self fatalError]
//    fatalError("should be implemented")
    return YES;
}

-(NSDictionary <XCSourceEditorCommandDefinitionKey, NSString*> *)commandDefinition
{
    
    NSDictionary <XCSourceEditorCommandDefinitionKey, id> * res=
        @{XCSourceEditorCommandClassNameKey:self.className,
        XCSourceEditorCommandIdentifierKey:[self commandIdentifier],
          XCSourceEditorCommandNameKey:[self commandName]};
    
    return res;
}

- (void)performCommandWithInvocation:(nonnull XCSourceEditorCommandInvocation *)invocation completionHandler:(nonnull void (^)(NSError * _Nullable))completionHandler {

    XCSourceTextBuffer * textBuffer = invocation.buffer;
    
    SweetSourceEditorCommand *sweetSourceEditorCommand =[[SweetSourceEditorCommand alloc]init];
    NSInteger isOrNot = [[sweetSourceEditorCommand validUTIs] containsObject:[textBuffer typedContentUTI]];
    
    switch (isOrNot) {
        case 0:
            // all UTIs can execute the command.
            NSLog(@"nil");
            break;
            
        case 1:
            // this UTI can execute the command.
        default:
            break;
    }
//    @try {
//
//
//
//    } @catch (NSException *exception) {
//        <#Handle an exception thrown in the @try block#>
//    } @finally {
//        <#Code that gets executed whether or not an exception is thrown#>
//    }
    
    completionHandler(nil);
    
}

@end

@implementation PasteboardOutputCommand

-(NSString *)commandName
{
    return @"file UTI -> PasteBoard";
}
@end
@implementation PasteboardInputCommand

-(NSString *)commandName
{
    return @"PasteBoard -> cursor place";
}
@end
@implementation OpenAppCommand

-(NSString *)commandName
{
    return @"open Calendar";
}
@end

@implementation URLSchemeCommand

-(NSString *)commandName
{
    return @"selected text -> twitter://post";
}
@end

@implementation LocalCommandCommand

-(NSString *)commandName
{
    return @"completeBuffer -> uppercased by tr -> completeBuffer";
}
@end

@implementation NetworkCommand

-(NSString *)commandName
{
    return @"URLRequest -> cursor place";
}
@end
@implementation ToDesktopCommand1

-(NSString *)commandName
{
    return @"completeBuffer -> desktop (permission denied)";
}
@end
@implementation ToDesktopCommand2

-(NSString *)commandName
{
    return @"completeBuffer -> (XPC) -> desktop";
}
@end
@implementation FileSelectionCommand

-(NSString *)commandName
{
    return @"(App by URLScheme) -> select a file -> (UserDefaults) -> cursor place";
}
@end

@implementation SourceEditorCommand

//- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
//{
//    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
//
//    completionHandler(nil);
//}

@end

@implementation XCSourceTextBuffer

-(UTI*)typedContentUTI
{
    UTI *uti =[[UTI alloc]init];
    [uti setValue:_contentUTI];
    return uti;
}

-(NSString*)selectedText:(BOOL)includesUnselectedStartAndEnd :(BOOL)trimsIndents
{
    NSMutableArray<NSString*>*texts=[[NSMutableArray alloc]init];
    NSInteger minimumIndentLength=NSIntegerMax;
    
    
    return @"";
}

@end

