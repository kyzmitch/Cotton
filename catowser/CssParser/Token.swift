//
//  Token.swift
//  mutatali
//
//  Created by Ahmad Alhashemi on 2017-03-22.
//  Copyright © 2017 Ahmad Alhashemi. All rights reserved.
//

public enum Token {
    public enum HashType {
        case id, unrestricted
    }
    
    public enum NumberType {
        case integer, number
    }
    
    case ident(value: String)
    case function(value: String)
    case atKeyword(value: String)
    case hash(value: String, type: HashType)
    case string(value: String)
    case url(value: String)
    
    case delim(value: Character)
    
    case number(repr: String, numeric: Double, type: NumberType)
    case percentage(repr: String, numeric: Double)
    case dimention(repr: String, numeric: Double, type: NumberType, unit: String)
    
    case unicodeRange(start: Int, end: Int)
    
    case badString
    case badUrl
    case includeMatch
    case dashMatch
    case prefixMatch
    case suffixMatch
    case substringMatch
    case column
    case whitespace
    case cdo
    case cdc
    case colon
    case semicolon
    case comma
    case leftSquare
    case rightSquare
    case leftParen
    case rightParen
    case leftBrace
    case rightBrace
    
    case eof
}
