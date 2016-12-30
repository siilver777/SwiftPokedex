//
//  PokemonTableViewCell.swift
//  PokeStats
//
//  Created by Jason Pierna on 07/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
