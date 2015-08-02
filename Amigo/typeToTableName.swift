//
//  typeToTableName.swift
//  Amigo
//
//  Created by Adam Venturella on 8/2/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation


func typeToTableName<T: AmigoModel>(type: T.Type) -> String{
    let parts = split(String(type).unicodeScalars){ $0 == "." }.map{ String($0).lowercaseString }
    return "_".join(parts)
}

func typeToTableName(type: String) -> String{
    let parts = split(type.unicodeScalars){ $0 == "." }.map{ String($0).lowercaseString }
    return "_".join(parts)
}