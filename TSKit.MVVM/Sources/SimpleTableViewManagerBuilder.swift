import UIKit

class SimpleTableViewManagerBuilder : TableViewManagerBuilder {
    
    private let log = try! Injector.inject(Log.self, with: TableViewManagerBuilder.self)
    
    private let tableView : UITableView
    private var registeredViews : [String : TableViewElement.Type] = [:]
    private var dataProvider : TableViewDataProvider?
    init(tableView : UITableView) {
        self.tableView = tableView
    }
    
    func consume() -> TableViewDataProviderBuilder {
        return SimpleTableViewDataProviderBuilder(builder: self) {
            self.dataProvider = $0
        }
    }
    
    func build() throws -> TableViewManager {
        guard let dataProvider = self.dataProvider else {
            self.log.error("DataProvider must be set.")
            throw TableViewManagerError.MissingDataProvider
        }
        
        return TableViewManager(tableView: self.tableView,
                                registeredViews: self.registeredViews,
                                dataProvider: dataProvider)
    }
    
    func registerContentCell<T where T : UITableViewCell, T : TableViewElement, T : Configurable>(cell : T.Type) -> ReusableViewBuilder {
        return SimpleReusableViewBuilder(builder: self, viewType: cell, buildingClosure: self.register)
    }
    
    func registerHeaderView<T where T : UITableViewHeaderFooterView, T : TableViewElement, T : Configurable>(view : T.Type) -> ReusableViewBuilder {
        return SimpleReusableViewBuilder(builder: self, viewType: view, buildingClosure: self.register)
    }
    
    func registerFooterView<T where T : UITableViewHeaderFooterView, T : TableViewElement, T : Configurable>(view : T.Type) -> ReusableViewBuilder {
        return SimpleReusableViewBuilder(builder: self, viewType: view, buildingClosure: self.register)
    }
    
    private func register(viewType : TableViewElement.Type, dsType : Any.Type) {
        self.registeredViews["\(dsType)"] = viewType
    }
}