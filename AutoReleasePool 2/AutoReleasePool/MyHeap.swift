
//
//  MyHeap.swift
//  AutoReleasePool
//
//  Created by Apple on 1/9/19.
//  Copyright © 2019 Apple. All rights reserved.
//

public struct MyHeap {
    
    //
    var updateHeapViewDelegate : UpdateHeapViewDelegate!
    
    
    // This is the array of nodes, it is generic
    var nodes = [NodeClass]()
    // comparing closure, we can store any comparing closure to make the heap tree max_Heap_Tree
    // or min_Heap_Tree
    // i made it private so no one can set it from outside.
    private var comparingClosure: (NodeClass, NodeClass) -> Bool
    
    // set the comparingClosure using public init
    init(compareCondition: @escaping (NodeClass, NodeClass) -> Bool) {
        self.comparingClosure = compareCondition
    }
    
    // set the nodes Array, and then shiftDown the indexs of the tree level before the last level
    // to get the indexs of the tree level before the last level, we divid the total number of nodes on 2
    // and subtract one , by doing that we get on level above the leaf level, and it is actually gives us the
    // index of the parent of the last leaf
    private mutating func configureMyHeap(with array: [NodeClass]) {
        nodes = array
        for i in stride(from: (nodes.count/2-1), through: 0, by: -1) {
            CompareDown(i)
        }
    }
    // check if the nodes array is empty
    public var isEmpty: Bool {
        return nodes.isEmpty
    }
    // returns the nodes array count
    public var count: Int {
        return nodes.count
    }
    
    // return the parent index for a sepacific node,
    // takes index of the sepacific node and return the parent index for it
    func parentIndex(ofIndex i: Int) -> Int {
        return (i - 1) / 2
    }
    
    // return the left child index for a sepacific node,
    // takes index of the sepacific node and return the left child index for it
    func leftChildIndex(ofIndex i: Int) -> Int {
        return 2*i + 1
    }
    
    // return the right child index for a sepacific node,
    // takes index of the sepacific node and return the right child index for it
    @inline(__always) internal func rightChildIndex(ofIndex i: Int) -> Int {
        return 2*i + 2
    }
    
    // return the first node of the array,
    // it will be max value in case of max_Tree_Heap or min value in case of min_Tree_Heap
    func peek() -> NodeClass? {
        return nodes.first
    }
    
    // insirt node to the end of the MyHeap nodes Array by append it in the array,
    // then start check through the whole tree indexs, starting from the last index to the top of the tree
    // check according to the comparing condition,
    // if we need to switch the new node up
    func insert(_ value: NodeClass,  nodes : inout [NodeClass]) {
        nodes.append(value)
        updateHeapViewDelegate?.insirtNode(nodes: &nodes)
        updateHeapViewDelegate.updateDisplayArrayLabel(nodeArray: getValueArrayFromNodeArray(nodeArray: nodes))
        CompareUpFromIndex(nodes.count - 1, nodes: &nodes)
    }
    
    // first check if the nodes array is empty
    // second check if this nnode the root node, last node to remove, if so we can remove the node without
    // replacing the root with the last element or compare the new root with the left and wight children
    // third if it is not the root node, so we remove the root and replace it with the last node in the array,
    // then update the heap view by calling the delegate
    // then compare the root with left and right children and shift it down if the compare condition return true
    // it is mutating func cause it will modify the nodes array inside itself
    mutating func remove() -> NodeClass? {
        guard !nodes.isEmpty else { return nil }
        
        if nodes.count == 1 {
            let removedNode = nodes.removeLast()
            updateHeapViewDelegate.removeHead(node: removedNode)
            updateHeapViewDelegate.updateDisplayArrayLabel(nodeArray: getValueArrayFromNodeArray(nodeArray: nodes))
            return removedNode
            
        } else {
            // Use the last node to replace the first one, then fix the heap by
            // shifting this new first node into its proper position.
            let value = nodes[0]
            let lastNode = nodes.removeLast()
            // update the heap view with the root node to remove and the last node to replace it with the root
            updateHeapViewDelegate.removeHeadMoveLastNodeToTheRoot(rootNodeToRemove: value, lastNodeToReplace: lastNode)
            nodes[0] = lastNode
            updateHeapViewDelegate.updateDisplayArrayLabel(nodeArray: getValueArrayFromNodeArray(nodeArray: nodes))
            // arrange the array down from the root
            updateHeapViewDelegate.clearNodeSwitchIndexTrackingArray()
            CompareDown(0)
            return value
        }
    }
    
    //this func will compare the node with the givin index with its parent, and swap the node and the parent
    // if the compare returns true
    internal func CompareUpFromIndex(_ index: Int, nodes : inout [NodeClass]) {
        
        var childIndex = index
        let child = nodes[childIndex]
        var parentIndex = self.parentIndex(ofIndex: childIndex)
        // this nodeSwitchedTrackArray to track the node switch by storing the index of the node switched
        // so late i can update the heap view to do the same exact move on the screen
        var nodeSwitchedTrackArray = [(Int,Int)]()
        
        while childIndex > 0 && comparingClosure(child, nodes[parentIndex]) {
            nodeSwitchedTrackArray.append((childIndex,parentIndex))
            nodes[childIndex] = nodes[parentIndex]
            childIndex = parentIndex
            parentIndex = self.parentIndex(ofIndex: childIndex)
            updateHeapViewDelegate.updateDisplayArrayLabel(nodeArray: getValueArrayFromNodeArray(nodeArray: nodes))
        }
        // here i update the heap view with the nodeSwitchedTrackArray, and now the heap view will move the nodes
        // on the screen by the same order this function switched the nodes inside the array
        updateHeapViewDelegate.switchNode(nodeSwitchedTrackArray: nodeSwitchedTrackArray)
        nodes[childIndex] = child
        updateHeapViewDelegate.updateDisplayArrayLabel(nodeArray: getValueArrayFromNodeArray(nodeArray: nodes))
    }

    //this func will compare the node with the givin index with its left and right children,
    // and swap the node and the child if the compare returns true
    mutating func compareDownToLastNode(from index: Int, until endIndex: Int) {
        
        let leftChildIndex = self.leftChildIndex(ofIndex: index)
        let rightChildIndex = leftChildIndex + 1
        // find out which one comes on the top of the three nodes, the parent, left child and the right child
        // if it is the parent so we done
        // if it is the child we swap it with the parent and continue comparing down
        var first = index
        if leftChildIndex < endIndex && comparingClosure(nodes[leftChildIndex], nodes[first]) {
            first = leftChildIndex
        }
        if rightChildIndex < endIndex && comparingClosure(nodes[rightChildIndex], nodes[first]) {
            first = rightChildIndex
        }
        if first == index {return }
        // here i update the heap view with every switch happen, and store it in the heap view
        // in variable named nodeSwitchIndexTrackingArray
        updateHeapViewDelegate.updateNodeSwitchIndexTrackingArray(switchIndex: (index, first))
        
        nodes.swapAt(index, first)
        updateHeapViewDelegate.updateDisplayArrayLabel(nodeArray: getValueArrayFromNodeArray(nodeArray: nodes))
        compareDownToLastNode(from: first, until: endIndex)
    }
    
    
    mutating func CompareDown(_ index: Int) {
        compareDownToLastNode(from: index, until: nodes.count)
    }
    
    func getValueArrayFromNodeArray(nodeArray: [NodeClass]) -> [Int] {
        
        var valueArray = [Int]()
        
        for node in nodeArray {
            valueArray.append(node.value)
        }
        
        return valueArray
        
    }
    
}

