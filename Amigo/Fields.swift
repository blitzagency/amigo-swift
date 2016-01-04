//
//  Fields.swift
//  Amigo
//
//  Created by Adam Venturella on 1/3/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation

public class UUIDField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false) {
        self.init(label, type: .BinaryDataAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
    }

    public override func serialize(value: AnyObject?) -> AnyObject?{
        guard let value = value as? String else {
            return nil
        }

        let uuid = NSUUID(UUIDString: value)!
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
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false) {
        self.init(label, type: .StringAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
    }
}

public class BooleanField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false) {
        self.init(label, type: .BooleanAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
    }
}

public class IntegerField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false) {
        self.init(label, type: .Integer64AttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
    }
}

public class FloatField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false) {
        self.init(label, type: .FloatAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
    }
}

public class DoubleField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false) {
        self.init(label, type: .DoubleAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
    }
}

public class BinaryField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false) {
        self.init(label, type: .BinaryDataAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
    }
}

public class DateTimeField: Column{
    public convenience init(_ label: String, primaryKey: Bool = false, indexed: Bool = false, optional: Bool = true, unique: Bool = false) {
        self.init(label, type: .DateAttributeType, primaryKey: primaryKey, indexed: indexed, optional: optional, unique: unique)
    }
}