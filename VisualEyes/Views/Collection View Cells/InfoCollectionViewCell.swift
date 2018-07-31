//
//  InfoCollectionViewCell.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/26/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

enum InfoType {
    case Name
    case Description
    case Author
    case Suggestion
}

class InfoCollectionViewCell: UICollectionViewCell {
    private var type: InfoType! {
        didSet {
            setupViews()
        }
    }
    private lazy var mainString: String = ""
    private lazy var image: UIImage = UIImage.imageWithSize(size: CGSize(width: 60, height: 60), color: UIColor.randomColor())!
    // items
    private lazy var label: UILabel = {
        let l = UILabel()
       
        l.textColor = Theme.textColor()
        l.translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case .Name?:
            l.font =  Theme.preferredFontWithTitleSize()
            break
        case .Author?:
            l.font = Theme.preferredTextTitleFont()
            
            break
        case .Description?:
            l.font = Theme.preferredFontWithMidSize()
            l.numberOfLines = 0
            break
        default:
            l.font = Theme.preferredFontWithMidSize()
            break
        }
        l.text = mainString
        return l
    }()
    
    private lazy var profileImageView: UIImageView = {
       let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        
        return i
    }()
    
    func updateCellWithTitle(name: String) {
        mainString = name
        type = .Name
    }
    
    func updateCellWithDescription(desc: String) {
        mainString = desc
        type = .Description
    }
    
    func updateCellWithAuthor(author: String) {
        mainString = author
        type = .Author
    }
    
    func updateCellWithSuggestion(suggestion: [String]) {
        
        type = .Suggestion
    }
    
    
    func setupViews() {
        switch type {
        case .Name?:
            setupViewWithName()
            break
        case .Author?:
            setupViewWithAuthor()
            break
        case .Description?:
            setupViewWithDescription()
            break
        case .Suggestion?:
            setupViewWithSuggestion()
            break
        default:
            fatalError("Type should be initialized")
        }
    }
    
    func setupViewWithName() {
        self.contentView.addSubview(label)
        NSLayoutConstraint.activateConstraintForTitleAtCenterY(child: label, parent: self.contentView, constant: 30)
        
        
        
    }
    
    func setupViewWithAuthor() {
        self.contentView.addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            
            ])
        
        profileImageView.layer.cornerRadius = 30
        profileImageView.image = image
        profileImageView.clipsToBounds = true
        
        self.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 30),
            label.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30)
            ])
        
        
    }
    
    func setupViewWithDescription() {
        self.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -30)
            
            ])
        label.loremIpsumGenerator()
    }
    
    func setupViewWithSuggestion() {
        
    }
    
}
