//
//  AmigoSession.swift
//  Amigo
//
//  Created by Adam Venturella on 6/29/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData

public class AmigoSessionModelAction<T: AmigoModel>{
    let using: T
    let usingModel: ORMModel
    let session: AmigoSession
    var _relationship: String?

    public init(_ obj: T, model: ORMModel, session: AmigoSession){
        self.using = obj
        self.usingModel = model
        self.session = session
    }

    public func relationship(value: String) -> AmigoSessionModelAction<T>{
        self._relationship = value
        return self
    }

    public func delete<U: AmigoModel>(other: U){

        if let key = _relationship{

            if let relationship = usingModel.relationships[key] as? ManyToMany{

                if let throughModel = relationship.throughModel{
                    fatalError("Relationship is managed though: \(throughModel)")
                }

                let leftModel = session.config.tableIndex[relationship.tables[0]]!
                let rightModel = session.config.tableIndex[relationship.tables[1]]!
                let left: AmigoModel
                let right: AmigoModel

                if leftModel == usingModel{
                    left = using
                    right = other
                } else {
                    left = other
                    right = using
                }

                let leftId = leftModel.primaryKey!.label
                let leftColumn = "\(leftModel.label)_\(leftId)"
                let leftParam = left.valueForKey(leftId)!

                let rightId = rightModel.primaryKey!.label
                let rightColumn = "\(rightModel.label)_\(rightId)"
                let rightParam = right.valueForKey(rightId)!

                var delete = relationship.associationTable.delete()

                let predicate = NSPredicate(format:" \(leftColumn) = \(leftParam) AND \(rightColumn) = \(rightParam)")

                let (filter, params) = session.engine.compiler.compile(predicate,
                    table: relationship.associationTable,
                    models: session.config.typeIndex)

                delete.filter(filter)

                let sql = session.engine.compiler.compile(delete)
                session.engine.execute(sql, params: params)
            }
        }
    }

    public func add<U: AmigoModel>(other: U...){
        add(other)
    }

    public func add<U: AmigoModel>(other: [U]){
        other.map(addModel)
    }

    public func addModel<U: AmigoModel>(other: U){

        if let key = _relationship{

            if let relationship = usingModel.relationships[key] as? ManyToMany{

                if let throughModel = relationship.throughModel{
                    fatalError("Relationship is managed though: \(throughModel)")
                }

                let leftModel = session.config.tableIndex[relationship.tables[0]]!
                let rightModel = session.config.tableIndex[relationship.tables[1]]!
                let left: AmigoModel
                let right: AmigoModel

                if leftModel == usingModel{
                    left = using
                    right = other
                } else {
                    left = other
                    right = using
                }

                let leftId = leftModel.primaryKey!.label
                let leftParam = left.valueForKey(leftId)!

                let rightId = rightModel.primaryKey!.label
                let rightParam = right.valueForKey(rightId)!

                let params = [leftParam, rightParam]
                let insert = relationship.associationTable.insert()
                let sql = session.engine.compiler.compile(insert)
                
                session.engine.execute(sql, params: params)
            }
        }
    }
}

public class AmigoSession: AmigoConfigured{
    public let config: AmigoConfiguration

    public init(config: AmigoConfiguration){
        self.config = config
    }

    public func begin(){
        config.engine.beginTransaction()
    }

    public func rollback(){
        config.engine.rollback()
    }

    public func commit(){
        config.engine.commitTransaction()
        begin()
    }

    public func query<T: AmigoModel>(value: T.Type) -> QuerySet<T>{
        let type = value.description()
        let model = typeIndex[type]!
        return QuerySet<T>(model: model, config: config)
    }

    public func using<U: AmigoModel>(obj: U) -> AmigoSessionModelAction<U>{
        let type = U.description()
        let model = config.typeIndex[type]!
        let action = AmigoSessionModelAction(obj, model: model, session: self)

        return action
    }

    public func add<T: AmigoModel>(objs: T...){
        add(objs)
    }

    public func delete<T: AmigoModel>(objs: T...){
        delete(objs)
    }

    public func add<T: AmigoModel>(objs: [T]){
        objs.map(self.addModel)
    }

    public func delete<T: AmigoModel>(objs: [T]){
        objs.map(self.deleteModel)
    }

    public func addModel<T: AmigoModel>(obj: T){
        let type = obj.dynamicType.description()
        let model = typeIndex[type]!
        if obj.valueForKey(model.primaryKey.label) == nil{
            insert(obj, model: model)
        } else {
            update(obj, model: model)
        }
    }


    public func deleteModel<T: AmigoModel>(obj: T){
        let type = obj.dynamicType.description()
        let model = typeIndex[type]!
        let id = model.primaryKey.label
        let value = obj.valueForKey(id)!
        let predicate = NSPredicate(format: "\(id) = \(value)")
        var delete = model.table.delete()

        let (filter, params) = engine.compiler.compile(predicate, table: model.table, models: config.tableIndex)
        delete.filter(filter)

        let sql = engine.compiler.compile(delete)
        engine.execute(sql, params: params)

        if let relationship = model.throughModelRelationship{

            let throughModel = relationship.through!
            let throughId = "\(throughModel.label)_\(throughModel.primaryKey!.label)"

            var delete = relationship.associationTable.delete()
            let predicate = NSPredicate(format: "\(throughId) = \(value)")
            let (filter, params) = engine.compiler.compile(predicate, table: relationship.associationTable, models: config.tableIndex)
            delete.filter(filter)

            let sql = engine.compiler.compile(delete)
            engine.execute(sql, params: params)
        }
    }

    func insert<T: AmigoModel>(obj: T, model: ORMModel){
        let insert = model.table.insert()
        let sql = engine.compiler.compile(insert)
        var automaticPrimaryKey = false
        var params = [AnyObject]()

        for each in model.table.sortedColumns{
            let value: AnyObject?

            if each.primaryKey && each.type == .Integer64AttributeType{
                automaticPrimaryKey = true
                continue
            }

            if let column = each.foreignKey{
                let parts = each.label.unicodeScalars.split{ $0 == "_"}.map(String.init)

                if let target = obj.valueForKey(parts[0]) as? AmigoModel{
                    let fkModel = config.tableIndex[column.relatedColumn.table!.label]!

                    if let id = target.valueForKey(fkModel.primaryKey.label){
                        value = id
                    } else {
                        self.insert(target, model: fkModel)
                        value = target.valueForKey(fkModel.primaryKey.label)!
                    }
                } else {
                    value = NSNull()
                }
            } else {
                if let x = obj.valueForKey(each.label){
                    value = x
                } else {
                    value = NSNull()
                }
            }

            params.append(value!)
        }

        engine.execute(sql, params: params)

        if automaticPrimaryKey && engine.fetchLastRowIdAfterInsert{
            let id = self.engine.lastrowid()
            obj.setValue(id, forKey: model.primaryKey.label)
        }

        if let relationship = model.throughModelRelationship{
            let left = relationship.left
            let right = relationship.right

            var leftKey: String!
            var rightKey: String!

            model.foreignKeys.map{ (key: String, c: Column) -> Void in

                let fk = c.foreignKey!
                if fk.relatedColumn == relationship.left.primaryKey{
                    leftKey = key
                }

                if fk.relatedColumn == relationship.right.primaryKey{
                    rightKey = key
                }
            }

            let leftParam = obj.valueForKeyPath("\(leftKey).\(left.primaryKey!.label)")!
            let rightParam = obj.valueForKeyPath("\(rightKey).\(right.primaryKey!.label)")!
            let throughParam = obj.valueForKey("\(model.primaryKey.label)")!

            let params = [leftParam, rightParam, throughParam]
            let insert = relationship.associationTable.insert()
            let sql = engine.compiler.compile(insert)

            engine.execute(sql, params: params)
        }
    }

    func update<T: AmigoModel>(obj: T, model: ORMModel){
        let id = model.primaryKey.label
        let value = obj.valueForKey(id)!
        var update = model.table.update()
        let sql: String
        let predicate = NSPredicate(format: "\(id) = \(value)")
        var params = [AnyObject]()

        for each in model.table.sortedColumns{
            let value: AnyObject?

            // is this the automatic primaryKey column?
            // skip it for updates.
            if each.primaryKey && each.type == .Integer64AttributeType{
                continue
            }

            // this is a duplicated block of code from add() above.
            // refactor this...
            if let column = each.foreignKey{
                let parts = each.label.unicodeScalars.split{ $0 == "_"}.map(String.init)

                if let target = obj.valueForKey(parts[0]) as? AmigoModel{
                    let fkModel = config.tableIndex[column.relatedColumn.table!.label]!

                    if let id = target.valueForKey(fkModel.primaryKey.label){
                        value = id
                    } else {
                        self.insert(target, model: fkModel)
                        value = target.valueForKey(fkModel.primaryKey.label)!
                    }
                } else {
                    value = NSNull()
                }
            } else {
                if let x = obj.valueForKey(each.label){
                    value = x
                } else {
                    value = NSNull()
                }
            }

            params.append(value!)
        }

        let (filter, predicateParams) = engine.compiler.compile(predicate, table: model.table, models: config.tableIndex)
        params = params + predicateParams
        update.filter(filter)

        sql = engine.compiler.compile(update)

        engine.execute(sql, params: params)
    }
}
