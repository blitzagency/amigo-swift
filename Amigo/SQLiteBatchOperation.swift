//
//  SQLiteBatchOperation.swift
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation


public class SQLiteBatchOperation: BatchOperation{

    let session: AmigoSession
    var insertCache = [String: [String]]()
    var upsertCache = [String: [String]]()
    var updateCache = [String: [String]]()
    var deleteCache = [String: [String]]()
    var statements = ""

    public required init(session: AmigoSession){
        self.session = session
    }

    public func add<T: AmigoModel>(obj: T) {
       add(obj, upsert: false)
    }

    public func add<T: AmigoModel>(obj: T, upsert isUpsert: Bool = false) {

        let action = session.addAction(obj)

        if action == .Insert {
            statements = statements + buildInsert(obj, upsert: isUpsert) + "\n"
        } else {
            statements = statements + buildUpdate(obj) + "\n"
        }
    }

    public func execute(){
        session.engine.execute(statements)
    }

    func buildUpdate<T: AmigoModel>(obj: T) -> String {
        let model = obj.amigoModel
        let fragments: [String]
        let sqlParams = session.insertParams(obj)
        let params = sqlParams.queryParams + [model.primaryKey.modelValue(obj)!]


        if let parts = updateCache[obj.qualifiedName] {
            fragments = parts
        } else {
            let (sql, _) = session.updateSQL(obj)
            let parts = sql.componentsSeparatedByString("?")

            updateCache[obj.qualifiedName] = parts
            fragments = parts
        }

        var sql = ""
        let escaped = params.map(escape)

        escaped.enumerate().forEach{ index, part in
            sql = sql + fragments[index] + part
        }

        sql = sql + fragments.last!
        return sql

    }

    func buildInsert<T: AmigoModel>(value: T, upsert isUpsert: Bool = false) -> String {
        let fragments: [String]
        let values = session.insertParams(value, upsert: isUpsert)
        var cache = isUpsert ? upsertCache : insertCache

        if let parts = cache[value.qualifiedName] {
            fragments = parts
        } else {
            let model = value.amigoModel
            let sql = isUpsert ? session.upsertSQL(model) : session.insertSQL(model)
            let parts = sql.componentsSeparatedByString("?")

            cache[value.qualifiedName] = parts

            if isUpsert{
                upsertCache = cache
            } else {
                insertCache = cache
            }

            fragments = parts
        }

        var sql = ""
        let escaped = values.queryParams.map(escape)

        escaped.enumerate().forEach{ index, part in
            sql = sql + fragments[index] + part
        }

        sql = sql + fragments.last!
        return sql
    }

    func escape(value: AnyObject) -> String{

        if let string = value as? String {
            return SQLiteFormat.escapeWithQuotes(string)
        }

        if let _ = value as? NSNull{
            let result = SQLiteFormat.escapeWithQuotes(nil)
            return result
        }

        return SQLiteFormat.escapeWithoutQuotes(String(value))
    }
    
    
}