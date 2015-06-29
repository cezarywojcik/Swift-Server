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
    subscript (i : Int) -> Character {
        return self[advance(self.startIndex, i)]
    }

    subscript (r : Range<Int>) -> String {
        return String(self.characters[Range(start: advance(self.startIndex,
            r.startIndex), end: advance(self.startIndex, r.endIndex))])
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

