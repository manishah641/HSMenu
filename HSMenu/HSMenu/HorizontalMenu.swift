//
//  HorizontalMenu.swift
//  HSMenu
//
//  Created by Syed Muhammad on 22/11/2021.
//


import UIKit

struct MenuProperties{
    var selectedIndex:Int = 0
    var deselectedTextColor:UIColor
    var selectedTextColor:UIColor
    var underlinerColor:UIColor
    var collectionBackgroundColor:UIColor
    var cellBackgroundColor:UIColor
    var textFontSize:CGFloat
    var delegate:HorizontalMenuControllerDelegate
    var menuTitles:[String]
}

protocol HorizontalMenuControllerDelegate:AnyObject {
    func didSelectMenuItem(selectedIndex:IndexPath)
}

class HorizontalMenuController: UIView,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {

    
    weak var menuControllerDelegate:HorizontalMenuControllerDelegate?
    private var menuProperties:MenuProperties!
    private var selectedItemIndex:IndexPath!
    private var didAutoScroll = false
    lazy var bottomView:UIView = {
       let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 20
        return view
    }()
    
    lazy var collectionView:UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cv.backgroundColor = self.menuProperties.collectionBackgroundColor
        cv.translatesAutoresizingMaskIntoConstraints  = false
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    required init?(coder: NSCoder) {
        fatalError("Init Coder has not been implemented")
    }
     init(frame: CGRect,menuProperties:MenuProperties) {
        self.menuProperties = menuProperties
        self.selectedItemIndex = IndexPath(row: menuProperties.selectedIndex, section: 0)
        self.menuControllerDelegate = menuProperties.delegate
        super.init(frame: frame)
        viewSetup()
        addSubview(bottomView)
        bottomView.alpha = 0.2
    }
 
    func  viewSetup(){
        viewRemove()
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: MenuCell.identifier)
        self.addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        bottomView.frame = CGRect(x: 0, y: (collectionView.frame.height+collectionView.frame.origin.y)-15, width: self.frame.width, height: 5)
    }
    func viewRemove(){
        for view in self.subviews{
//            if view.tag == self.menuProperties.menuIndex.rawValue{
                view.removeFromSuperview()
            }
//        }
    }

//MARK: - CollectionView Delegate And DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuProperties.menuTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCell.identifier, for: indexPath) as! MenuCell
    
        
        let isSelected = indexPath == self.selectedItemIndex ? true : false
        cell.create(indexPath:indexPath,isSelected:isSelected,menuProperties:self.menuProperties)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if let menuCell = collectionView.cellForItem(at: self.selectedItemIndex) as? MenuCell {
            menuCell.removeSelection()
        }
        self.selectedItemIndex = indexPath
        if let menuCell = collectionView.cellForItem(at: indexPath) as? MenuCell {
                menuCell.createSelection()
            self.menuControllerDelegate?.didSelectMenuItem(selectedIndex: indexPath)
        }
       
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let menuCell = collectionView.cellForItem(at: self.selectedItemIndex) as? MenuCell {
            menuCell.removeSelection()
        }
    }
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath == self.selectedItemIndex {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !self.didAutoScroll{
            collectionView.scrollToItem(at: self.selectedItemIndex, at: .left, animated: false)
            self.didAutoScroll = true
        }
    }
}

//MARK: - MenuCell Class
class MenuCell:UICollectionViewCell{
    static let identifier = "HMenuCell"
    
    private var menuProperties:MenuProperties!
    private var titleLabel = UILabel()
    private var bottomLayer = CALayer()
    
    private func createLabel(title:String){
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: menuProperties.textFontSize)
        titleLabel.backgroundColor = self.menuProperties.cellBackgroundColor
        titleLabel.textColor = self.menuProperties.deselectedTextColor
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    }
    func createSelection(){
        let myWidth = titleLabel.frame.width-2
        let layerAnimation = CABasicAnimation(keyPath: "bounds.size.width")
        layerAnimation.duration = 0.1
        layerAnimation.fromValue = 2
        layerAnimation.toValue = myWidth
        let bottomLayer = CALayer()
            bottomLayer.frame = CGRect(x: 0, y: titleLabel.frame.height+20, width: myWidth, height: 5)
            bottomLayer.backgroundColor = self.menuProperties.underlinerColor.cgColor
        bottomLayer.cornerRadius = 2.5
        titleLabel.layer.addSublayer(bottomLayer)
        titleLabel.textColor = self.menuProperties.selectedTextColor
        self.bottomLayer = bottomLayer
    
        bottomLayer.add(layerAnimation, forKey: "anim")
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        removeSelection()
        
    }
    func removeSelection(){
        titleLabel.textColor = self.menuProperties.deselectedTextColor
        self.bottomLayer.removeFromSuperlayer()
        self.bottomLayer = CALayer()
    }
    
    func create(indexPath:IndexPath,isSelected:Bool,menuProperties:MenuProperties){
        self.menuProperties = menuProperties
        createLabel(title: menuProperties.menuTitles[indexPath.row])
        if isSelected{createSelection()}
        else {removeSelection()}
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
