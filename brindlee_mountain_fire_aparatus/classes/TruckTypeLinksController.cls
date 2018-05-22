public class TruckTypeLinksController {
    
	/*
    	@return List of Category Wrapper records
    */
    public List<CategoryWrapper> getListCategoryWrappers(){
        List<String> listCategoryEntries = Utilities.generatePicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Apparatus_Type__c');
        
        List<CategoryWrapper> listCategoryWrappers = new List<CategoryWrapper>();
        for( String category : listCategoryEntries ){
            listCategoryWrappers.add(new CategoryWrapper( category ));
        }
        return listCategoryWrappers;
    }
    
    public class CategoryWrapper{
        public String category{ get; set; }
        public String canonicalCategory{ get; set; }
        public String categoryImageName{ get; set; }
        
        public CategoryWrapper( String category ){
            this.category = category;
            this.canonicalCategory = Utilities.getCanonicalCategoryValue(category);
            this.categoryImageName = category.replaceAll(' ','');
        }
    }
}