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

            // deny an update for a model without a primary key
            guard let _ = obj.amigoModel.primaryKey.modelValue(obj) else {
                return
            }

            statements = statements + buildUpdate(obj) + "\n"
        }
    }

    public func delete<T: AmigoModel>(obj: T){
        // deny an delete for a model without a primary key
        guard let _ = obj.amigoModel.primaryKey.modelValue(obj) else {
            return
        }

        statements = statements + buildDelete(obj) + "\n"
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

        let sql = buildSQL(fragments, params: params)
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

        let sql = buildSQL(fragments, params: values.queryParams)
        return sql
    }

    func buildDelete<T: AmigoModel>(obj: T) -> String {
        let model = obj.amigoModel
        let fragments: [String]
        let params = [model.primaryKey.modelValue(obj)!]

        if let parts = deleteCache[obj.qualifiedName] {
            fragments = parts
        } else {
            let (sql, _) = session.deleteSQL(obj)
            let parts = sql.componentsSeparatedByString("?")

            deleteCache[obj.qualifiedName] = parts
            fragments = parts
        }

        let sql = buildSQL(fragments, params: params)
        return sql
    }

    func buildSQL(queryFragments: [String], params: [AnyObject]) -> String{
        var sql = ""
        let escaped = params.map(escape)

        escaped.enumerate().forEach{ index, part in
            sql = sql + queryFragments[index] + part
        }

        sql = sql + queryFragments.last!
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