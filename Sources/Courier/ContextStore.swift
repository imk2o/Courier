//
//  ContextStore.swift
//  Courier
//
//  Created by k2o on 2019/12/06.
//  Copyright © 2019 imk2o. All rights reserved.
//

import UIKit

class ContextStore {
    enum Error: Swift.Error {
        case contextNotFound(UIViewController)
    }
    
    static let shared = ContextStore()
    
    // 遷移先VCごとのコンテキスト
    // キーを弱参照にすることで, VCの破棄とともに揮発する
    private var destinationToContexts: NSMapTable<UIViewController, ContextHolder> = .weakToStrongObjects()
    
    // 構造体やタプルなどの値型に対応するためのホルダクラス
    private class ContextHolder {
        let body: Any
        
        init(body: Any) {
            self.body = body
        }
    }
    
    private init() {
    }
    
    func store<DestinationVC: DestinationViewController>(
        for destinationViewController: UIViewController,
        contextForDestination: ((DestinationVC) -> DestinationVC.Context)
    ) {
        guard let destinationContentViewController = destinationViewController.contentViewController() as? DestinationVC else {
            fatalError("Destination view controller is not a type of DestinationType.")
        }
        
        let context = contextForDestination(destinationContentViewController)
        self.store(context: context, for: destinationContentViewController)
    }
    
    func store<DestinationVC: DestinationViewController>(
        context: DestinationVC.Context,
        for destinationViewController: DestinationVC
    ) {
        let oldContext = try? self.context(for: destinationViewController)
        
        self.destinationToContexts.setObject(ContextHolder(body: context), forKey: destinationViewController)
        
        // NOTE:
        // DestinationVCでは、contextプロパティのdidSetをオーバライドできないため
        // 代わりにcontextDidUpdate()を実装することで、変更を検知できるようにする
        if let oldContext = oldContext {
            destinationViewController.contextDidUpdate(context, oldContext: oldContext)
        }
    }
    
    func context<DestinationVC: DestinationViewController>(
        for destinationViewController: DestinationVC
    ) throws -> DestinationVC.Context {
        guard let contextHolder = self.destinationToContexts.object(forKey: destinationViewController) else {
            throw Error.contextNotFound(destinationViewController)
        }
        
        return contextHolder.body as! DestinationVC.Context
    }
    
    var debugDescription: String {
        var strings: [String] = []
        let keyEnumerator = self.destinationToContexts.keyEnumerator()
        while let vc = keyEnumerator.nextObject() as? UIViewController {
            guard let context = self.destinationToContexts.object(forKey: vc) else {
                continue
            }
            strings.append("VC: \(vc), context: \(context.body)")
        }
        
        return strings.joined(separator: "\n")
    }
}

extension UIViewController {
    func contentViewController() -> UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController
        } else {
            return self
        }
    }
}
