/*
 * This is a controller class for vf page Homepage used on firetruckmall.com
 * @created 2016/07/15
 * @author Dreamwares (Aditya S.)
 */
public class FilterComponent_Controller {
    
    // Values chosen from picklist    
    public String selBudgetMin{
        get{
            return String.isBlank(selBudgetMin) ? '0' : selBudgetMin;
        } set;}           
    public String selBudgetMax{
        get{   
            return String.isBlank(selBudgetMax) ? '1200000' : selBudgetMax;
        }set;}
    public String selCategory{
        get{
            return String.isBlank(selCategory) ? 'All' : selCategory;
        } set;}
     public List<String> listSelBrands{
        get{
            return listSelBrands == null ? new List<String>{'All'} : listSelBrands;
        } set;}
    public String selMileageOption{
        get{
            return String.isBlank(selMileageOption) ? 'Any Mileage' : selMileageOption;
        } set;}
    public String selYearMin{
        get{
            return String.isBlank(selYearMin) ? '1970' : selYearMin;
        } set;}
    public String selYearMax{
        get{
            return String.isBlank(selYearMax) ? String.valueOf(System.Today().year()) : selYearMax;
        } set;}
    public String selChassis{
        get{
            return String.isBlank(selChassis) ? 'Both' : selChassis;
        } set;}
   
    public String selPumpSize{
        get{
            return String.isBlank(selPumpSize) ? 'All' : selPumpSize;
        } set;}
    public String selTankSize{
        get{
            return String.isBlank(selTankSize) ? 'All' : selTankSize;
        } set;}
    public String selWarrantyOption{
        get{
            return String.isBlank(selWarrantyOption) ? 'All' : selWarrantyOption;
        } set;}
    public List<String> listSelRegions{
        get{
            return listSelRegions == null ? new List<String>{'All'} : listSelRegions;
        } set;}
    
        
    public List<SelectOption> getPriceOptions(){          // Get list of options for Budget Lists
        return Utilities.getPriceOptions();
    }

    public List<SelectOption> getYearOptions(){           // Get year options for picklists
        return Utilities.getPicklistYearOptions();
    }
    
    public List<SelectOption> getChassisTypes(){    // create picklist for chassis types
        return Utilities.generatePicklistFieldOptions( new Fire_Truck__c(),'Custom_Commercial__c','Both');
    }
    
    public List<SelectOption> getBrands(){    // create picklist for brands
        return Utilities.generatePicklistFieldOptions( new Fire_Truck__c(),'Fire_Body_Manufacturer__c','All');
    }
    
    public List< SelectOption > getPumpSizeRanges(){    // create picklist for pump size ranges
        return Utilities.getPicklistPumpSizeOptions();
    }
        
    public List<SelectOption> getTankSizeRanges(){     // create picklist for tank size ranges
        return Utilities.getPicklistTankSizeOptions();
    }
    
    public List<SelectOption> getCategories(){    // create picklist for categories
        return Utilities.generatePicklistFieldOptions(new Product2(),'apparatusType__c','All');
    }
    
    public List<SelectOption> getMileageOptions(){
        return Utilities.generatePicklistFieldOptions( new Fire_Truck_Finder_Criteria__c(), 'FTF_Mileage__c', '' );
    }
    
    public List<SelectOption> getGeographicRegions(){
        return Utilities.generatePicklistFieldOptions( new Fire_Truck_Finder_Criteria__c(), 'FTF_Geographic_Region__c', '' );
    }
    
    public List<SelectOption> getWarrantyOptions(){    // Create picklist for Warranty options
        return Utilities.getPicklistWarrantyOptions();
    }
    
    /*
     This method redirects to the Avaiable Trucks page with the picklist parameters mapped in the url
     
     @return Page reference
    */
    public PageReference redirectToAvailableTrucksPageWithUrlParams(){
        String availableTrucksUrl = String.format('/AvailableTrucks/{0}?price={1}-{2}&year={3}-{4}&brand={5}&chassis={6}&pumpsize={7}&tanksize={8}&mileage={9}&region={10}&warranty={11}',
                                        new List<String>{ Utilities.getCanonicalCategoryValue(selCategory), selBudgetMin, selBudgetMax, selYearMin,
                                                          selYearMax, String.join(listSelBrands, ';'), selChassis, selPumpSize, 
                                                          selTankSize, selMileageOption, String.join(listSelRegions,';'), selWarrantyOption });
        return new PageReference( availableTrucksUrl );
    }
}