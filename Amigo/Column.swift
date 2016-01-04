//
//  Column.swift
//  Amigo
//
//  Created by Adam Venturella on 7/3/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public func ==(lhs: Column, rhs: Column) -> Bool {
    return lhs.hashValue == rhs.hashValue
}


public class Column: SchemaItem, CustomStringConvertible, Hashable{

    public let label: String
    public let type: NSAttributeType
    public let primaryKey: Bool
    public let indexed: Bool
    public let unique: Bool
    public var optional: Bool

    public var hashValue: Int{
        return description.hashValue
    }

    var _foreignKey: ForeignKey?
    public var foreignKey: ForeignKey? {
        get{
            return _foreignKey
        }
    }

    var _table: Table? {
        didSet{
            _qualifiedLabel = "\(_table!.label).\(label)"
        }
    }

    public var table: Table? {
        return _table
    }

    var _qualifiedLabel: String?
    public var qualifiedLabel: String? {
        return _qualifiedLabel
    }

    public init(_ label: String, type: NSAttributeType, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false){
        self.label = label
        self.type = type
        self.primaryKey = primaryKey
        self.indexed = indexed
        self.optional = optional
        self.unique = unique
    }

    public convenience init(_ label: String, type: Any.Type, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false){
        let attrType: NSAttributeType

        switch type{
        case is NSString.Type:
            attrType = .StringAttributeType
        case is String.Type:
            attrType = .StringAttributeType
        case is Int16.Type:
            attrType = .Integer16AttributeType
        case is Int32.Type:
            attrType = .Integer32AttributeType
        case is Int64.Type:
            attrType = .Integer64AttributeType
        case is Int.Type:
            attrType = .Integer64AttributeType
        case is NSDate.Type:
            attrType = .DateAttributeType
        case is [UInt8].Type:
            attrType = .BinaryDataAttributeType
        case is NSData.Type:
            attrType = .BinaryDataAttributeType
        case is NSDecimalNumber.Type:
            attrType = .DecimalAttributeType
        case is Double.Type:
            attrType = .DoubleAttributeType
        case is Float.Type:
            attrType = .FloatAttributeType
        case is Bool.Type:
            attrType = .BooleanAttributeType
        default:
            attrType = .UndefinedAttributeType
        }

        self.init(label, type: attrType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)

    }

    public convenience init(_ label: String, type: ForeignKey, primaryKey: Bool = false, indexed: Bool = true, optional: Bool = true, unique: Bool = false){
        let columnLabel: String

        if let range = label.rangeOfString("_id", options:.BackwardsSearch){
            if range.endIndex == label.endIndex{
                columnLabel = label
            }else {
                columnLabel = "\(label)_id"
            }
        } else {
            columnLabel = "\(label)_id"
        }

        let associatedType = type.relatedColumn.type
        self.init(columnLabel, type: associatedType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
        _foreignKey = ForeignKey(type.relatedColumn, column: self)
    }


    public var description: String {
        if let t = table{
            return "<Column<\(t.label)>:\(label), primaryKey:\(primaryKey), indexed: \(indexed), optional: \(optional), unique:\(unique)>"
        } else {
            return "<Column:\(label), primaryKey:\(primaryKey), indexed: \(indexed), optional: \(optional), unique:\(unique)>"
        }

    }
}