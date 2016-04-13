//
//  Worker.swift
//  Echo
//
//  Created by Elliott Minns on 14/04/2016.
//  Copyright © 2016 Elliott Minns. All rights reserved.
//

import Foundation
import CUV

public protocol Worker: class {
    func task()
}

extension Worker {
    
    public func queueTask(callback: () -> ()) {
        let container = WorkerContainer(worker: self, callback: callback)
        WorkerQueue.defaultQueue.add(worker: container)
    }
    
    public func cancel() {
        
    }
}

func work_cb(req: UnsafeMutablePointer<uv_work_t>!) {
    let queue = unsafeBitCast(req.pointee.data, to: WorkerQueue.self)
    queue.execute()
}

func after_work_cb(req: UnsafeMutablePointer<uv_work_t>!, status: Int32) {
    let queue = unsafeBitCast(req.pointee.data, to: WorkerQueue.self)
    queue.completed()
}

class WorkerContainer {
    
    let worker: Worker
    
    let callback: () -> ()
    
    init(worker: Worker, callback: () -> ()) {
        self.worker = worker
        self.callback = callback
    }
    
}

class WorkerQueue {
    
    static let defaultQueue = WorkerQueue()
    
    var tasks: [WorkerContainer]
    
    var currentTask: WorkerContainer?
    
    var req: UnsafeMutablePointer<uv_work_t>
    
    init() {
        tasks = []
        currentTask = nil
        req = UnsafeMutablePointer<uv_work_t>(allocatingCapacity: 1)
    }
    
    func add(worker: WorkerContainer) {
        
        tasks.append(worker)
        
        if currentTask == nil {
            perform(task: tasks.removeFirst())
        }
    }
    
    func perform(task: WorkerContainer) {
        currentTask = task
        req.pointee.data = unsafeBitCast(self,
                                         to: UnsafeMutablePointer<Void>.self)
        let loop = EchoLoop.instance.loop

        uv_queue_work(loop, req, work_cb, after_work_cb)
    }
    
    func execute() {
        currentTask?.worker.task()
    }
    
    func completed() {
        let task = currentTask
        currentTask = nil
        if tasks.count > 0 {
            perform(task: tasks.removeFirst())
        }
        task?.callback()
    }
}

