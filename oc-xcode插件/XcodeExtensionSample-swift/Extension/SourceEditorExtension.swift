//
//  SourceEditorExtension.swift
//  Extension
//
//  Created by Aron Ruan on 2022/4/16.
//

import Foundation
import XcodeKit
//import Foundation

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */
    

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        print("-----",PasteboardOutputCommand.commandDefinition)
//        print(PasteboardInputCommand.commandDefinition);
//        print(OpenAppCommand.commandDefinition);
//        print(URLSchemeCommand.commandDefinition);
        return [
            PasteboardOutputCommand.commandDefinition,
            PasteboardInputCommand.commandDefinition,
            OpenAppCommand.commandDefinition,
            URLSchemeCommand.commandDefinition,
            LocalCommandCommand.commandDefinition,
            NetworkCommand.commandDefinition,
            ToDesktopCommand1.commandDefinition,
            ToDesktopCommand2.commandDefinition,
            FileSelectionCommand.commandDefinition,
        ]
    }
    
}
