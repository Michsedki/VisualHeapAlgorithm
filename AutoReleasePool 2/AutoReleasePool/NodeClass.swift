//
//  NodeClass.swift
//  AutoReleasePool
//
//  Created by Apple on 1/9/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit


// this is the NodeClass,
// this class will be our node in the heap tree array, so we can adjusted in one place,
// it will hold the value and one nodeView
// inside the node view we store the value and the index in the array, so we can track the node view
// on the screen
// we can change the shape of the node
// we can add more object to the node, like the real auto release pool we can add referance to
// the object we need to release from from the memory
class NodeClass : NSObject {
    
    var value: Int
    
    lazy var nodeView = NodeView()
    
    init(value: Int) {
        self.value = value
        
        super.init()

        nodeView.valueView.text = "\(value)"
    }
}

class NodeView : UIView {
    
    lazy var valueView : UILabel = {
        let view = UILabel()
        view.clipsToBounds = true
        view.layer.cornerRadius = view.frame.height / 2
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = .blue
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 9)
        view.textColor = .white
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        
        return view
    }()
    
    lazy var indexAndTagView : UILabel = {
        let view = UILabel()
        view.clipsToBounds = true
        view.layer.cornerRadius = view.frame.height / 2
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = .blue
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 9)
        view.textColor = .white
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        
        return view
    }()
    
    override init(frame : CGRect){
        
        super.init(frame: frame)
        
        addSubview(valueView)
        addSubview(indexAndTagView)
        
        valueView.anchor(top: topAnchor,
                         leading: leadingAnchor,
                         bottom: bottomAnchor,
                         trailing: nil,
                         padding: .init(top: 0, left: 0, bottom: 0, right: 0),
                         size: .init(width: 15, height: 0))
        
        indexAndTagView.anchor(top: topAnchor,
                         leading: valueView.trailingAnchor,
                         bottom: bottomAnchor,
                         trailing: trailingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 0, right: 0),
                         size: .init(width: 15, height: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWith(value: Int, index: Int) {
        valueView.text = "\(value)"
        indexAndTagView.text = "\(index)"
    }
    
    func configureWithValue(value: Int) {
        valueView.text = "\(value)"
    }
    
    func configureWithIndex(index: Int) {
        indexAndTagView.text = "\(index)"
    }
    

}
