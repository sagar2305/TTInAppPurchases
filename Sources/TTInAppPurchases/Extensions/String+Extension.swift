//
//  String+Extension.swift
//  CallRecorder
//
//  Created by Sandesh on 13/10/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
public extension String {
    subscript (offset: Int) -> Character {
        return self[index(startIndex, offsetBy: offset)]
    }
    
    func levenshtein(_ other: String) -> Int {
        let sCount = self.count
        let oCount = other.count

        guard sCount != 0 else {
            return oCount
        }

        guard oCount != 0 else {
            return sCount
        }

        let line: [Int]  = Array(repeating: 0, count: oCount + 1)
        var mat: [[Int]] = Array(repeating: line, count: sCount + 1)

        for iIndex in 0...sCount {
            mat[iIndex][0] = iIndex
        }

        for jIndex in 0...oCount {
            mat[0][jIndex] = jIndex
        }

        for jIndex in 1...oCount {
            for iIndex in 1...sCount {
                if self[iIndex - 1] == other[jIndex - 1] {
                    mat[iIndex][jIndex] = mat[iIndex - 1][jIndex - 1]       // no operation
                } else {
                    let del = mat[iIndex - 1][jIndex] + 1         // deletion
                    let ins = mat[iIndex][jIndex - 1] + 1         // insertion
                    let sub = mat[iIndex - 1][jIndex - 1] + 1     // substitution
                    mat[iIndex][jIndex] = min(min(del, ins), sub)
                }
            }
        }

        return mat[sCount][oCount]
    }
    
    var alphanumericWithSpaces: String {
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(" ")
        return self.components(separatedBy: allowedCharacters.inverted).joined(separator: "")
    }
    
    var localized: String {
        let string = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        return string
    }
    
    var removeLeadingTrailingWhitespacesNewlines: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var removeAllWhitespacesAndNewlines: String {
        return self.filter { !" \n\t\r".contains($0) }
    }
    
    func createRandomLettersArray(count: Int) -> [String.Element] {
        var lastChars = [String.Element]()
        let movieNameWithoutSpaces = self.removeAllWhitespacesAndNewlines.uppercased()
        var alphabets = (0..<26).map({Character(UnicodeScalar("A".unicodeScalars.first!.value + $0)!)})
        // don't repeat characters in movie title
        alphabets = alphabets.filter({ !movieNameWithoutSpaces.contains($0) })
        
        if count >= movieNameWithoutSpaces.count {
            let sequences = (0..<count - movieNameWithoutSpaces.count).map { _ -> String in
                let radomLetter = Int.random(in: 0..<alphabets.count)
                return String(alphabets[radomLetter])
            }
            
            lastChars = sequences.compactMap { $0.last }
            lastChars.append(contentsOf: movieNameWithoutSpaces)
            lastChars.shuffle()
        }
        
        return lastChars
    }
    
    /// stringToFind must be at least 1 character.
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: stringToFind, options: [], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
    
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
