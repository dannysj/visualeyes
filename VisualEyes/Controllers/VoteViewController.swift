//
//  VoteViewController.swift
//  VisualEyes
//
//  Created by Danny Chew on 7/21/18.
//  Copyright © 2018 Danny Chew. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController {
    
    var voteBar: Votebar!
    private var voted: Bool = false {
        didSet {
            updateVoteBar(votedAns: voted)
        }
    }
    private lazy var frameForVoteBar: CGRect = {
        let r = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: voteBarHeight)
        return r
    }()
    let voteBarHeight: CGFloat = 120.0
    var headerHeight: CGFloat = 240.0
     var statusBarShouldBeHidden: Bool = false
    // FIXME: Dummy data:
    let selection: [String] = ["Yes", "No"]
    var statistics: [Double] = [0.4,0.6]
    let color: [UIColor] = [UIColor.FlatColor.Green.mintDark, UIColor.FlatColor.Red.grapeFruit, UIColor.purple]
    
    // Collection View stuff
    let cellID: String = "VoteViewCell"
    let headerID: String = "HeaderCell"
    private lazy var collectionView: UICollectionView = {
        let layout = CustomLayout()
        layout.isVertical = true
        layout.delegate = self
    
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.alwaysBounceVertical = true
        cv.backgroundColor = UIColor.white
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isScrollEnabled = true
        cv.register(HeaderViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        return cv
    }()
    
    private lazy var option1Button: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.FlatColor.Green.mintLight
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Theme.preferredFontWithMidSize()
        label.textColor = UIColor.white
        
        v.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -15),
            label.centerYAnchor.constraint(equalTo: v.centerYAnchor)
            ])
        label.text = "Option 1"
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(option1ButtonPressed))
        v.addGestureRecognizer(tapGR)
        
        return v
    }()
    
    private lazy var option2Button: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.FlatColor.Red.grapeFruit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Theme.preferredFontWithMidSize()
        label.textColor = UIColor.white
        v.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -15),
            label.centerYAnchor.constraint(equalTo: v.centerYAnchor)
            ])
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(option2ButtonPressed))
        v.addGestureRecognizer(tapGR)
        label.text = "Option 2"
        return v
    }()
    
    private lazy var votedButton: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.FlatColor.Red.grapeFruit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = Theme.preferredFontWithSmallSize()
        label.textColor = UIColor.white
        v.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -15),
            label.centerYAnchor.constraint(equalTo: v.centerYAnchor)
            ])
        label.text = "Thank You For Your Response"
        return v
    } ()
    
    private lazy var closeButton: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 20
        v.layer.shadowRadius = 2
        v.layer.shadowColor = UIColor.FlatColor.White.darkMediumGray.withAlphaComponent(0.5).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        let close = CustomDrawView(type: .cross, lineColor: Theme.textColor(), frame: frame)
        close.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(close)
        
        NSLayoutConstraint.activate([
            close.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            close.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            close.widthAnchor.constraint(equalToConstant:  frame.width),
            close.heightAnchor.constraint(equalToConstant: frame.height)
            ])
        
        v.addBasicShadow()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        v.addGestureRecognizer(tapGR)
        return v
    }()
    
    private lazy var popUpMessageView: CardView = {
        let width = self.view.frame.width * 0.5
        let v = CardView(frame: CGRect(x: self.view.frame.width / 2.0 - width / 2.0, y: self.view.frame.height, width: width, height: 200))
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private var popUpMessageYConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupScene()
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func setupScene() {
        self.view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        // close button
        self.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
           closeButton.widthAnchor.constraint(equalToConstant: 40),
           closeButton.heightAnchor.constraint(equalToConstant: 40),
           closeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
           closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30)
         
            ])
        
        if voted {
            self.view.addSubview(votedButton)
            NSLayoutConstraint.activate([
                votedButton.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.7),
                votedButton.heightAnchor.constraint(equalToConstant: 50),
                votedButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                votedButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
                
                ])
        }
        else {
             self.view.addSubview(option1Button)
             self.view.addSubview(option2Button)
            NSLayoutConstraint.activate([
                option1Button.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.3),
                option1Button.heightAnchor.constraint(equalToConstant: 50),
                option1Button.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -15),
                option1Button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
               option2Button.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.3),
               option2Button.heightAnchor.constraint(equalToConstant: 50),
               option2Button.leadingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 15),
               option2Button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30)
                ])
        }
        
        
    }
    
   
    @objc func closeTapped() {
        print("Close tapped")
    }
    
    // Vote functions
    
    @objc func option1ButtonPressed() {
        voted = true
        addPopUpMessage()
    }
    
    @objc func option2ButtonPressed() {
        voted = true
        
    }
    
    func updateVoteBar(votedAns: Bool) {
        voteBar.updateVoteStatus(voted: votedAns, statistic:statistics )
    }
    
    func addPopUpMessage() {
        self.view.addSubview(popUpMessageView)
        
        NSLayoutConstraint.activate([
            popUpMessageView.widthAnchor.constraint(equalToConstant: popUpMessageView.frame.width),
            popUpMessageView.heightAnchor.constraint(equalToConstant: popUpMessageView.frame.height),
            popUpMessageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ])
        
     
        let oldFrame = popUpMessageView.frame
        let newFrame = CGRect(x: oldFrame.minX, y: (self.view.frame.height / 2.0) - (oldFrame.height / 2.0), width: oldFrame.width, height: oldFrame.height)
           popUpMessageYConstraint = popUpMessageView.topAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -oldFrame.height / 2.0)
 
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.popUpMessageView.frame = newFrame
            self.popUpMessageYConstraint.isActive = true
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VoteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! HeaderViewCell
        
        header.setupViews()
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        if indexPath.row == 1 {
            
        }
        else {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 30),
                label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 30),
                label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -30),
              
                ])
            
            label.font = Theme.preferredFontWithTitleSize()
            label.text = "Test Question~"
            
            let timeLabel = UILabel()
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(timeLabel)
            
            NSLayoutConstraint.activate([
               timeLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
               timeLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 30),
               timeLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -30),
               
                ])
            
            timeLabel.font = Theme.preferredFontWithSmallSize()
            timeLabel.textColor = UIColor.FlatColor.White.darkMediumGray
            timeLabel.text = "Time"
            
            // Bar
            voteBar = Votebar(frame: frameForVoteBar, selection: selection, color: color, voted: false)
            voteBar.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(voteBar)
            NSLayoutConstraint.activate([
                voteBar.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                voteBar.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 30),
                voteBar.heightAnchor.constraint(equalToConstant: voteBarHeight),
                voteBar.widthAnchor.constraint(equalToConstant: frameForVoteBar.width)
                
                ])
            
            let descLabel = UILabel()
            descLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(descLabel)
            
            NSLayoutConstraint.activate([
               descLabel.topAnchor.constraint(equalTo: voteBar.bottomAnchor, constant: 15),
               descLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 30),
               descLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -30),
                
                ])
            
           descLabel.font = Theme.preferredFontWithMidSize()
           descLabel.numberOfLines = 0
           descLabel.text = "Time"
            
        }
        
        return cell
    }
    
    
}

extension VoteViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}


extension VoteViewController: CustomLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
      return CGSize(width: view.frame.width, height: headerHeight)
    }
    
    func collectionView(collectionView: UICollectionView, totalHeightForCellAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
            return 800
        
        
    }
    
    // MARK: Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = self.collectionView.contentOffset.y
        
        
        
        if y < headerHeight - 65 {
            if let naviC = self.navigationController {
                if !naviC.navigationBar.isHidden {
                    
                    self.navigationController?.navigationBar.alpha = 0.0
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                }
     
                
                
            }
        }
        else if y > headerHeight - 65{
            if y < headerHeight {
                if !statusBarShouldBeHidden {
                    statusBarShouldBeHidden = true
                    UIView.animate(withDuration: 0.25) {
                        self.setNeedsStatusBarAppearanceUpdate()
                    }
                }
                
                if let naviC = self.navigationController {
                    if !(naviC.navigationBar.isHidden) {
                    self.navigationController?.navigationBar.alpha = 0.0
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    }
                }
                print("hi")
                print(self.collectionView.contentOffset.y)
                print(headerHeight)
                let x = y - headerHeight + 65
                print(x)
                self.navigationController?.navigationBar.alpha = x / 65.0
            }
            else if y > headerHeight {
                statusBarShouldBeHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
    
}
