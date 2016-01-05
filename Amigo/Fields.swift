//
//  Fields.swift
//  Amigo
//
//  Created by Adam Venturella on 1/3/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation

public class UUIDField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .BinaryDataAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }

    public override func serialize(value: AnyObject?) -> AnyObject?{
        let string: String

        if let defaultValue = defaultValue where value == nil{
            if let candidate = defaultValue() as? String{
                string = candidate
            } else {
                return nil
            }
        } else if let candidate = value as? String{
            string = candidate
        } else {
            return nil
        }

        guard let uuid = NSUUID(UUIDString: string) else {
            return nil
        }

        var bytes = [UInt8](count: 16, repeatedValue: 0)
        uuid.getUUIDBytes(&bytes)

        return NSData(bytes: bytes, length: bytes.count)
    }

    public override func deserialize(value: AnyObject?) -> AnyObject?{
        guard let value = value as? NSData else {
            return nil
        }

        var bytes = [UInt8](count: 16, repeatedValue: 0)
        value.getBytes(&bytes, length: bytes.count)

        let uuid = NSUUID(UUIDBytes: bytes).UUIDString
        return uuid
    }
}

public class CharField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .StringAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}

public class BooleanField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .BooleanAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}

public class IntegerField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .Integer64AttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}

public class FloatField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .FloatAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}

public class DoubleField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .DoubleAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}

public class BinaryField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .BinaryDataAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}

public class DateTimeField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false, defaultValue: (()-> AnyObject?)? = nil) {
        self.init(label, type: .DateAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique, defaultValue: defaultValue)
    }
}