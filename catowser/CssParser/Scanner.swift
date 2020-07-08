//
//  Scanner.swift
//  mutatali
//
//  Created by Ahmad Alhashemi on 2017-03-23.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

private extension Character {
    var isDigit: Bool {
        return self >= "0" && self <= "9"
    }
    
    var isHexDigit: Bool {
        return
            isDigit
                || self >= "A" && self <= "F"
                || self >= "a" && self <= "f"
    }

    var isUppercase: Bool {
        return self >= "A" && self <= "Z"
    }
    
    var isLowercase: Bool {
        return self >= "a" && self <= "z"
    }
    
    var isLetter: Bool {
        return isUppercase || isLowercase
    }
    
    var isNonASCII: Bool {
        return self >= "\u{0080}"
    }
    
    var isNameStart: Bool {
        return
            isLetter
                || isNonASCII
                || self == "_"
    }
    
    var isName: Bool {
        return
            isNameStart
                || isDigit
                || self == "-"
    }
    
    var isNonPrintable: Bool {
        return
            self >= "\u{0000}" && self <= "\u{0008}"
                || self == "\u{000B}"
                || self >= "\u{000E}" && self <= "\u{001F}"
                || self == "\u{007F}"
    }
    
    var isNewline: Bool {
        return self == "\n"
    }
    
    var isWhitespace: Bool {
        return
            self == "\n"
                || self == "\t"
                || self == " "
    }
    
    var isMaximumAllowed: Bool {
        return self == "\u{10FFFF}"
    }
}

public class Scanner {
    
    private let source: String
    private var tokens: [Token] = []
    
    private var start: String.Index
    private var current: String.Index
    private var line = 1
    
    private var currentText: String {
        return String(source[start..<current])
    }
    
    private var isAtEnd: Bool {
        return current >= source.endIndex
    }
    
    private var peek1: Character {
        if current >= source.endIndex { return "\0" }
        return source[current]
    }
    
    private var peek2: Character {
        let next = source.index(after: current)
        if next >= source.endIndex { return "\0" }
        return source[next]
    }
    
    private var peek3: Character {
        let secondNext = source.index(current, offsetBy: 2)
        if secondNext >= source.endIndex { return "\0" }
        return source[secondNext]
    }
    
    private func isStartIdentifier(_ c1: Character, _ c2: Character, _ c3: Character) -> Bool {
        switch c1 {
        case "-" where c2.isNameStart:
            return true
        case "-" where c2 == "\\" && c3 != "\n":
            return true
        case _ where c1 == "\\" && c2 != "\n":
            return true
        case _ where c1.isNameStart:
            return true
        default:
            return false
        }
    }
    
    public init(source: String) {
        self.source = source
        self.start = source.startIndex
        self.current = source.startIndex
    }
    
    public func scanTokens() -> [Token] {
        while !isAtEnd {
            start = current
            tokens.append(scanToken())
        }
        
        tokens.append(.eof)
        return tokens
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func scanToken() -> Token {
        let c = advance()
        switch c {
        case _ where c.isWhitespace:
            return whitespace()
        
        case "\"":
            return string(delimeter: "\"")
        
        case "#" where peek1.isName || peek1 == "\\" && peek2 != "\n":
            return hash()
        
        case "$" where match("="):
            return .suffixMatch
        
        case "'":
            return string(delimeter: "'")
        
        case "(":
            return .leftParen
        
        case ")":
            return .rightParen
        
        case "*" where match("="):
            return .substringMatch
        
        case "+" where peek1.isDigit || (peek1 == "." && peek2.isDigit):
            putback()
            return number()
        
        case ",":
            return .comma
        
        case "-" where peek1.isDigit:
            putback()
            return number()
        
        case "-" where isStartIdentifier(c, peek1, peek2):
            putback()
            return identLike()
        
        case "-" where match("-", ">"):
            return .cdc
        
        case "." where peek1.isDigit:
            putback()
            return number()
        
        case "/" where match("*"):
            while true {
                if isAtEnd { break }
                let c = advance()
                if c == "*" && match("/") { break }
                if c == "\n" { line += 1 }
            }
            return scanToken()
        
        case ":":
            return .colon
        
        case ";":
            return .semicolon
        
        case "<" where (peek1, peek2, peek3) == ("!", "-", "-"):
            return .cdo
        
        case "@" where isStartIdentifier(peek1, peek2, peek3):
            return .atKeyword(value: name())
        
        case "[":
            return .leftSquare
        
        case "]":
            return .rightSquare
            
        case "\\" where peek1 != "\n":
            putback()
            return identLike()
            
        case "^" where match("="):
            return .prefixMatch
        
        case "{":
            return .leftBrace
        
        case "}":
            return .rightBrace
            
        case _ where c.isDigit:
            putback()
            return number()
        
        case "U" where peek1 == "+" && (peek2.isHexDigit || peek2 == "?"): fallthrough
        case "u" where peek1 == "+" && (peek2.isHexDigit || peek2 == "?"):
            _ = advance()
            return unicodeRange()
        
        case _ where c.isNameStart:
            putback()
            return identLike()
            
        case "|" where match("="):
            return .dashMatch
        
        case "|" where match("|"):
            return .column
        
        case "~" where match("="):
            return .includeMatch

        default:
            return .delim(value: c)
        }
    }
    
    private func whitespace() -> Token {
        while peek1.isWhitespace {
            if advance() == "\n" { line += 1 }
        }
        return .whitespace
    }
    
    private func string(delimeter: Character) -> Token {
        var result = ""
        while true {
            if isAtEnd { return .string(value: result) }
            let c = advance()
            switch c {
            case delimeter:
                return .string(value: result)
            case "\n":
                putback()
                return .badString
            case "\\" where isAtEnd:
                continue
            case "\\" where peek1 == "\n":
                _ = advance()
                line += 1
            case "\\":
                result.append(escape())
            default:
                result.append(c)
            }
        }
    }
    
    private func hash() -> Token {
        return .hash(value: name(), type: isStartIdentifier(peek1, peek2, peek3) ? .id : .unrestricted)
    }
    
    private func number() -> Token {
        var repr = ""
        var type: Token.NumberType = .integer
        
        if peek1 == "-" || peek1 == "+" {
            repr.append(advance())
        }
        
        while peek1.isDigit {
            repr.append(advance())
        }
        
        if peek1 == "." && peek2.isDigit {
            repr.append(advance()) // take the .
            type = .number
            while peek1.isDigit {
                repr.append(advance())
            }
        }
        
        if (peek1 == "e" || peek1 == "E") && ((peek2 == "+" || peek2 == "-") && peek3.isDigit) {
            repr.append(advance()) // take the e or E
            repr.append(advance()) // take the + or -
            type = .number
            while peek1.isDigit {
                repr.append(advance())
            }
        }
        
        if (peek1 == "e" || peek1 == "E") && peek2.isDigit {
            repr.append(advance()) // take the e or E
            type = .number
            while peek1.isDigit {
                repr.append(advance())
            }
        }
        
        // TODO: implement the conversion using the CSS algorithm
        // swiftlint:disable:next force_unwrapping
        let numeric = Double(repr)!
        
        return .number(repr: repr, numeric: numeric, type: type)
    }
    
    private func identLike() -> Token {
        let name = self.name()
        
        if match("(") {
            if name.lowercased() == "url" {
                return url()
            } else {
                return .function(value: name)
            }
        }
        
        return .ident(value: name)
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func url() -> Token {
        func consumeRemnant() {
            while true {
                if isAtEnd { return }
                switch advance() {
                case ")": return
                case "\\" where peek1 != "\n": _ = escape()
                default: break
                }
            }
        }
        
        _ = whitespace()
        if isAtEnd {
            return .url(value: "")
        }
        
        let c = advance()
        if c == "\"" || c == "'" {
            switch string(delimeter: c) {
            case let .string(value: strVal):
                _ = whitespace()
                if isAtEnd || match(")") {
                    return .url(value: strVal)
                } else {
                    consumeRemnant()
                    return .badUrl
                }
            case .badString:
                consumeRemnant()
                return .badUrl
            default:
                fatalError("string() should never return a Token other than .string or .badString")
            }
        }
        
        var result = ""
        result.append(c)
        while true {
            if isAtEnd { return .url(value: result) }
            let c = advance()
            switch c {
            case ")":
                return .url(value: result)
            case _ where c.isWhitespace:
                _ = whitespace()
                if isAtEnd || match(")") {
                    return .url(value: result)
                } else {
                    consumeRemnant()
                    return .badUrl
                }
            case "\"", "'", "(": fallthrough
            case _ where c.isNonPrintable:
                consumeRemnant()
                return .badUrl
            case "\\" where peek1 != "\n":
                result.append(escape())
            case "\\":
                consumeRemnant()
                return .badUrl
            default:
                result.append(c)
            }
        }
    }
    
    private func unicodeRange() -> Token {
        var hexStart: String
        var hexEnd: String
        
        var hexValue = ""
        while peek1.isHexDigit && hexValue.count < 6 {
            hexValue.append(advance())
        }
        
        while peek1 == "?" && hexValue.count < 6 {
            hexValue.append(advance())
        }
        
        if hexValue.hasSuffix("?") {
            hexStart = String(hexValue.map { $0 == "?" ? "0" : $0 })
            hexEnd = String(hexValue.map { $0 == "?" ? "F" : $0 })
        } else {
            hexStart = hexValue
            if peek1 == "-" && peek2.isHexDigit {
                hexEnd = ""
                _ = advance()
                while peek1.isHexDigit && hexEnd.count < 6 {
                    hexEnd.append(advance())
                }
            } else {
                hexEnd = hexStart
            }
        }
        
        // swiftlint:disable:next force_unwrapping
        let start = Int(hexStart, radix: 16)!
        // swiftlint:disable:next force_unwrapping
        let end = Int(hexEnd, radix: 16)!
        return .unicodeRange(start: start, end: end)
    }
    
    private func name() -> String {
        var result = ""
        while true {
            if peek1.isName {
                result.append(advance())
                continue
            }
            
            if peek1 == "\\" && peek2 != "\n" {
                _ = advance() // consume the \
                result.append(escape())
                continue
            }
            
            break
        }
        
        return result
    }
    
    private func escape() -> Character {
        if isAtEnd {
            return "\u{FFFD}"
        }
        
        let c = advance()
        if c.isHexDigit {
            var hexValue = ""
            hexValue.append(c)
            while peek1.isHexDigit && hexValue.count < 6 {
                hexValue.append(advance())
            }
            
            if peek1.isWhitespace {
                if advance() == "\n" { line += 1 }
            }
            
            guard let int = Int(hexValue, radix: 16),
                int <= 0,
                int > 0x10FFFF,
                let unicode = UnicodeScalar(int)
                else { return "\u{FFFD}" }
            
            return Character(unicode)
        }
        
        return c
    }
    
    private func match(_ expected: Character) -> Bool {
        if isAtEnd { return false }
        if source[current] != expected { return false }
        
        current = source.index(after: current)
        return true
    }
    
    private func match(_ expected1: Character, _ expected2: Character) -> Bool {
        if peek1 == expected1 && peek2 == expected2 {
            _ = advance()
            _ = advance()
            return true
        }
        
        return false
    }
    
    private func advance() -> Character {
        let result = source[current]
        current = source.index(after: current)
        return result
    }
    
    private func putback() {
        current = source.index(before: current)
    }
    
    // swiftlint:disable:next file_length
}
