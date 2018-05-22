/*
 Controller for Upload Loose Equipment vf page
 @createdDate - 2016/08/29
 @createdBy   - Dreamwares (Aditya S.)
 */
public class UploadLooseEquipmentController {
    
    /*
        Get price for the Loose Equipment Listing on firetruckmall.com
    */
    public Loose_Equipment_Pricing__c getLooseEquipmentPricing(){
         List<Loose_Equipment_Pricing__c> listPricings = Loose_Equipment_Pricing__c.getAll().values();
         if(!listPricings.isEmpty()){
             return listPricings[0];
         }
         return null;
    }
    
    /*
        Get json serialized picklist values
        @param SObject Type
        @param field name
        @return json string for picklist values
    */
    private String getSerializedPicklistValues(SObject SobjectType, String strFieldAPIName){
        if(SobjectType != null && String.isNotBlank(strFieldAPIName)){
            List<String> listPicklistVals;
            try{
                listPicklistVals = Utilities.generatePicklistValues(SobjectType, strFieldAPIName);
            }
            catch(Exception e){
                System.debug('Could not fetch picklist values ::: '+ e);
            }
            if(listPicklistVals != null && !listPicklistVals.isEmpty()){
                return JSON.Serialize(listPicklistVals);
            }
        }
        return null;
    }
    
    public String getLoginCredentials(){    // API credentials for AWS
        List<AWS_Credentials__c> listAWSCredentials = AWS_Credentials__c.getAll().values();
        return !listAWSCredentials.isEmpty() ? JSON.serialize(listAWSCredentials[0]) : null;
    }
    
    public String getLooseEquipmentTypes(){    // get serialized picklist options for chassis types
        return getSerializedPicklistValues(new Product2(), 'Loose_Equipment_Type__c');
    }
    
    public String getChargentBillingStateValues(){    // get serialized picklist options for chassis types
        return getSerializedPicklistValues(new ChargentOrders__ChargentOrder__c(), 'ChargentOrders__Billing_State__c');
    }
    
    /*
        register a user for the Loose Equipment listing
        @param json account
        @param json contact
        @param json product
        @param json Chargent Order
        @return json ConsolidatedResponse
    */
    @remoteAction
    public static String registerLooseEquipmentListing( String jsonAcc, String jsonCon, String jsonProduct, String jsonChargentOrder ){
        if( String.isNotBlank(jsonAcc) && String.isNotBlank(jsonCon) && String.isNotBlank(jsonProduct) && String.isNotBlank(jsonChargentOrder) ){
            Account objAccount;
            Contact objContact;
            Product2 objProduct;
            ChargentOrders__ChargentOrder__c chargentOrder;
            try{
                objAccount = (Account)JSON.deserialize(jsonAcc, Account.class);
                objContact = (Contact)JSON.deserialize(jsonCon, Contact.class);
                                
                objProduct = (Product2)JSON.deserialize(jsonProduct, Product2.class);    
                objProduct.Equipment_Listing_Date__c = System.today();    // set some other product field values
                objProduct.IsActive = True;
                
                chargentOrder = (ChargentOrders__ChargentOrder__c)JSON.deserialize(jsonChargentOrder, ChargentOrders__ChargentOrder__c.class);
            }
            catch(Exception e){
                System.debug('Exception in Deserializing records ::: '+ e);
            }
            
            return processRegistration( objAccount, objContact, objProduct, chargentOrder );
        }
        return null;
    }
    
    /*
        Register new records for account, contact, product and chargent order
        @param Account
        @param Contact
        @param Product
        @param Chargent Order
        @return json ConsolidatedResponse
    */
    private static String processRegistration( Account objAccount, Contact objContact, Product2 objProduct, ChargentOrders__ChargentOrder__c chargentOrder ){
        if( objAccount != null && objContact != null && objProduct != null && chargentOrder != null ){            
            Contact existingContact = fetchExisingContact(objContact.Email);
            
            if( existingContact != null ){
                return processRegForExistingCustomer( existingContact, objAccount, objProduct, chargentOrder );
            }
            else{
                return processRegForNewCustomer(objAccount, objContact, objProduct, chargentOrder);
            }
        }
        else{
            return getSerializedResponse( new ConsolidatedResponse( 'Error! Could not process your request!<br/>Please contact our customer support!', null, null, null ) );
        }
    }
    
    /*
        Register new Loose Equipment for existing contact from the org.
        @param Existing Contact
        @param Account
        @param Product
        @param Chargent Order
        @return json ConsolidatedResponse
    */
    private static String processRegForExistingCustomer( Contact existingContact, Account objAccount, Product2 objProduct, ChargentOrders__ChargentOrder__c chargentOrder ){
        objProduct.Equipment_Owner__c = existingContact.Id;
        objProduct.RecordTypeId = Utilities.getProductRecordTypeId('Loose Equipment');
        Id ProductId = insertProduct(objProduct);
        
        if(String.isNotBlank(ProductId)){
            Id accId;
            if( String.isNotBlank(existingContact.AccountId)){    // get account Id
                accId = existingContact.AccountId;
            }
            else{        // create account if necessary
                accId = insertAccount(objAccount);
                existingContact.AccountId = accId;
                upsertContact(existingContact);
            }
            
            chargentOrder.ChargentOrders__Account__c = accId;
            return handleChargentOrderCreation( chargentOrder, productId, existingContact.Id );
        }
        else{
            return getSerializedResponse( new ConsolidatedResponse('Error! Could not create your product record!<br/>Please contact our customer support!', null, null, null));
        }
    }
    
    /*
        Create chargent record and if fails delete the product(Loose Equipment)
        @param Chargent Order
        @param Product Id
        @param Contact Id
        @return json ConsolidatedResponse
    */
    private static String handleChargentOrderCreation(ChargentOrders__ChargentOrder__c chargentOrder, Id productId, Id contactId){
        if( chargentOrder != null && String.isNotBlank(productId) && String.isNotBlank(contactId) ){
            ConsolidatedResponse response = insertChargentOrder(chargentOrder);
            //System.debug('Final Response :'+response);
            
            if( String.isNotBlank(response.chargentId) ){
                return getSerializedResponse(new ConsolidatedResponse( 'success', productId, contactId, response.chargentId ));
            }
            else{
                deleteProductWithId(ProductId);
                return getSerializedResponse(response);
            }
        }
        return null;
    }
    
    /*
        Register new Loose Equipment for a new contact / account
        @param Account
        @param Contact
        @param Product
        @param Chargent Order
        @return json ConsolidatedResponse
    */
    private static String processRegForNewCustomer( Account objAccount, Contact objContact, Product2 objProduct, ChargentOrders__ChargentOrder__c chargentOrder ){
        Id accId = insertAccount(objAccount);
                
        if( String.isNotBlank(accId) ){
            objContact.AccountId = accId;
            Id conId = upsertContact(objContact);
            
            if( String.isNotBlank(conId) ){
                objProduct.Equipment_Owner__c = conId;
                objProduct.RecordTypeId = Utilities.getProductRecordTypeId('Loose Equipment');
                
                if( String.isNotBlank(objProduct.RecordTypeId) ){
                    Id productId = insertProduct(objProduct);
                    
                    if( String.isNotBlank(ProductId) ){    // create chargent Order
                        chargentOrder.ChargentOrders__Account__c = accId;
                        return handleChargentOrderCreation( chargentOrder, productId, conId );
                    }
                    else{
                        return getSerializedResponse( new ConsolidatedResponse( 'Error! Could not create your Loose Equipment record. Please contact our customer support!', null, null, null ));
                    }
                }
                else{
                    return getSerializedResponse( new ConsolidatedResponse( 'Sorry! An internal error occurred.<br/> Please contact our customer support!', null, null, null ));
                }
            }
            else{
                return getSerializedResponse( new ConsolidatedResponse( 'Error! Could not create your Contact record.<br/>Please contact our customer support!', null, null, null ));
            }
        }
        else{
            return getSerializedResponse( new ConsolidatedResponse( 'Error! Could not create your Account record.<br/>Please contact our customer support!', null, null, null ));
        }
    }
    
    /*
        Remote action to charge an account using chargent. If charging fails, the product is deleted
        @param Chargent Order Id
        @param Contact Id
        @return json response ChargentUtility.TransactionChargeResponse
    */
    @remoteAction
    public static String ChargeOrder( Id chargentOrderId, Id productId, Id contactId ){
        if( String.isNotBlank(chargentOrderId) && String.isNotBlank(productId) ){
            ChargentUtility.TransactionChargeResponse response;
            try{
                response = ChargentUtility.charge(chargentOrderId);
            }
            catch(Exception e){
                System.debug('Exception in making a charge for ChargentOrderId:'+ chargentOrderId +' :: '+e);
                return getSerializedResponse( new ConsolidatedResponse( e.getMessage(), null, null, null ));
            }
            System.debug('Response:'+response);
            
            if( response != null ){
                if( !response.isSuccess ){
                    deleteProductWithId(productId);
                }
                else if( response.status.equals('Approved')
                         || ( Test.isRunningTest() && response.status.equals('UNKNOWN') ) ){
                    sendLooseEqpmntNotificationEmail( productId, contactId );
                }
            }
            else{
                deleteProductWithId(productId);
            }
            return JSON.serialize(response);
        }
        return null;
    }
    
    private static void deleteProductWithId(Id productId){
        if(String.isNotBlank(productId)){
            try{
                delete new Product2(Id=productId);
            }
            catch(Exception e){
                System.debug('Exception in deleting product :: '+ e);
            }
        }
    }
    
    /*
        Insert chargent order record
        @param Chargent Order
        @return ConsolidatedResponse
    */
    private static ConsolidatedResponse insertChargentOrder(ChargentOrders__ChargentOrder__c chargentOrder){
        if( chargentOrder != null ){
            try{
                insert chargentOrder;
                return new ConsolidatedResponse( 'success', null, null, chargentOrder.Id );
            }
            catch(DMLException e){
                return new ConsolidatedResponse( e.getDmlMessage(0), null, null, null );
                System.debug('DML Exception in inserting Chargent Order:'+e);
            }
            catch(Exception e){
                return new ConsolidatedResponse( 'Sorry! Could not create your payment record. Please try again later.<br/>If problem persists, please contact our customer support.', null, null, null );
                System.debug('Exception in inserting Chargent Order:'+e);
            }
        }
        return null;
    }
    
    private static Id insertAccount( Account acc ){
        if( acc != null ){
            try{
                insert acc;
                return acc.Id;
            }
            catch(Exception e){
                System.debug('Exception in upserting Account :'+ e);
            }
        }
        return null;
    }
    
    private static Id upsertContact( Contact con ){
        if( con != null ){
            try{
                upsert con;
                return con.Id;
            }
            catch(Exception e){
                System.debug('Exception in upserting Contact :'+ e);
            }
        }
        return null;
    }
    
    private static Id insertProduct( Product2 product ){
        if( product != null ){
            try{
                insert product;
                return product.Id;
            }
            catch(Exception e){
                System.debug('Exception in upserting Product :'+ e);
            }
        }
        return null;
    }
    
    /*
        Get contact record with given email Id
        @param email
        @return contact record
    */
    private static Contact fetchExisingContact(String email){
        if( String.isNotBlank(email) ){
            try{
                return [ SELECT Id, AccountId
                         FROM Contact
                         WHERE Email=:email
                         LIMIT 1 ];
            }
            catch(Exception e){
                System.debug('Exception in fetching Contact :'+ e);
            }
        }
        return null;
    }
    
    /*
        Send email to the user registering for Loose Equipment listing
        @param Product Id
        @param Contact Id
        @return Boolean - result of operation
    */
    private static Boolean sendLooseEqpmntNotificationEmail( Id productId, Id contactId ){
        if( String.isNotBlank(productId) && String.isNotBlank(contactId) ){
            OrgWideEmailAddress orgWideEmail = Utilities.getOrgWideEmailAddress(Label.FTF_Notification_OrgWideEmailAddress);
            Id templateId = Utilities.getEmailTemplateId('Loose_Equipment_Listing');
            
            if( orgWideEmail != null && String.isNotBlank(templateId) ){
                return Utilities.sendEmailViaTemplate( templateId, contactId, productId, false, orgWideEmail.Id );
            }
        }
        return false;
    }
    
    /*
        Update Account, Contact and Product records of the customer
        @param json Account
        @param json Contact
        @param json Product
        @return Boolean - result of operation
    */
    @remoteAction
    public static Boolean updateLooseEqmntListingDetails( String jsonAcc, String jsonCon, String jsonProduct ){
        if( String.isNotBlank(jsonAcc) && String.isNotBlank(jsonCon) && String.isNotBlank(jsonProduct) ){
            Account objAccount;
            Contact objContact;
            Product2 objProduct;
            try{
                objAccount = (Account)JSON.deserialize(jsonAcc, Account.class);
                objContact = (Contact)JSON.deserialize(jsonCon, Contact.class);
                objProduct = (Product2)JSON.deserialize(jsonProduct, Product2.class);
                
                update objAccount;
                update objContact;
                update objProduct;
                
                return true;
            }
            catch(Exception e){
                System.debug('Exception in deserializing : '+ e);
            }
        }
        return false;
    }
    
    /*
        convert ConsolidatedResponse to json
    */    
    public static String getSerializedResponse( ConsolidatedResponse response ){
        if( response != null ){
            return JSON.serialize(response);
        }
        return null;
    }
    
    // Wrapper class to hold response from operations
    public class ConsolidatedResponse {
        public String message { get; set;}
        public Id productId { get; set; }
        public Id contactId { get; set; }
        public Id chargentId { get; set; }
        
        public ConsolidatedResponse( String message, Id productId, Id contactId, Id chargentId ){
            this.message = message;
            this.productId = productId;
            this.contactId = contactId;
            this.chargentId = chargentId;
        }        
    }
}