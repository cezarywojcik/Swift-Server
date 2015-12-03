/**
 * File: utils.swift
 * Desc: Some utility functions
 * Auth: Cezary Wojcik
 */

// ---- [ helper functions ] --------------------------------------------------

@noreturn func fatalError(message : String) {
    print(message)
    let errorCode = errno
    guard let text = String.fromCString(UnsafePointer(strerror(errorCode)))
        else {
        print("\(errorCode): Unknown error.")
        exit(2)
    }
    print("\(errorCode): \(text)")
    exit(2)
}

// ---- [ extensions ] --------------------------------------------------------

extension String {

    subscript (i: Int) -> Character {
        guard i < self.characters.count else { return characters.last }
        return self[startIndex.advancedBy(i, limit: endIndex)]
    }

    subscript (r: Range<Int>) -> String {
        return String(self.characters[Range(start: self.startIndex.advancedBy(r.startIndex, limit: self.endIndex),
            end: self.startIndex.advancedBy(r.endIndex, limit: self.endIndex))])
    }

    func indexOf(searchString : String) -> Int {
        // TODO: find a better way to do this
        for i in 0..<(self.characters.count - searchString.characters.count) {
            let substring = self[i..<i + searchString.characters.count]
            if searchString == substring {
                return i
            }
        }
        return -1
    }
}
