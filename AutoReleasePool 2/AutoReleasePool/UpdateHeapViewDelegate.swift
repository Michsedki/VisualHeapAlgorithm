//
//  UpdateHeapViewDelegate.swift
//  AutoReleasePool
//
//  Created by Apple on 1/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation


protocol UpdateHeapViewDelegate {
    func insirtNode(nodes: inout [NodeClass])
    func switchNode (nodeSwitchedTrackArray: [(Int,Int)])
    func updateNodeSwitchIndexTrackingArray(switchIndex : ( Int, Int))
    func clearNodeSwitchIndexTrackingArray()
    func removeHead(node: NodeClass)
    func updateDisplayArrayLabel(nodeArray: [Int])

    
    func removeHeadMoveLastNodeToTheRoot(rootNodeToRemove: NodeClass, lastNodeToReplace : NodeClass)


}
