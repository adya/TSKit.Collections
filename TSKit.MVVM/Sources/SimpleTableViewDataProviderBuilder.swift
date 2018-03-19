
class SimpleTableViewDataProviderBuilder : TableViewDataProviderBuilder {
    
    private let log = try! Injector.inject(Log.self, with: TableViewDataProviderBuilder.self)
    
    private let builder : TableViewManagerBuilder
    private var dataProvider : TableViewDataProvider
    
    
    typealias BuildingClosure = (dataProvider : TableViewDataProvider) -> Void
    private let buildingClosure : BuildingClosure
    
    init(builder : TableViewManagerBuilder, buildingClosure : BuildingClosure) {
        self.builder = builder
        self.buildingClosure = buildingClosure
        self.dataProvider = TableViewDataProvider()
    }
    
    func content(closure: TableViewContentProvider) -> Self {
        self.dataProvider.content = closure
        return self
    }
    
    func headers(closure: TableViewSectionsProvider) -> Self {
        self.dataProvider.headers = closure
        if self.dataProvider.footers == nil {
            self.footers(closure)
        }
        return self
    }
    
    func footers(closure: TableViewSectionsProvider) -> Self {
        self.dataProvider.footers = closure
        return self
    }
    
    func build() throws -> TableViewManagerBuilder {
        guard self.dataProvider.content != nil else {
            self.log.error("Content must be set.")
            throw TableViewManagerError.MissingDataProvider
        }
        self.buildingClosure(dataProvider: self.dataProvider)
        return self.builder
    }
}