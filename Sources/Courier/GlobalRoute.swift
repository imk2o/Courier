//
//  GlobalRoute.swift
//  DeclarativeRouting
//
//  Created by k2o on 2019/12/06.
//  Copyright © 2019 imk2o. All rights reserved.
//

import UIKit

public class Routes {
    init() {}
}

public class GlobalRoute<DestinationVC: DescribedDestinationViewController>: Routes {
    public override init() {
        super.init()
    }
    
    public func perform<SourceVC: UIViewController>(
        with context: DestinationVC.Context,
        from sourceVC: SourceVC
    ) {
        guard let viewController = DestinationVC.instantiate(with: context) else {
            return
        }
        
        sourceVC.present(viewController, animated: true, completion: nil)
    }
}
