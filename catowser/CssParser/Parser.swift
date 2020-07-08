//
//  Parser.swift
//  mutatali
//
//  Created by Ahmad Alhashemi on 2017-03-25.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

enum StyleSheetComponent {
    case atRule(AtRule)
    case qualifiedRule(QualifiedRule)
    case declaration(Declaration)
    case componentValue(ComponentValue)
}

struct AtRule {
    let name: String
    let prelude: [ComponentValue]
    let block: SimpleBlock?
}

struct QualifiedRule {
    let prelude: [ComponentValue]
    let block: SimpleBlock
}

struct Declaration {
    enum Category {
        case property, descriptor
    }
    let name: String
    let value: [ComponentValue]
    let important = false
    let category: Category
}

enum ComponentValue {
    case preservedToken(Token)
    case function(Function)
    case simpleBlock(SimpleBlock)
}

struct Function {
    let name: String
    let value: [ComponentValue]
}

struct SimpleBlock {
    let token: Token
    let value: [ComponentValue]
}

class Parser {
    let tokens: [Token]
    var cursor = 0
    
    private var current: Token {
        if cursor >= tokens.count {
            return .eof
        }
        return tokens[cursor]
    }
    
    private var next: Token {
        if (cursor + 1) >= tokens.count {
            return .eof
        }
        return tokens[cursor + 1]
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func advance() {
        cursor = max(cursor + 1, tokens.count)
    }
    
    func putback() {
        cursor -= 1
    }
}
