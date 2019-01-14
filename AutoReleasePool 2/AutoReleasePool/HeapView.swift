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
        // remove all old nodes but leave the red removed nodes in the view
        subviews.forEach({
            if $0.tag != 99  {
                $0.removeFromSuperview()
            }})
        // here i want to collect some information about the heap tree from the nodes array
        // first i want to know what is the tree hieght floor(log2(n)), n is the how many nodes in the array
        // so i can drew every level of the tree
        // and i need a start x and y postion
        // then i need to calculate the x shift for every node in the level
        // and the y shift for every level
        // then i loop on the levels and start shift in x and y to drew every node of the array in its place
        // and calculate the space between the nodes, so it shaps a tree
        let nodesCountInDouble = Double(nodes.count)
        let heapHieght = Int(floor(log2(nodesCountInDouble)))
                
        let x = CGFloat(frame.midX)
        let y = CGFloat(100)

        for i in 0...heapHieght {
            
            let startIndex = NSDecimalNumber(decimal: pow(2,i) - 1).intValue
            var endIndex = NSDecimalNumber(decimal: (pow(2, i + 1) - 2)).intValue
            
            let numberOfNodesInTheLevel = Double (endIndex - startIndex + 1)

            // check if the index is out of the array range set the end index to the end index in the array
            // i added this cause i calculate the start and end index of the tree level but actually
            // the tree maybe has just one element in this level
            // so this prevent the code from crashing whin it call index out of range
            if endIndex > nodes.count - 1 {
                endIndex = nodes.count - 1
            }
            
            // here i shift y with (tree hieght * constant of 25) so it drew in the same y postion
            // for the whole level
            let startY = y + (CGFloat(i) * CGFloat(25))
            
            // here i calculate the nodes on the left hand side in the same level
            // also the spaces between this nodes on the left hand side of that level
            // so i will be able to calculate the start point of the first left node in that level
            // and from there i can shift x with constatant of 40 to the right and start drew the next node
            // i keep shifting the x untill the last node in that level
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
    // i need function to print the heap tree array values on the screen for the user
    // so i create this function to take the [NodeClass] and loop on it
    // and returns [Int] so i can print it in the label on the screen
    func getValueArrayFromNodeArray(nodeArray: [NodeClass]) -> [Int] {
        
        var valueArray = [Int]()
        
        for node in nodeArray {
            valueArray.append(node.value)
        }
        return valueArray
    }
    
    // this function will be called from the UpdateHeapViewDelegate
    // when the MyHeap class will do any compare down it will send this nodeSwitchedTrackArray
    // which contains all switched nodes indexs in pair, so the view can move teh nodes in the same way
    // here i do the prep for the switch and i call the switch function,
    // and clean all the code in the completion block
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
    
    // here i need to do the actual node swtich in the interface
    // i need to switch tags between nodes
    // and change background color of the valueView to orange
    // also update the indexView with the new tag
    // then change background color of the valueView to blue again
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
    
    // this function will be called from the UpdateHeapViewDelegate
    // when the MyHeap class remove the root node it will give the node class to the heapView
    // through this delegate call so the heapView also can remove the root node to the top of the view
    // and change the valueView to red and tag it 99
    // also i need to calculate the postion for the new removed node on top of the view,
    // so i use removedNodesCounter as counter of the removed nodes
    // i shift x with = removedNodesCounter * 30
    // i shift y with = floor(Double(self.removedNodesCounter / 16) * 25)
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
    
    // this function will be called from the UpdateHeapViewDelegate
    // when the MyHeap class remove the root node and replace it with the last node of the tree
    // it will give the nodes class to the heapView to dreww the move of the switch
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
                
                // after the heapView finish moving the root node and the last node,
                // it calls the switchNodesAccordingToNodeSwitchIndexTrackingArray
                // to check if the MyHeap Class made any node switch while it was compare down from the root node
                // to the end of the array
                // if any switches happended it will be stord in nodeSwitchIndexTrackingArray as pair of indexs
                self.switchNodesAccordingToNodeSwitchIndexTrackingArray()
            }
        }
    }
    // this function will be called from the UpdateHeapViewDelegate
    // if the compare Down in the MyHeap made any node switch it call this function
    // to store the indexs of the two nodes switched in nodeSwitchIndexTrackingArray
    func updateNodeSwitchIndexTrackingArray(switchIndex: (Int, Int)) {
        nodeSwitchIndexTrackingArray.append(switchIndex)
    }
    // i needed function to clear nodeSwitchIndexTrackingArray before the MyHeap class starts
    // Compare down the tree so it prevet having old data in that variable
    // specially i don't know which call back will be executed first
    // as the Myheap class will run the whole code in the scope and the call back will come any time
    func clearNodeSwitchIndexTrackingArray() {
        nodeSwitchIndexTrackingArray.removeAll()
    }
    
    // i need function to execute the snode switch by order in the interface,
    // so i check if there is any node switches in nodeSwitchIndexTrackingArray
    // and start switch one by one so the user can see it
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
