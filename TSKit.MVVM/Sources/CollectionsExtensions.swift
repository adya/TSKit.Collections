extension UITableViewCell : TableViewElement, Configurable, Stylable {
    public static var height: CGFloat {
        return 44
    }

    public var dynamicHeight : CGFloat {
        return 44
    }

    public func configure(with dataSource: Any) {}

    public func style(with styleSource: Any) {}
}

extension UITableViewHeaderFooterView : TableViewElement, Configurable, Stylable {
    public static var height: CGFloat {
        return 44
    }

    public var dynamicHeight : CGFloat {
        return 44
    }

    public func configure(with dataSource: Any) {}

    public func style(with styleSource: Any) {}
}