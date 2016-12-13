//
//  ListViewController.swift
//  PokeStats
//
//  Created by Jason Pierna on 06/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON

class ListViewController: UITableViewController {
    
    var pokemons = [(Int, String)]()
    let miniatureQueue = DispatchQueue(label: "miniatures")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPokemons()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchPokemons), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPokemon" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationViewController = segue.destination as! PokemonViewController
                destinationViewController.pokemonId = pokemons[indexPath.row].0
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonTableViewCell", for: indexPath) as? PokemonTableViewCell else {
            return PokemonTableViewCell(style: .default, reuseIdentifier: "PokemonTableViewCell")
        }
        
        // Reset (if reused)
        cell.pokemonImageView.image = nil
        let pokemon = pokemons[indexPath.row]
        
        cell.pokemonNameLabel.text = pokemon.1
        cell.pokemonNumberLabel.text = "#" + String(pokemon.0)
        
        miniatureQueue.async {
            if let data = try? Data(contentsOf: URL(string: API.mini(no: pokemon.0))!) {
                let artwork = UIImage(data: data)
                DispatchQueue.main.async {
                    cell.pokemonImageView.image = artwork
                }
            }
        }
        
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPokemon", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Misc
    
    func fetchPokemons() {
        Alamofire.request(API.pokemons).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value).arrayValue
                
                self.pokemons.removeAll(keepingCapacity: true)
                
                for pokemon in json {
                    if let name = pokemon["name"].string,
                        let id = pokemon["id"].int {
                        self.pokemons.append((id, name))
                    }
                }
                self.tableView.reloadData()
                
                if let refreshControl = self.tableView.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
                
            case .failure(let error):
                print(error)
                
                if let refreshControl = self.tableView.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
}
