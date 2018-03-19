
class SimpleReusableViewBuilder <ReusableViewType where ReusableViewType : TableViewElement, ReusableViewType : Configurable> : ReusableViewBuilder {
    private let log = try! Injector.inject(Log.self, with: ReusableViewBuilder.self)
    
    private let builder : TableViewManagerBuilder
    private let viewType : ReusableViewType.Type
    private var dataSourceType : ReusableViewType.TSPresenterDataSource.Type
    
    typealias BuildingClosure = (viewType : TableViewElement.Type, dsType : Any.Type) -> Void
    private let buildingClosure : BuildingClosure
    
    init(builder : TableViewManagerBuilder, viewType : ReusableViewType.Type, buildingClosure : BuildingClosure) {
        self.builder = builder
        self.viewType = viewType
        self.dataSourceType = viewType.TSPresenterDataSource.self
        self.buildingClosure = buildingClosure
    }
    
    func forDataSource(dataSource : Any.Type) -> TableViewManagerBuilder {
        guard let acceptableDataSource = dataSource as? ReusableViewType.TSPresenterDataSource.Type else {
            self.log.error("'\(self.viewType)' can't be configured with '\(dataSource)' (dataSource must conform to '\(ReusableViewType.TSPresenterDataSource.self)'.")
            return self.builder
        }
        self.dataSourceType = acceptableDataSource
        self.buildingClosure(viewType: self.viewType, dsType: self.dataSourceType)
        return self.builder
    }
    
    func forDefaultDataSource() -> TableViewManagerBuilder {
        self.buildingClosure(viewType: self.viewType, dsType: self.dataSourceType)
        return self.builder
    }
}