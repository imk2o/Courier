//
//  SegueRoute.swift
//  Courier
//
//  Created by k2o on 2019/12/03.
//  Copyright © 2019 imk2o. All rights reserved.
//

import UIKit

protocol SegueContextStorable: class {
    func storeContext(for segue: UIStoryboardSegue, sender: Any?)
}

public class ActionSegueRoute<DestinationVC: DestinationViewController> {
    public typealias ContextProvider = (UIStoryboardSegue, Any?) -> DestinationVC.Context
    private let contextProvider: ContextProvider
    public init(contextProvider: @escaping ContextProvider) {
        self.contextProvider = contextProvider
    }
}

extension ActionSegueRoute: SegueContextStorable {
    func storeContext(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? DestinationVC else {
            return
        }
        
        destinationVC.context = self.contextProvider(segue, sender)
    }
}

public class ManualSegueRoute<DestinationVC: DestinationViewController> {
    public init() {
    }

    public func perform<SourceVC: DeclarativeRoutingViewController>(with context: DestinationVC.Context, from sourceVC: SourceVC) {
        let mirror = Mirror(reflecting: sourceVC.segueRoutes)
        guard
            let child = mirror.children.first(where: {
                guard ($0.value as AnyObject) === self else {
                    return false
                }
                  
                return true
            }),
            let label = child.label
        else {
            return
        }
              
        sourceVC.performSegue(withIdentifier: label, sender: context)
    }
}

extension ManualSegueRoute: SegueContextStorable {
    func storeContext(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? DestinationVC else {
            return
        }
        
        destinationVC.context = sender as! DestinationVC.Context
    }
}

//protocol InjectableDestinationSceneInstantiableContext {
//    func instantiate(with coder: NSCoder) -> UIViewController?
//}
//
//class ManualSegueActionRoute<DestVC: InjectableDestinationVC> {
//    class ContextHolder: InjectableDestinationSceneInstantiableContext {
//        let route: ManualSegueActionRoute<DestVC>
//        let context: DestVC.Context
//
//        init(route: ManualSegueActionRoute<DestVC>, context: DestVC.Context) {
//            self.route = route
//            self.context = context
//        }
//
//        func instantiate(with coder: NSCoder) -> UIViewController? {
//            return DestVC(coder: coder, context: self.context)
//        }
//    }
//
//    init() {
//    }
//
//    func perform<SourceVC: DeclarativeRoutingViewController>(with context: DestVC.Context, from sourceVC: SourceVC) {
//        let mirror = Mirror(reflecting: sourceVC.segueRoutes)
//        guard
//            let child = mirror.children.first(where: {
//                guard ($0.value as AnyObject) === self else {
//                    return false
//                }
//
//                return true
//            }),
//            let label = child.label
//        else {
//            return
//        }
//
//        sourceVC.performSegue(
//            withIdentifier: label,
//            sender: ContextHolder(route: self, context: context)
//        )
//    }
//}

public protocol SegueRouteDeclarations {
    static var shared: Self { get }
}

extension SegueRouteDeclarations {
    func storable(for segue: UIStoryboardSegue, sender: Any?) -> SegueContextStorable? {
        return Mirror(reflecting: self).children
            .first { $0.label == segue.identifier }
            .flatMap { $0.value as? SegueContextStorable }
    }
    
    @discardableResult
    public func prepare(for segue: UIStoryboardSegue, sender: Any?) -> Bool {
        guard let storable = self.storable(for: segue, sender: sender) else {
            return false
        }

        storable.storeContext(for: segue, sender: sender)
        
        return true
    }

//    func instantiate(with coder: NSCoder, sender: Any?) -> UIViewController? {
//        guard let instantiatableContext = sender as? InjectableDestinationSceneInstantiableContext else {
//            return nil
//        }
//
//        return instantiatableContext.instantiate(with: coder)
//    }
}

public protocol DeclarativeRouting {
    associatedtype SegueRoutes: SegueRouteDeclarations
    var segueRoutes: SegueRoutes { get }
}
public typealias DeclarativeRoutingViewController = DeclarativeRouting & UIViewController

extension DeclarativeRouting where Self: UIViewController {
    public var segueRoutes: SegueRoutes { SegueRoutes.shared }
}
