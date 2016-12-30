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
import FBSDKShareKit

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
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    var pokemon: Pokemon!
    var audioPlayer: AVAudioPlayer?
    
    lazy var synthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        return synthesizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUI()
        
        // Gesture Recognizer for sound
        artworkImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(playSound))
        artworkImageView.addGestureRecognizer(gesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favorite(sender: UIButton?) {
        
        if let context = DataManager.shared.context {
            pokemon.favorite = !pokemon.favorite
            
            do {
                try context.save()
                
                if pokemon.favorite {
                    favoriteButton.setImage(#imageLiteral(resourceName: "favoriteFilled"), for: .normal)
                }
                else {
                    favoriteButton.setImage(#imageLiteral(resourceName: "favoriteEmpty"), for: .normal)
                }
                
            }
            catch {
                print(error)
            }
        }
    }
    
    @IBAction func readDescription() {
        if synthesizer.isSpeaking {
            if synthesizer.isPaused {
                synthesizer.continueSpeaking()
            }
            else {
                synthesizer.pauseSpeaking(at: .immediate)
            }
        }
        else {
            let utterance = AVSpeechUtterance(string: pokemon.pokedexDescription)
            
            utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
            utterance.rate = 0.55
            
            synthesizer.speak(utterance)
        }
    }
    
    @IBAction func share() {
        if FBSDKAccessToken.current() != nil {
            let content = FBSDKShareLinkContent()
            
            if let url = "http://www.pokepedia.fr/index.php/\(pokemon.name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                content.contentURL = URL(string: url)
                FBSDKShareDialog.show(from: self, with: content, delegate: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Log in with Facebook", message: "To share Pokémons, you need to log in with Facebook. You can connect Facebook to SwiftDex inside settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    func loadUI() {
        // Navigation bar
        navigationItem.title = pokemon.name
        
        // Main information
        numberLabel.text = "Kanto #00" + pokemon.number.stringValue
        firstTypeImageView.image = UIImage(named: "type\(pokemon.type1.rawValue)")
        if let type2 = pokemon.type2 {
            secondTypeImageView.image = UIImage(named: "type\(type2.rawValue)")
        }
        else {
            secondTypeImageView.image = nil
        }
        heightLabel.text = String(pokemon.height) + "m"
        weightLabel.text = String(pokemon.weight) + "kg"
        descriptionTextView.text = pokemon.pokedexDescription
        
        // Stats
        
        pvLabel.text = String(pokemon.stats.pv)
        atkLabel.text = String(pokemon.stats.atk)
        defLabel.text = String(pokemon.stats.def)
        atkSpeLabel.text = String(pokemon.stats.atkspe)
        defSpeLabel.text = String(pokemon.stats.defspe)
        vitLabel.text = String(pokemon.stats.vit)
        
        // Favorite button state
        
        if pokemon.favorite {
            favoriteButton.setImage(#imageLiteral(resourceName: "favoriteFilled"), for: .normal)
        }
        else {
            favoriteButton.setImage(#imageLiteral(resourceName: "favoriteEmpty"), for: .normal)
        }
        
        // Artwork
        
        if let artworkPath = FileManager.documentsURL(childPath: "artwork_\(self.pokemon.number).png") {
            if FileManager.default.fileExists(atPath: artworkPath.path) {
                // Load from disk
                let artwork = UIImage(contentsOfFile: artworkPath.path)
                self.artworkImageView.image = artwork
            }
            else {
                // Download and store
                if let artworkUrl = URL(string: API.artwork(no: self.pokemon.number.intValue)) {
                    let artworkQueue = DispatchQueue(label: "artwork")
                    artworkQueue.async {
                        if let data = try? Data(contentsOf: artworkUrl),
                            let artwork = UIImage(data: data) {
                            try? data.write(to: artworkPath, options: .atomic)
                            
                            DispatchQueue.main.async {
                                self.artworkImageView.image = artwork
                            }
                        }
                    }
                }
            }
        }
        
        // Sound
        
        let soundQueue = DispatchQueue(label: "sound")
        soundQueue.async {
            if let soundPath = FileManager.documentsURL(childPath: "sound_\(self.pokemon.number).mp3") {
                if FileManager.default.fileExists(atPath: soundPath.path) {
                    // Load from disk
                    self.audioPlayer = try? AVAudioPlayer(contentsOf: soundPath)
                }
                else {
                    // Download
                    if let soundUrl = URL(string: API.sound(no: self.pokemon.number.intValue)),
                        let data = try? Data(contentsOf: soundUrl) {
                        // Save on disk
                        try? data.write(to: soundPath, options: .atomic)
                        
                        // Load the file in the player
                        self.audioPlayer = try? AVAudioPlayer(data: data)
                    }
                }
            }
        }
    }
    
    func playSound() {
        if let audioPlayer = audioPlayer {
            audioPlayer.play()
            
            artworkImageView.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseInOut, animations: {
                self.artworkImageView.transform = .identity
            })
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
