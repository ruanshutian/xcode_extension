//
//  SourceEditorCommand.swift
//  ZExtension
//
//  Created by Aron Ruan on 2022/4/15.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.

        let linesToSort = invocation.buffer.lines.filter { line in
            return (line as? String)?.hasPrefix("import") ?? false
        }
        
        print(linesToSort)

        guard linesToSort.count > 0 else {
            completionHandler(nil)
            return
        }

        let firstLineIndex = invocation.buffer.lines.index(of: linesToSort[0]) // For insert
        guard firstLineIndex >= 0 else {
            completionHandler(nil)
            return
        }
        invocation.buffer.lines.removeObjects(in: linesToSort)
        let linesSorted = (linesToSort as? [String] ?? []).sorted() {$0 <= $1}
        linesSorted.reversed().forEach { (line) in
            invocation.buffer.lines.insert(line, at: firstLineIndex)
        }
        let selectionsUpdated: [XCSourceTextRange] = (0..<linesSorted.count).map { (index) in
            let lineIndex = firstLineIndex + index
            let endColumn = linesSorted[index].count - 1
            return XCSourceTextRange(start: XCSourceTextPosition(line: lineIndex, column: 0), end: XCSourceTextPosition(line: lineIndex, column: endColumn))
        }
        invocation.buffer.selections.setArray(selectionsUpdated)
        completionHandler(nil)
    }
    
}
