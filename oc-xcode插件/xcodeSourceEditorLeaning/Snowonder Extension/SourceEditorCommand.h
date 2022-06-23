//
//  SourceEditorCommand.h
//  Snowonder Extension
//
//  Created by Aron Ruan on 2022/5/5.
//

#import <XcodeKit/XcodeKit.h>

@interface SourceEditorCommand : NSObject <XCSourceEditorCommand>

@end
@interface ImportBlock : NSObject

@end
@interface ImportCategory : NSHashTable

@property(nonatomic)NSString *title;
@property(nonatomic)NSString *declarationPattern;
@property(nonatomic)CFComparisonResult * sortingComparisonResult;

@end
@interface ImportBlockDetector : NSObject
-(NSMutableArray<ImportCategory*>*)group:(NSMutableArray<NSString*>*)lines :(NSMutableArray<NSMutableArray<ImportCategory*>*>*)availableGroups;

@end


