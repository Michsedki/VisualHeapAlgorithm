//
//  HeapView.swift
//  AutoReleasePool
//
//  Created by Apple on 1/10/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Foundation

// HeapView is the view responsible for drew the heap tree array
// and move the nodes according the modification happens by the MyHeap class on the aray
// switch the node on the screen when it need to be switched according to the comparing condition
// update the viewContoller when it finish updating the interface
class HeapView: UIView {
    // this delegate to update the viewContoller when it finish updating the interface
    var finishedUpdateTheHeapViewDelegate : FinishedUpdateTheHeapViewDelegate!
    // this counter count the removed nodes to the top, so we can organize them
    // i use it to calculate the shiftX & shiftY between each node
    var removedNodesCounter = 0
    // this is the root frame, so i can move the last nood to this frame on top of the tree
    lazy var rootFrame = CGRect(x: self.frame.midX - 10, y: 100, width: 30, height: 20)
    // i need this variable to keep track of the switches happend on the nodes array while
    // the heap was comparing down, so i can move the node with the same sequance on the screen later
    var nodeSwitchIndexTrackingArray = [(Int,Int)]()
    
    
    // every time i insert new node, i want heap view to drew the all array, so it will match the array
    // it remove all subviews but the nodes removed from the array i keep them on top of the view
    // it drew the nodeView, and update its tag according to its index in the nodes array
    // and drew the whole tree by drew every level separate,
    func configureWith( nodes: [NodeClass]) {
        
        guard nodes.count > 0 else {
            // show there is nothing to drew
        return
        }
        
        subviews.forEach({
            
            if $0.tag != 99  {
                $0.removeFromSuperview()
            }})
        
        let nodesCountInDouble = Double(nodes.count)
        let heapHieght = Int(floor(log2(nodesCountInDouble)))
                
        let x = CGFloat(frame.midX)
        let y = CGFloat(100)

        for i in 0...heapHieght {
            
            let startIndex = NSDecimalNumber(decimal: pow(2,i) - 1).intValue
            var endIndex = NSDecimalNumber(decimal: (pow(2, i + 1) - 2)).intValue
            
            let numberOfNodesInTheLevel = Double (endIndex - startIndex + 1)

            
            if endIndex > nodes.count - 1 {
                endIndex = nodes.count - 1
            }
            
            let startY = y + (CGFloat(i) * CGFloat(25))
            
            let lengthOfNodesOnTheLeft = (numberOfNodesInTheLevel / 2) * 20
            let lengthOfSpaceBetweenTheNodesOnTheLeft = ((numberOfNodesInTheLevel - 1) * 20) / 2
            
            let startX = x - CGFloat(lengthOfNodesOnTheLeft + lengthOfSpaceBetweenTheNodesOnTheLeft)

            
            let shiftX =  40
            var shiftXCounter = 0
            
            for index in startIndex...endIndex {
                
                addSubview(nodes[index].nodeView)
                
                nodes[index].nodeView.frame = CGRect(x: startX + CGFloat(shiftX * shiftXCounter), y: startY, width: 30, height: 20)
                
                
                nodes[index].nodeView.tag = index
                nodes[index].nodeView.configureWith(value: nodes[index].value, index: index)

                
                print(i,startIndex, endIndex,numberOfNodesInTheLevel, index, startX + CGFloat(shiftX * shiftXCounter), startY, getValueArrayFromNodeArray(nodeArray: nodes))
                
                shiftXCounter = shiftXCounter + 1

            }
        }
    }
    
    func getValueArrayFromNodeArray(nodeArray: [NodeClass]) -> [Int] {
        
        var valueArray = [Int]()
        
        for node in nodeArray {
            valueArray.append(node.value)
        }
        
        return valueArray
        
    }
    
    func switchNodesWithSwitchTrack(nodeSwitchedTrackArray: [(Int,Int)]) {
        
        var indextrackArray = nodeSwitchedTrackArray
        
        if !indextrackArray.isEmpty,
            let (index1, index2) = indextrackArray.first {
            
            switchEment(firestIndex: index1, secondIndex: index2) {
                indextrackArray.remove(at: 0)
                self.switchNodesWithSwitchTrack(nodeSwitchedTrackArray: indextrackArray)
            }
        }
        
        
    }
    
    
    func switchEment(firestIndex: Int, secondIndex: Int,completion: (@escaping() -> Void)) {
        
        
        var firstNodeView = NodeView()
        var secondNodeView = NodeView()
        
        subviews.forEach({if $0.tag == firestIndex {
            firstNodeView = $0 as! NodeView
        } else if $0.tag == secondIndex {
            secondNodeView = $0 as! NodeView
            }
        })
        

        
            firstNodeView.tag = secondIndex
            secondNodeView.tag = firestIndex
            
            firstNodeView.configureWithIndex(index: secondIndex)
            secondNodeView.configureWithIndex(index: firestIndex)
            
            firstNodeView.valueView.backgroundColor = .orange
            secondNodeView.valueView.backgroundColor = .orange
            
            let firstNodeX = firstNodeView.frame.origin.x
            let firstNodeY = firstNodeView.frame.origin.y
            
            UIView.animate(withDuration: 1, animations: {
                
                firstNodeView.frame = CGRect(x: secondNodeView.frame.origin.x, y: secondNodeView.frame.origin.y, width: 30, height: 20)
                
            }) { (complete) in
                
                UIView.animate(withDuration: 1, animations: {
                    secondNodeView.frame = CGRect(x: firstNodeX, y: firstNodeY, width: 30, height: 20)
                }, completion: { (complete) in
                    firstNodeView.valueView.backgroundColor = .blue
                    secondNodeView.valueView.backgroundColor = .blue
                    
                    completion()
                })
            }
        
    }
    
    func removeNode(node: NodeClass) {
        
        let yShift = floor(Double(self.removedNodesCounter / 16) * 25)
        let xShift = self.removedNodesCounter * 30
        
        UIView.animate(withDuration: 1, animations: {
            
            node.nodeView.frame = CGRect(x: 10 + xShift, y: Int(20 + yShift) , width: 30, height: 20)
            
            
        }) { (complete) in
            node.nodeView.valueView.backgroundColor = .red
            node.nodeView.tag = 99
            node.nodeView.configureWithIndex(index: 0)


            self.removedNodesCounter += 1
        }
        
    }
    
    func removeHeadMoveLastNodeToTheRoot(rootNodeToRemove: NodeClass, lastNodeToReplace: NodeClass) {
        
        
        let yShift = floor(Double(self.removedNodesCounter / 16) * 25)
        let xShift = self.removedNodesCounter * 30
        
        UIView.animate(withDuration: 1, animations: {
            
            rootNodeToRemove.nodeView.frame = CGRect(x: 10 + xShift, y: Int(20 + yShift) , width: 30, height: 20)
            
            
        }) { (complete) in
            rootNodeToRemove.nodeView.valueView.backgroundColor = .red
            rootNodeToRemove.nodeView.tag = 99
            rootNodeToRemove.nodeView.configureWithIndex(index: 0)
            
            
            self.removedNodesCounter += 1
            
            UIView.animate(withDuration: 0.5, animations: {
                lastNodeToReplace.nodeView.valueView.backgroundColor = .green
                lastNodeToReplace.nodeView.tag = 0
                lastNodeToReplace.nodeView.configureWithIndex(index: 0)
                lastNodeToReplace.nodeView.frame = self.rootFrame
            }) { (complete) in
                lastNodeToReplace.nodeView.valueView.backgroundColor = .blue
                
                self.switchNodesAccordingToNodeSwitchIndexTrackingArray()

                
            }
        }
        
   
        
    }
    
    func updateNodeSwitchIndexTrackingArray(switchIndex: (Int, Int)) {
        
        nodeSwitchIndexTrackingArray.append(switchIndex)
        
    }
    
    func clearNodeSwitchIndexTrackingArray() {
        nodeSwitchIndexTrackingArray.removeAll()
    }
    
    func switchNodesAccordingToNodeSwitchIndexTrackingArray() {
        
        if !nodeSwitchIndexTrackingArray.isEmpty,
            let (index1, index2) = nodeSwitchIndexTrackingArray.first {
            

            switchEment(firestIndex: index1, secondIndex: index2) {
                self.nodeSwitchIndexTrackingArray.remove(at: 0)
                self.switchNodesWithSwitchTrack(nodeSwitchedTrackArray: self.nodeSwitchIndexTrackingArray)
                
                self.finishedUpdateTheHeapViewDelegate.completedNodeRemove()

            }
        } else {
            self.finishedUpdateTheHeapViewDelegate.completedNodeRemove()
            nodeSwitchIndexTrackingArray.removeAll()

        }
    }
    
    
}
