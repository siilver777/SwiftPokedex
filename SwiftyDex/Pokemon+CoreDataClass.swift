//
//  Pokemon+CoreDataClass.swift
//  PokeStats
//
//  Created by Jason Pierna on 22/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation
import CoreData

import SwiftyJSON

@objc(Pokemon)
public class Pokemon: NSManagedObject {
    
    var number: NSNumber {
        get {
            return NSNumber(value: pokedexNumber)
        }
        set {
            pokedexNumber = newValue.int16Value
        }
    }
    
    var type1: Type {
        get {
            return Type(rawValue: Int(type1value))!
        }
        set {
            type1value = Int16(newValue.rawValue)
        }
    }
    
    var type2: Type? {
        get {
            if type2value > 0 {
                return Type(rawValue: Int(type2value))
            }
            return nil
            
        }
        set {
            type2value = Int16(newValue!.rawValue)
        }
    }
    
    var stats: Stats {
        get {
            return Stats(pv: Int(pv), atk: Int(atk), def: Int(def), atkspe: Int(atkspe), defspe: Int(defspe), vit: Int(vit))
        }
        set {
            self.pv = Int16(newValue.pv)
            self.atk = Int16(newValue.atk)
            self.def = Int16(newValue.def)
            self.atkspe = Int16(newValue.atkspe)
            self.defspe = Int16(newValue.defspe)
            self.vit = Int16(newValue.vit)
        }
    }
    
    func populate(json: JSON) {
        
        // Base info
        self.pokedexNumber = json["id"].int16Value
        self.name = json["name"].stringValue
        self.pokedexDescription = json["description"].stringValue
        self.height = json["height"].doubleValue
        self.weight = json["weight"].doubleValue
        
        // Types
        let types = json["types"].arrayValue
        self.type1 = Type(rawValue: types[0]["id"].intValue)!
        
        if types.count > 1 {
            self.type2 = Type(rawValue: types[1]["id"].intValue)!
        }
        
        // Stats
        self.stats = Stats(pv: json["stats"]["pv"].intValue,
                           atk: json["stats"]["atk"].intValue,
                           def: json["stats"]["def"].intValue,
                           atkspe: json["stats"]["atkspe"].intValue,
                           defspe: json["stats"]["defspe"].intValue,
                           vit: json["stats"]["vit"].intValue)
    }
}
