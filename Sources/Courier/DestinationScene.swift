//
//  DestinationScene.swift
//  Courier
//
//  Created by k2o on 2019/12/03.
//  Copyright © 2019 imk2o. All rights reserved.
//

import UIKit

public protocol ContextScene: class {
    associatedtype Context
    var context: Context { get set }
}

public protocol DestinationScene: ContextScene {
    func contextDidUpdate(_ context: Context, oldContext: Context)
}
public typealias DestinationViewController = UIViewController & DestinationScene

extension DestinationScene where Self: UIViewController {
    public var context: Context {
        get { try! ContextStore.shared.context(for: self) }
        set { ContextStore.shared.store(context: newValue, for: self) }
    }
    
    public func contextDidUpdate(_ context: Context, oldContext: Context) {}
}

//protocol InjectableDestinationScene: ContextScene {
//    init?(coder: NSCoder, context: Context)
//}
//typealias InjectableDestinationVC = UIViewController & InjectableDestinationScene
//
//extension InjectableDestinationScene where Self: UIViewController {
//    static func instantiate(coder: NSCoder, context: Context) -> Self? {
//        return self.init(coder: coder, context: context)
//    }
//}
