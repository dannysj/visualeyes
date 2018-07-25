//
//  EventCollectionViewCell.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/23/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit
enum EventType {
    case Summary
    case Normal
    
}
class EventCollectionViewCell: UICollectionViewCell {
    private var type: EventType!
    private lazy var imageView: UIImageView = {
       let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        return i
    }()
    
    private lazy var label: UILabel = {
       let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var innerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var backgroundImage: UIImage? = nil
    private var title: String = ""
    private var location: String = ""
    private var time: String = ""
    
    func initData(type: EventType, title: String, location: String, time: String, image: UIImage? = nil) {
        self.type = type
        self.title = title
        self.location = location
        self.time = time
        if let bgImage = image {
            self.backgroundImage = bgImage
        }
        
        setupViews()
    }
    
    func setupViews() {
        self.contentView.addSubview(innerView)
        innerView.clipsToBounds = true
        NSLayoutConstraint.activateAllConstraintsEquallyInCollectionView(child: innerView, parent: self.contentView, constant: 15.0)
        innerView.layer.cornerRadius = 5.0
        innerView.backgroundColor = UIColor.white
        innerView.addBasicShadow()
        
        switch type {
        case .Summary?:
            updateUISummary()
            break
        case .Normal?:
            updateUINormal()
            break
        default:
            // FIXME:
            return
        }
    }
    
    func updateUISummary() {
        innerView.addSubview(label)
        
        NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo:innerView.leadingAnchor, constant: 15),
                label.trailingAnchor.constraint(equalTo: innerView.trailingAnchor, constant: -15),
                label.topAnchor.constraint(equalTo: innerView.topAnchor, constant: 15)
            ])
        
        let attributedText = NSMutableAttributedString(string: "\(time)\n", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithMidSize(),
            NSAttributedStringKey.foregroundColor: UIColor.FlatColor.White.darkMediumGray
            ])
        
        let secondAttributedText = NSAttributedString(string: "\(title)\n", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithTitleSize(),
            NSAttributedStringKey.foregroundColor: UIColor.FlatColor.Blue.midnightBlue
            ])
        
        let thirdAttributedText = NSAttributedString(string: "\(location)\n", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithMidSize(),
            NSAttributedStringKey.foregroundColor: UIColor.FlatColor.White.darkMediumGray
            ])
        
        
        attributedText.append(secondAttributedText)
        attributedText.append(thirdAttributedText)
        
        label.textAlignment = .left
        label.attributedText = attributedText
    }
    
    func updateUINormal() {
        innerView.addSubview(imageView)
    
        NSLayoutConstraint.activateAllConstraintsEqually(child: imageView, parent: innerView)
        if let bgImage = backgroundImage {
           imageView.image = bgImage
        }
        imageView.clipsToBounds = true
        imageView.layer.backgroundColor = UIColor.FlatColor.White.darkLightGray.withAlphaComponent(0.4).cgColor
        imageView.layer.opacity = 1
        imageView.layer.cornerRadius = 5.0
        innerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: innerView.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: innerView.trailingAnchor, constant: -15),
            label.bottomAnchor.constraint(equalTo: innerView.bottomAnchor, constant: -15)
            ])
        
        let attributedText = NSMutableAttributedString(string: "\(time)\n", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithMidSize(),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        let secondAttributedText = NSAttributedString(string: "\(title)\n", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithTitleSize(),
            NSAttributedStringKey.foregroundColor: UIColor.FlatColor.Blue.midnightBlue
            ])
        
        let thirdAttributedText = NSAttributedString(string: "\(location)\n", attributes: [
            NSAttributedStringKey.font: Theme.preferredFontWithMidSize(),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ])
        
        attributedText.append(secondAttributedText)
        attributedText.append(thirdAttributedText)
        
        label.textAlignment = .left
        label.attributedText = attributedText
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if self.subviews.contains(self.contentView) {
            for subView in self.contentView.subviews {
                subView.removeFromSuperview()
            }
        }
        setupViews()
    }
}
