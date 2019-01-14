//
//  ViewController.swift
//  AutoReleasePool
//
//  Created by Apple on 1/9/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // IBoutlet
    @IBOutlet weak var insertLabel: UILabel!
    @IBOutlet weak var displayArrayLabel: UILabel!
    //Variables
    // this is the view responsible to drew the MyHeap tree array, and move nodes arround on the screen
    let heapView = HeapView()
    // this is object of MyHEap class, the modal of the heap tree
    var heap = MyHeap { (item1: NodeClass, item2: NodeClass) -> Bool in
        item1.value < item2.value
    }
    // if this bool is true that mean the MyHeap needs to drain itself, so keep remove the root node
    // and rearange itself untill it drain
    var isDrainingTheHeap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the delegate of the heap and heapView to viewController,
        // so now the viewController listen to any change in the heap and heapView
        heap.updateHeapViewDelegate = self
        heapView.finishedUpdateTheHeapViewDelegate = self
        
        setupHeapView()
    }
    
    // setup the heapView on the top of the view
    // and set its translatesAutoresizingMaskIntoConstraints to true so it doesn't autolayout itself
    func setupHeapView() {
        
        self.view.addSubview(heapView)
        
        heapView.translatesAutoresizingMaskIntoConstraints = true
        heapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 400)
        heapView.backgroundColor = UIColor(red: 42/255, green: 54/255, blue: 88/255, alpha: 1)
        heapView.tag = 20
    }
    
    //IBActions
    // restartButtonPressed, here i need to remove all heapView subViews
    // and empty the heap.nodes array
    // also set removedNodesCounter to zero,
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        
        heap.nodes.removeAll()
        heapView.subviews.forEach({$0.removeFromSuperview()})
        heapView.removedNodesCounter = 0
    }
    
    // clear the insert label to 0, clean the screen for the user to enter a valid value for the node
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        insertLabel.text = "0"
    }
    // i want to take the input from this buttons so i grantee it is numbers and the user
    // can't insert deferent charachters.
    // select one of the number button to enter a node value to the insert label
    @IBAction func numberButton(_ sender: UIButton) {
        if insertLabel.text == "0" {
            insertLabel.text = "\(sender.tag)"
        } else if let labeltext =  insertLabel.text {
            insertLabel.text = labeltext + "\(sender.tag)"
        }
    }
    // insert Button pressed, we need to get the value entered and create a new node
    // then insert this node into the tree of the Heap (heap.nodes)
    @IBAction func insertNodeButtonPressed(_ sender: UIButton) {
        if let text = insertLabel.text,
            let value = Int(text) {
            let newNode = NodeClass(value: value)
            self.heap.insert(newNode, nodes: &self.heap.nodes)
        }
        // here i clear the insertLabel for the user to insert a new value right away,
        // no need to pree clear again
        insertLabel.text = "0"
    }
    // handle the action to remove the root node from the heap tree array,
    // here i check if the tree is Empty then do nothing, and maybe inform the user
    // if the tree is not empty so go ahead and remove this node
    // inside the heap.remove i take care if it is the last node or there is children
    // so i need to replace and compare
    @IBAction func removeTheTopButtonPressed(_ sender: UIButton) {
        
        guard !heap.nodes.isEmpty else {
            return
        }
        
        let _ = heap.remove()
    }
    // here i needed a function to clear the top area of the heapView, so when i delete more nodes
    // from the heap.nodes it has a space on top to be shown to the user with red color
    // so inside this function i remove all subViews which have tag == 99,
    // which i tagged after i removed from the array and moved it to the top of the heapView
    // at the end i clear the removedNodesCounter so the view start with
    // x = shiftX * removeNodesFromView  = 0 and y = shiftY * removeNodesFromView = 0
    @IBAction func removeNodesFromView(_ sender: UIButton) {
        heapView.removedNodesCounter = 0
        heapView.subviews.forEach({$0.removeFromSuperview()})
    }
    
    // this handle the heap drain itself, by check if the drain is empty do nothing
    // if the drain is not empty set isDrainingTheHeap to true, that means we are in drain the heap process
    // and start remove the root element, which will send call back to the delegate after it finish
    // remove each node, so i can cheack again on isDrainingTheHeap and keep removing until drain
    @IBAction func drainTheHeapButtonPressed(_ sender: UIButton) {
        
        guard !heap.nodes.isEmpty else {return}
        
        isDrainingTheHeap = true
        let _ = heap.remove()
    }
    // this function will be called back after the MyHeap class finish removing the root node
    // and replace it with the last node if the array had many nodes
    // this function will tell the heapView to do the same move on the screen in front of the user
    // so that the heapView will be matching the modification in the MyHeap.nodes array
    func removeHeadMoveLastNodeToTheRoot(rootNodeToRemove: NodeClass, lastNodeToReplace: NodeClass) {
        
        heapView.removeHeadMoveLastNodeToTheRoot(rootNodeToRemove: rootNodeToRemove, lastNodeToReplace: lastNodeToReplace)
    }
}

// this extention handle all call backs coming from the MyHeap Class
// here i need to handle
// 1 - clear nodeSwitchIndexTrackingArray
// 2 - update displayArrayLabel
// 3 - update the heapView to drew the heap.nodes after insert new node
// 4 - when the MyHeap compare up after adding new node, i need the heapView
// to execute the same node switch moves
// 5 - after the MyHeap remove the head of the tree, i need heapView to remove the root node
// and move it to the top area of the heapView, and color it red and tag it 99
// 6 - after the MyHeap replace the head with the last node, and finish compare down through the whole tree
// i need the heapView to execute the same node switch moves in the interface
extension ViewController : UpdateHeapViewDelegate {
    
    // i need to be sure that nodeSwitchIndexTrackingArray inside the heapView is empty
    // before i start remove the next node, because what was happning is the heapView keeps appending
    // to this array, and when it execute the switch moves, it redo the old switch moves again each time
    func clearNodeSwitchIndexTrackingArray() {
        heapView.clearNodeSwitchIndexTrackingArray()
    }

    // here the MyHeap should update the displayArrayLabel with the new array values
    func updateDisplayArrayLabel(nodeArray: [Int]) {
        displayArrayLabel.text = "\(nodeArray)"
    }
    // here MyHeap should tell the heapView to drew the new nodes array after adding the new Node
    func insirtNode(nodes: inout [NodeClass]) {
        heapView.configureWith(nodes: nodes)
    }
    // here MyHeap should tell the heapView to switch nodes according to certain sequance
    func switchNode(nodeSwitchedTrackArray: [(Int,Int)]) {
        heapView.switchNodesWithSwitchTrack(nodeSwitchedTrackArray: nodeSwitchedTrackArray)
    }
    // here MyHeap should tell the heapView to remove the root node and move it to the top of the heapView
    // and color it red and tag it 99 so the view will skip it when it remove all subviews inside
    // while it drew the array at the next insertion
    // also it block the drain sequance by setting the isDrainingTheHeap to false
    func removeHead(node: NodeClass) {
        isDrainingTheHeap = false
        heapView.removeNode(node: node)
    }
    // here the MyHeap should send the two indexs of the switched nodes, while it was comparing down
    // from the root node to the last node, so the heapView will store this values
    // and then execute the switch at once after the MyHEap finish the compare Down
    func updateNodeSwitchIndexTrackingArray(switchIndex: (Int, Int)) {
        heapView.updateNodeSwitchIndexTrackingArray(switchIndex: switchIndex)
    }
}

// this extention is for the heapView to tell the viewController that it is done moving object on the screen
// i need this delegate to figure out when to start the next move on the screen,
// cause the moves was overlaped and it starts before the old one finish which made a mess in view tag tracing
extension ViewController : FinishedUpdateTheHeapViewDelegate {
    
    func completedNodeRemove() {
        if isDrainingTheHeap {
            let _ = heap.remove()
        }
    }
}

