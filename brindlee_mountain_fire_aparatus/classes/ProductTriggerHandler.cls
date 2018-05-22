/*
 * Handler for Product2 trigger
 * @author Dreamwares
 * @lastModifiedDate 2016/09/20
 */
public with sharing class ProductTriggerHandler {
	
    private static final String PRODUCT_IDENTITY_NAME = 'Product Autonumbers';	// name of custom setting record
    
    /*  Autonumber functionality for product records
            1. Updates the Stock Number field on product2 records (truck record type)
            2. Updates the Equipment Number field on product2 (Loose Equipment record type)
     	@param : List of Products
     */
    public static void updateProductAutonumbers(List<Product2> newProducts) {
        Product_Autonumber_Identity__c productIdentity = Product_Autonumber_Identity__c.getValues(PRODUCT_IDENTITY_NAME);
        
        Integer intLatestStockNumber, intLatestEqpmntNum;
        
        intLatestStockNumber = ( productIdentity != null && productIdentity.Latest_Stock_Number__c != null )
                                    ? Integer.valueOf(productIdentity.Latest_Stock_Number__c)
                                    : getStockNumberFromLatestTruck();
        
        intLatestEqpmntNum = ( productIdentity != null && productIdentity.Latest_Equipment_Number__c != null )
                                    ? Integer.valueOf(productIdentity.Latest_Equipment_Number__c)
                                    : 0 ;
        
        Boolean isEqpmntNumUpdated = false,
            	isStockNumUpdated = false;	// denotes change in number fields
        
        Id truckTypeId = Utilities.getProductRecordTypeId('Trucks'),
           looseEqpmntTypeId = Utilities.getProductRecordTypeId('Loose Equipment');
        
        for(Product2 product : newProducts) {		// assign auto numbers manually
            
            if( String.isNotBlank(truckTypeId)
               		&& product.recordTypeId.equals(truckTypeId)) {	// Truck record type
                product.Stock_Number__c = formatInteger(++intLatestStockNumber);
                isStockNumUpdated = true;
            }
            else if( String.isNotBlank(looseEqpmntTypeId)
               		&& product.recordTypeId.equals(looseEqpmntTypeId) ){	// Loose Equipment Type
                product.Equipment_Number__c = 'E'+formatInteger(++intLatestEqpmntNum);
                isEqpmntNumUpdated = true;
            }
        }
        
        if( productIdentity == null ){
            productIdentity = new Product_Autonumber_Identity__c(Name=PRODUCT_IDENTITY_NAME);
        }
        if( isStockNumUpdated ){
            productIdentity.Latest_Stock_Number__c = intLatestStockNumber;
        }
        if( isEqpmntNumUpdated ){
            productIdentity.Latest_Equipment_Number__c = intLatestEqpmntNum;
        }
        upsert productIdentity;
    }
	
	/*
		Get the latest product stock number from the product with the highest stock number
 	 */     
    private static Integer getStockNumberFromLatestTruck(){
        Product2 product;
        try {
            product = [ SELECT Stock_Number__c
                       FROM Product2
                       WHERE recordType.Name = 'Trucks'
                       ORDER BY Stock_Number__c DESC LIMIT 1];
        } catch(Exception exp) {
            system.debug('Exception :: ' + exp.getMessage());
        }
        String strHighStockNumber = ( product != null ) ? product.Stock_Number__c : '0';
        return integer.valueof(strHighStockNumber);	// get latest stock number for use
    }
      
    /*
     	Format integer to include 5 digits (leftpad with 0s)
		@param Integer to format
		@return formatted integer as String
     */
    @testVisible
    private static String formatInteger(Integer intVal){
        if(intVal != null){
            return intVal.format().replaceAll('[,]','').leftPad(5).replaceAll(' ','0');
        }
        return null;
    }
}