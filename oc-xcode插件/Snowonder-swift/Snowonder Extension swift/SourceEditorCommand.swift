//
//  SourceEditorCommand.swift
//  Snowonder Extension swift
//
//  Created by Aron Ruan on 2022/5/5.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        var error: Error? = nil
        
        if let lines = invocation.buffer.lines as? [String] {
            do {
                let detector = ImportBlockDetector()
                let importBlock = try detector.importBlock(from: lines)
                let formatter = ImportBlockFormatter()
                let formattedImportLines = formatter.lines(for: importBlock, using: ImportBlockFormatter.Operation.all)

                let bufferEditor = SourceTextBufferEditor(buffer: invocation.buffer)
                bufferEditor.replace(lines: importBlock.declarations, with: formattedImportLines, using: .top)
            } catch let catchedError {
                error = catchedError
            }
        }
        
        completionHandler(error)
    }
    
}
