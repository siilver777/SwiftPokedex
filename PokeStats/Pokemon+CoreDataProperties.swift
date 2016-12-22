//
//  Pokemon+CoreDataProperties.swift
//  PokeStats
//
//  Created by Jason Pierna on 22/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation
import CoreData


extension Pokemon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pokemon> {
        return NSFetchRequest<Pokemon>(entityName: "Pokemon");
    }

    @NSManaged public var atk: Int16
    @NSManaged public var atkspe: Int16
    @NSManaged public var def: Int16
    @NSManaged public var defspe: Int16
    @NSManaged public var height: Double
    @NSManaged public var name: String
    @NSManaged public var pokedexDescription: String
    @NSManaged public var pokedexNumber: Int16
    @NSManaged public var pv: Int16
    @NSManaged public var type1value: Int16
    @NSManaged public var type2value: Int16
    @NSManaged public var vit: Int16
    @NSManaged public var weight: Double

}
