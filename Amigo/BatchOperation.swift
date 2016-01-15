//
//  BatchOperation.swift
//  Amigo
//
//  Created by Adam Venturella on 1/14/16.
//  Copyright © 2016 BLITZ. All rights reserved.
//

import Foundation

public protocol BatchOperation{
    init(session: AmigoSession)
    func add<T: AmigoModel>(obj: T)
    func add<T: AmigoModel>(value: T, upsert: Bool)
    func execute()
}