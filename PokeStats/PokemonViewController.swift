//
//  PokemonViewController.swift
//  PokeStats
//
//  Created by Jason Pierna on 12/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import UIKit
import AVFoundation

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
    @IBOutlet weak var descriptionButton: UIButton!
    
    @IBOutlet weak var pvLabel: UILabel!
    @IBOutlet weak var atkLabel: UILabel!
    @IBOutlet weak var defLabel: UILabel!
    @IBOutlet weak var atkSpeLabel: UILabel!
    @IBOutlet weak var defSpeLabel: UILabel!
    @IBOutlet weak var vitLabel: UILabel!
    
    var pokemonId: Int?
    var pokemon: Pokémon!
    lazy var synthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        return synthesizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadPokemon()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favorite(sender: UIButton?) {
        if let sender = sender {
            if sender.currentImage == UIImage(named: "favoriteEmpty") {
                sender.setImage(#imageLiteral(resourceName: "favoriteFilled"), for: .normal)
            }
            else {
                sender.setImage(#imageLiteral(resourceName: "favoriteEmpty"), for: .normal)
            }
        }
    }
    
    @IBAction func readDescription() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
        }
        else if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        }
        else {
            let utterance = AVSpeechUtterance(string: pokemon.pokedexDescription)
            
            utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
            utterance.rate = 0.55
            
            synthesizer.speak(utterance)
        }
    }
    
    @IBAction func share() {
        let alert = UIAlertController(title: "Not available", message: "Facebook Sharing is not yet available. Stay tuned!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func loadPokemon() {
        guard let pokemonId = pokemonId else { print("loadPokemon: pokemonId not set"); return }
        
        Alamofire.request(API.pokemon(no: pokemonId)).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
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

extension PokemonViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        descriptionButton.setImage(#imageLiteral(resourceName: "pauseButton"), for: .normal)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        descriptionButton.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        descriptionButton.setImage(#imageLiteral(resourceName: "playButton"), for: .normal)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        descriptionButton.setImage(#imageLiteral(resourceName: "pauseButton"), for: .normal)
    }
}
