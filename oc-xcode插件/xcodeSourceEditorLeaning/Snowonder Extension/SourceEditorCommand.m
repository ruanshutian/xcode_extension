//
//  SourceEditorCommand.m
//  Snowonder Extension
//
//  Created by Aron Ruan on 2022/5/5.
//

#import "SourceEditorCommand.h"

//extension String {
//
//    func matches(pattern: String) -> Bool {
//        guard let regularExpression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
//            return false
//        }
//
//        let matchingStrings = regularExpression.matches(in: self, range: NSMakeRange(0, count))
//        return !matchingStrings.isEmpty
//    }
//}

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    
    NSMutableArray<NSString *> * lines = invocation.buffer.lines;
    NSLog(@"lines = %@",lines);
    
    NSError *error = nil;
    
    if([lines isKindOfClass:[NSMutableArray<NSString*> class]])
    {
        @try {
            ImportBlockDetector * detector=[[ImportBlockDetector alloc]init];
            
            
            
        } @catch (NSError *exception) {
//            <#Handle an exception thrown in the @try block#>
            error = exception;
        } @finally {
            
        }
    }
    
    completionHandler(error);
}

@end

@implementation ImportBlock

@end

@implementation ImportBlockDetector

//open func importBlock(from lines: [String]) throws -> ImportBlock {
//    let group = self.group(for: lines, using: Constant.allGroups)
//
//    guard !group.isEmpty else {
//        throw ImportBlockDetectorError.notFound
//    }
//
//    let declarations = self.declarations(from: lines, using: group)
//    let categorizedDeclarations = self.categorizedDeclarations(from: declarations, using: group)
//
//    return .init(group: group, declarations: declarations, categorizedDeclarations: categorizedDeclarations)
//}
-(ImportBlock*)importBlock:(NSMutableArray<NSString*>*)lines
{
    ImportBlock * s= [[ImportBlock alloc] init];
    
    return s;
}

//open func group(for lines: [String], using availableGroups: [ImportCategoriesGroup]) -> ImportCategoriesGroup {
//    for line in lines {
//        for group in availableGroups {
//            for category in group {
//                if line.matches(pattern: category.declarationPattern) {
//                    return group
//                }
//            }
//        }
//    }
//
//    return .init()
//}
-(NSMutableArray<ImportCategory*>*)group:(NSMutableArray<NSString*>*)lines :(NSMutableArray<NSMutableArray<ImportCategory*>*>*)availableGroups
{
    NSMutableArray<ImportCategory*>* s =[[NSMutableArray alloc]init];
//    for(NSString *line in lines)
//    {
//        for(NSMutableArray<ImportCategory*>* group in availableGroups)
//        {
//            for(ImportCategory * category in group)
//            {
//                
//            }
//        }
//    }
    return s;
}

@end

@implementation ImportCategory

@end
