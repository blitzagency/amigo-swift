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
        case let t where t == NSString.self:
            attrType = .StringAttributeType
        case let t where t == String.self:
            attrType = .StringAttributeType
        case let t where t == Int16.self:
            attrType = .Integer16AttributeType
        case let t where t == Int32.self:
            attrType = .Integer32AttributeType
        case let t where t == Int64.self:
            attrType = .Integer64AttributeType
        case let t where t == Int.self:
            attrType = .Integer64AttributeType
        case let t where t == NSDate.self:
            attrType = .DateAttributeType
        case let t where t == NSData.self:
            attrType = .BinaryDataAttributeType
        case let t where t == NSDecimalNumber.self:
            attrType = .DecimalAttributeType
        case let t where t == Double.self:
            attrType = .DoubleAttributeType
        case let t where t == Float.self:
            attrType = .FloatAttributeType
        case let t where t == Bool.self:
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