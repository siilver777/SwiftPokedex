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
                
                // update UI
                DispatchQueue.main.async {
                    self.navigationItem.title = pokemon.name
                    
                    self.numberLabel.text = "Kanto #00" + String(pokemon.id)
                    self.firstTypeImageView.image = UIImage(named: "type\(pokemon.type1.rawValue)")
                    if let type2 = pokemon.type2 {
                        self.secondTypeImageView.image = UIImage(named: "type\(type2.rawValue)")
                    }
                    else {
                        self.secondTypeImageView.image = nil
                    }
                    self.heightLabel.text = String(pokemon.height) + "m"
                    self.weightLabel.text = String(pokemon.weight) + "kg"
                    self.descriptionTextView.text = pokemon.pokedexDescription
                    
                    self.pvLabel.text = String(pokemon.stats.pv)
                    self.atkLabel.text = String(pokemon.stats.atk)
                    self.defLabel.text = String(pokemon.stats.def)
                    self.atkSpeLabel.text = String(pokemon.stats.atkspe)
                    self.defSpeLabel.text = String(pokemon.stats.defspe)
                    self.vitLabel.text = String(pokemon.stats.vit)
                    
                    let artworkQueue = DispatchQueue(label: "artwork")
                    artworkQueue.async {
                        if let data = try? Data(contentsOf: URL(string: API.artwork(no: pokemon.id))!) {
                            let artwork = UIImage(data: data)
                            DispatchQueue.main.async {
                                self.artworkImageView.image = artwork
                            }
                        }
                    }
                    
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
