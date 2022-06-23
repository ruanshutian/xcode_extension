//
//  XcodeExtensionSampleHelper.swift
//  Extension
//
//  Created by Aron Ruan on 2022/4/16.
//

import Foundation
@objc class XcodeExtensionSampleHelper: NSObject, XcodeExtensionSampleHelperProtocol {
    func write(text: String, to directory: String, reply: @escaping HelperResultHandler) {

        try? text.write(
            toFile: directory + "/outputFile",
            atomically: true, encoding: .utf8
        )

        reply(0)
    }
}

