//
//  ChangeInMyHeapArrayDelegate.swift
//  AutoReleasePool
//
//  Created by Apple on 1/11/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation


protocol UpdateHeapViewDelegate {
    func insirtNode(nodes: inout [NodeClass])
    func switchNode (nodeSwitchedTrackArray: [(Int,Int)])
    func moveLastNodeToTheRoot(node: NodeClass)
    func removeHead(node: NodeClass)
    func updateNodeSwitchIndexTrackingArray(switchIndex : ( Int, Int))
    func switchNodesAccordingToNodeSwitchIndexTrackingArray()
    func drainMyHeap()
}
