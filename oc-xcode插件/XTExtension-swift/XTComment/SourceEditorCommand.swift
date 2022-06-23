//
//  SourceEditorCommand.swift
//  XTComment
//
//  Created by Aron Ruan on 2022/4/14.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        var lineIndexes = [Int]()
        for range in invocation.buffer.selections {
            guard let range = range as? XCSourceTextRange else {
                continue
            }
            let start = range.start
            let end = range.end
            for i in start.line...end.line {
                lineIndexes.append(i)
            }
        }
        lineIndexes.reverse()
        for lineNumber in lineIndexes {
            guard let line = invocation.buffer.lines[lineNumber] as? NSString else {
                continue
            }
            let commentLine = NSString(format: "// %@", line)
            invocation.buffer.lines.insert(commentLine, at: lineNumber)
            }
        completionHandler(nil)
    }
    
}
