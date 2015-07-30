//
//  ForeignKey.swift
//  Amigo
//
//  Created by Adam Venturella on 7/3/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation

public struct ForeignKey{
    public let relatedColumn: Column
    public var column: Column!

    public init(_ relatedColumn: Column, column: Column){
        self.relatedColumn = relatedColumn
        self.column = column
    }

    public init(_ relatedColumn: Column){
        self.relatedColumn = relatedColumn
    }

    public init(_ table: Table){
        self.relatedColumn = table.primaryKey!
    }

    public var relatedTable: Table{
        return relatedColumn.table!
    }
}
//public struct ForeignKey : CustomStringConvertible{
//    public let label: String
//    public let type: Any.Type
//    public let relatedType: AmigoModel.Type
//    public let optional: Bool
//
//    public var description: String {
//        return "<ForeignKey: \(label) toOne:\(relatedType) optional: \(optional)>"
//    }
//}