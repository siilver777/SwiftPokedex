//
//  PokemonViewController.swift
//  PokeStats
//
//  Created by Jason Pierna on 12/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON

class PokemonViewController: UIViewController {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var firstTypeImageView: UIImageView!
    @IBOutlet weak var secondTypeImageView: UIImageView!
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var pvLabel: UILabel!
    @IBOutlet weak var atkLabel: UILabel!
    @IBOutlet weak var defLabel: UILabel!
    @IBOutlet weak var atkSpeLabel: UILabel!
    @IBOutlet weak var defSpeLabel: UILabel!
    @IBOutlet weak var vitLabel: UILabel!
    
    var pokemonId: Int?
    var pokemon: Pokémon!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadPokemon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPokemon() {
        guard let pokemonId = pokemonId else { print("loadPokemon: pokemonId not set"); return }
        
        Alamofire.request(API.pokemon(no: pokemonId)).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                
                let pokemon = Pokémon(json: json)
                self.pokemon = pokemon
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
