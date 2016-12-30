//
//  ListViewController.swift
//  PokeStats
//
//  Created by Jason Pierna on 06/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import UIKit
import CoreData

import Alamofire
import SwiftyJSON

class ListViewController: UITableViewController {
    
    var pokemons = [Pokemon]()
    var filteredPokemons = [Pokemon]()
    
    let searchController = UISearchController(searchResultsController: nil)
    let miniatureQueue = DispatchQueue(label: "miniatures")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load offline Pokemons
        loadPokemons()
        
        // Fetch new online Pokemons
        fetchPokemons()
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Table View Refresh Control
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
                
                let pokemon: Pokemon = {
                    if searchController.isActive && searchController.searchBar.text != "" {
                        return filteredPokemons[indexPath.row]
                    }
                   return pokemons[indexPath.row]
                }()
                
                destinationViewController.pokemon = pokemon
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredPokemons.count
        }
        return pokemons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonTableViewCell", for: indexPath) as? PokemonTableViewCell else {
            return PokemonTableViewCell(style: .default, reuseIdentifier: "PokemonTableViewCell")
        }
        
        // Reset (if reused)
        cell.pokemonImageView.image = nil
        
        let pokemon: Pokemon = {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredPokemons[indexPath.row]
            }
            return pokemons[indexPath.row]
        }()
        
        
        cell.pokemonNameLabel.text = pokemon.name
        cell.pokemonNumberLabel.text = "#" + pokemon.number.stringValue
        
        if let miniaturePath = FileManager.documentsURL(childPath: "mini_\(pokemon.number).png") {
            if FileManager.default.fileExists(atPath: miniaturePath.path) {
                // Load from disk
                let miniature = UIImage(contentsOfFile: miniaturePath.path)
                cell.pokemonImageView.image = miniature
            }
            else {
                // Download and store
                if let miniatureUrl = URL(string: API.mini(no: pokemon.number.intValue)) {
                    miniatureQueue.async {
                        if let data = try? Data(contentsOf: miniatureUrl),
                            let miniature = UIImage(data: data) {
                            try? data.write(to: miniaturePath, options: .atomic)
                            
                            DispatchQueue.main.async {
                                cell.pokemonImageView.image = miniature
                            }
                        }
                    }
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
    
    func loadPokemons() {
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "pokedexNumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let context = DataManager.shared.context {
            if let rows = try? context.fetch(fetchRequest) {
                for pokemon in rows {
                    if !self.pokemons.contains(where: { pkmn in pkmn.number.intValue == pokemon.number.intValue }) {
                        self.pokemons.append(pokemon)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchPokemons() {
        Alamofire.request(API.pokemons).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value).arrayValue
                
                if let context = DataManager.shared.context {
                    for item in json {
                        if let pokemon = NSEntityDescription.insertNewObject(forEntityName: "Pokemon", into: context) as? Pokemon {
                            pokemon.populate(json: item)
                            
                            if !self.pokemons.contains(where: { pkmn in pkmn.number.intValue == pokemon.number.intValue }) {
                                self.pokemons.append(pokemon)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        try? context.save()
                        self.tableView.reloadData()
                    }
                }
              
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

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredPokemons = pokemons.filter {
            $0.name.lowercased().contains(searchController.searchBar.text!.lowercased())
        }
        tableView.reloadData()
    }
}
