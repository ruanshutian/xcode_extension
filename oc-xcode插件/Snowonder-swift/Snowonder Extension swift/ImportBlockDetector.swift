//
//  ImportDetector.swift
//  Snowonder
//
//  Created by Aliaksei Karetski on 19.06.17.
//  Copyright © 2017 Karetski. All rights reserved.
//

import Foundation

extension String {
    
    func matches(pattern: String) -> Bool {
        guard let regularExpression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return false
        }

        let matchingStrings = regularExpression.matches(in: self, range: NSMakeRange(0, count))
        return !matchingStrings.isEmpty
    }
}

public enum ImportBlockDetectorError: Error {
    case notFound
}

open class ImportBlockDetector {
    
    // MARK: - Constant values
    
    private struct Constant { // TODO: Init these values from JSON on detector init. #13
        static let allGroups: [ImportCategoriesGroup] = [swiftGroup, objcGroup]
        
        static let swiftGroup: ImportCategoriesGroup = [
            ImportCategory(title: "Framework", declarationPattern: "^\\s*(import) +.*.", sortingComparisonResult: .orderedAscending),
            ImportCategory(title: "Testable", declarationPattern: "^\\s*(@testable \\s*import) +.*.", sortingComparisonResult: .orderedAscending)
        ]
        static let objcGroup: ImportCategoriesGroup = [
            ImportCategory(title: "Module", declarationPattern: "^\\s*(@import) +.*.", sortingComparisonResult: .orderedAscending),
            ImportCategory(title: "Global", declarationPattern: "^\\s*(#import) \\s*<.*>.*", sortingComparisonResult: .orderedAscending),
            ImportCategory(title: "Global Include", declarationPattern: "^\\s*(#include) \\s*<.*>.*", sortingComparisonResult: .orderedAscending),
            ImportCategory(title: "Local", declarationPattern: "^\\s*(#import) \\s*\".*\".*", sortingComparisonResult: .orderedAscending),
            ImportCategory(title: "Local Include", declarationPattern: "^\\s*(#include) \\s*\".*\".*", sortingComparisonResult: .orderedAscending)
        ]
    }
    
    // MARK: - Initializers
    
    public init() { }
    
    // MARK: - Detection functions
    
    /// Creates new import block based on `lines` parameter.
    ///
    /// - Parameters:
    ///   - lines: Lines used to detect import declarations.
    /// - Throws: Error if import declarations can't be found.
    open func importBlock(from lines: [String]) throws -> ImportBlock {
        let group = self.group(for: lines, using: Constant.allGroups)

        guard !group.isEmpty else {
            throw ImportBlockDetectorError.notFound
        }

        let declarations = self.declarations(from: lines, using: group)
        let categorizedDeclarations = self.categorizedDeclarations(from: declarations, using: group)
        
        return .init(group: group, declarations: declarations, categorizedDeclarations: categorizedDeclarations)
    }
    
    /// Constructs import categories based on `lines` parameter.
    ///
    /// - Parameter lines: Lines used to construct import categories.
    /// - Returns: Constructed import declarations based on `lines` parameter.
    open func group(for lines: [String], using availableGroups: [ImportCategoriesGroup]) -> ImportCategoriesGroup {
        for line in lines {
            for group in availableGroups {
                for category in group {
                    if line.matches(pattern: category.declarationPattern) {
                        return group
                    }
                }
            }
        }

        return .init()
    }
    
    /// Detects import declarations based on `lines` parameter using import categories `group`.
    ///
    /// - Parameters:
    ///   - lines: Lines used to detect import declarations.
    ///   - group: Import categories group used to detect import declarations.
    /// - Returns: Detected import declarations.
    open func declarations(from lines: [String], using group: ImportCategoriesGroup) -> ImportDeclarations {
        return lines.filter { (line) -> Bool in
            var matches = false
            
            for category in group {
                matches = line.matches(pattern: category.declarationPattern)
                if matches {
                    break
                }
            }
            
            return matches
        }
    }

    /// Detects import declarations based on `lines` parameter and groupes it by import category using `group` parameter.
    ///
    /// - Parameters:
    ///   - lines: Lines used to detect and categorize import declarations.
    ///   - group: Import categories group used to detect and categorize import declarations.
    /// - Returns: Grouped by category import declarations.
    open func categorizedDeclarations(from lines: [String], using group: ImportCategoriesGroup) -> CategorizedImportDeclarations {
        var categorizedDeclarations = CategorizedImportDeclarations()
        
        for line in lines {
            for category in group {
                if line.matches(pattern: category.declarationPattern) {
                    if let _ = categorizedDeclarations[category] {
                        categorizedDeclarations[category]!.append(line)
                    } else {
                        categorizedDeclarations[category] = [line]
                    }
                }
            }
        }
        
        return categorizedDeclarations
    }
}
