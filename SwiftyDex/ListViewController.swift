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

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    
    var pokemons = [Pokemon]()
    var filteredPokemons = [Pokemon]()
    var displayMode: DisplayMode = .all
    
    let searchController = UISearchController(searchResultsController: nil)
    let miniatureQueue = DispatchQueue(label: "miniatures")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load offline Pokemons
        loadPokemons()
        
        // Fetch new online Pokemons
        fetchPokemons()
        
        // Table View Edge Insets
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBar.frame.size.height, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: tabBar.frame.size.height, right: 0)
        
        // Tab Bar Set Up
        tabBar.selectedItem = tabBar.items?[0]
        tabBar.items?[0].selectedImage = #imageLiteral(resourceName: "pokedexFilled")
        
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
    
    // MARK: - Misc
    
    func loadPokemons() {
        
        pokemons.removeAll()
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "pokedexNumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if displayMode == .favorites {
            fetchRequest.predicate = NSPredicate(format: "favorite == YES")
        }
        
        if let context = DataManager.shared.context {
            do {
                let rows = try context.fetch(fetchRequest)
                for pokemon in rows {
                    if !self.pokemons.contains(where: { pkmn in pkmn.number.intValue == pokemon.number.intValue }) {
                        self.pokemons.append(pokemon)
                    }
                }
                self.tableView.reloadData()
            }
            catch {
                print(error)
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
                            
                            //                            if !self.pokemons.contains(where: { pkmn in pkmn.number.intValue == pokemon.number.intValue }) {
                            //                                self.pokemons.append(pokemon)
                            //                            }
                        }
                    }
                    DispatchQueue.main.async {
                        try? context.save()
                        //                        self.tableView.reloadData()
                        self.loadPokemons()
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

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredPokemons.count
        }
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
}

 // MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPokemon", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredPokemons = pokemons.filter {
            $0.name.lowercased().contains(searchController.searchBar.text!.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - UITabBarDelegate
extension ListViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = tabBar.items,
            let index = items.index(of: item) {
            switch index {
            case 0:
                displayMode = .all
            case 1:
                displayMode = .favorites
            default:
                break
            }
            
            loadPokemons()
        }
    }
}
