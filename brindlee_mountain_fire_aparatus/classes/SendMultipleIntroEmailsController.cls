/*
 * @description - Controller for Vf page SendMultipleIntroEmails
 * @createdDate - 12/2/2016
 * @createdby   - Dreamwares
 */
public with sharing class SendMultipleIntroEmailsController {
    
    public String fieldWrapperJson{        // Json consisting of records from Field Wrapper
        get{
            return JSON.Serialize( createListFieldWrapper() );
        }
        set;
    }
    
    /*
    @description - Create list of Field wrapper DTO
    @outputParam - List of Field Wrapper objects
    */
    @testVisible
    private static List<FieldWrapper> createListFieldWrapper(){
        List<FieldWrapper> listFieldWrapper = new List<FieldWrapper>();
        FieldWrapper fieldWrapper;
        Schema.describeFieldResult fieldRes;
        String strFieldType, strDisallowedFieldTypes='TEXTAREA';
        Map <String, Schema.SObjectField> fieldMap = getMapProductFields();
        
        for(Schema.SObjectField currentField : fieldMap.values())
        {   
            fieldRes = currentField.getDescribe();
            strFieldType = String.valueOf(fieldRes.getType());
            
            // Create FieldsWrapper Objects for datatypes other than text area and reference types
            if( !strDisallowedFieldTypes.contains(strFieldType)){    
                fieldWrapper = new FieldWrapper( fieldRes.getlabel(), String.valueOf( fieldRes.getSobjectField() ), strFieldType );
                listFieldWrapper.add(fieldWrapper);
            }
        }
        return listFieldWrapper;
    }
    
    /*
    @description - get map containing Field and info for Products fields
    @outputParam - Map of Field name and SObjectField
    */
    private static Map <String, Schema.SObjectField> getMapProductFields(){
        return SOBjectType.Product2.fields.getMap();
    }
    
    /*
    @description - Start the functionality for Send Multiple intro emails
    @inputParam  - 1. Customer (Lead/Contact) Id    
                   2. String with List of Products Ids
    @outputParam - Errors string  if exists
    */
    @remoteAction
    public static String initiateMultipleIntroEmailsProcess( Id customerId, String strProductIds, String strNotes ){
        if( String.isNotBlank(customerId) && String.isNotBlank(strProductIds) ){
            Set<Id> setProductIds;
            try{
                setProductIds = (Set<Id>)System.JSON.deserialize(strProductIds, Set<Id>.class);
            }
            catch(Exception e){
                System.debug('Exception in deserializing Product Ids Json ::: '+ e);
                return getFormattedError('<li>Could not parse the Product Ids!</li>');
            }
            
            if(setProductIds != null && !setProductIds.isEmpty()){
                String errMsg = '';
                
                errMsg = updateCustomerRecord(customerId, strNotes);
                if(String.isNotBlank(errMsg)){
                    return getFormattedError(errMsg);
                }
                
                List<Product2> listProducts = fetchSelectedProduct(setProductIds);
                if(!listProducts.isEmpty()){
                    errMsg = handleMultipleIntroEmailsProcess(customerId, listProducts);
                    return getFormattedError(errMsg);
                }
            }
        }
        return getFormattedError('Required arguments not found!');
    }
    
    /*
    @description - Get html formatted error string
    */
    private static String getFormattedError( String errmsg ){
        String errTemplate = '<b>Error</b> :<ul>{0}</ul>';
        return String.isBlank(errMsg) ? errMsg : String.format( errTemplate, new List<String>{errMsg});
    }
    
    /*
    @description - Update the notes for Customer (Contact/Lead)
    @inputParam - 1. Contact/Lead Id        2. Notes to update
    @outputParam - Errors string if exist
    */
    private static String updateCustomerRecord( Id customerId, String strNotes ){
        if(String.isNotBlank(customerId)){
            if( getSObjectTypeFromId(customerId) == Schema.Lead.SObjectType ){
                return modifyAndUpdateLead(customerId, strNotes);    
            }
            else{
                return modifyAndUpdateContact(customerId, strNotes);
            }
        }
        return '';
    }
    
    /*
    @description - Update the notes for Lead
    @inputParam - 1. Lead Id        2. Notes to update
    @outputParam - Errors string if exist
    */
    private static String modifyAndUpdateLead( Id customerId, String strNotes ){
        Lead lead = new lead();
        lead.Id = customerId;
        lead.Send_Multiple_Intro_Email_Notes__c = String.isEmpty(strNotes) ? null : strNotes;
        
        try{
            update lead;
        }
        catch(Exception e){
            System.debug('Exception ::: '+ e);
            return '<li>'+ e.getMessage() +'</li>';
        }
        return '';
    }
    
    /*
    @description - Update the notes for Contact
    @inputParam - 1. Contact Id        2. Notes to update
    @outputParam - Errors string if exist
    */
    private static String modifyAndUpdateContact( Id customerId, String strNotes ){
        Contact contact = new Contact();
        contact.Id = customerId;
        contact.Send_Multiple_Intro_Email_Notes__c = String.isEmpty(strNotes) ? null : strNotes;
        
        try{
            update contact;
        }
        catch(Exception e){
            System.debug('Exception ::: '+ e);
            return '<li>'+ e.getMessage() +'</li>';
        }
        return '';
    }
    
    /*
    @description - Get Products with given Ids
    @inputParam  - Set of Product Ids
    @outputParam - List of products
    */
    private static List<Product2> fetchSelectedProduct(Set<Id> setProductIds){
        if( setProductIds != null && !setProductIds.isEmpty()){
            return [ SELECT Id, Name, Seller_Email__c, Seller_Contact__c
                     FROM Product2
                     WHERE Id IN: setProductIds];
        }
        return null;
    }
    
    /*
    @description - Send email to customer and create truck inquiry records
    @inputParam  - 1. Customer (Lead/Contact) Id    
                   2. List of Products
    @outputParam - Response errors (id exists)
    */
    private static String handleMultipleIntroEmailsProcess(Id customerId, List<Product2> listProducts){
        Sobject customerRec = getCustomerRecord(customerId);
        
        if(String.isNotBlank((String)customerRec.get('Email'))){
            String strErrMsg = sendMultipleIntroEmailsToCustomer(customerRec, listProducts);
            strErrMsg += createTruckInquiries(customerRec, listProducts);
            return strErrMsg;
        }
        return '<li>Email Id Not Present for Customer!</li>';
    }
    
    /*
    @description - Send email to customer for each product selected
    @inputParam  - 1. Customer (Lead/Contact) Id    
                   2. List of Products
    @outputParam - Errors if exist (String)
    */
    private static String sendMultipleIntroEmailsToCustomer( SObject customerRec, List<Product2> listProducts){
        if( customerRec != null
                && listProducts != null && !listProducts.isEmpty() ){
                
            String strResponse = '';
            Id customerId = (Id)customerRec.get('Id');
            Id templateId = getEmailTemplateIdForSObjectType(customerId);
            
            if(String.isNotBlank(templateId)){ 
                              
                Messaging.SingleEmailMessage email;
                Map<Id, Messaging.SingleEmailMessage> mapProductIdToEmail = new Map<Id, Messaging.SingleEmailMessage>();
                
                List<String> listRecipients = new List<String>();
                listRecipients.add(getCurrentUsersEmailId());
                
                for( Product2 currentProduct : listProducts){
                                
                    if(String.isNotBlank(currentProduct.Seller_Email__c)){
                        listRecipients.add( currentProduct.Seller_Email__c );
                    }
                    email = createEmail( customerId, currentProduct.Id,                 
                                         templateId, listRecipients);                    // create email for current product
                                         
                    if( listRecipients.size() > 1 ){                                    // remove current product's seller's email Id from list
                        listRecipients.remove(1);
                    }
                                         
                    if( email != null ){
                        mapProductIdToEmail.put( currentProduct.Id, email );
                    }
                }
                strResponse += sendEmails(mapProductIdToEmail.values());                // Send emails to customer
                            
                if( getSObjectTypeFromId(customerId) == Schema.Lead.SObjectType ){      // create tasks if customer type is Lead
                    createTasksFromEmails(customerId, (String)customerRec.get('Email'), listProducts, mapProductIdToEmail);
                }
                return strResponse;
            }
            else{
                strResponse += '<li>Could not get template for sending emails!</li>';
                return strResponse;
            }
        }
        return null;
    }
    
    /*
    @description - Fetch the Current User's email Id
    @outputParam - Current User's email Id
    */
    private static String getCurrentUsersEmailId(){
        return UserInfo.getUserEmail();
    }
    
    /*
    @description - Create emails with given Template Id
    @inputParam  - 1. Customer (Lead/Contact) Id    
                   2. Product Id
                   3. Template Id
                   4. Additional To addresses
    @outputParam - Messaging.SingleEmailMessage
    */
    private static Messaging.SingleEmailMessage createEmail( Id customerId, Id productId, Id templateId, List<String> listAdditionalEmailIds ){
        if( String.isNotBlank( customerId )
                && String.isNotBlank( productId )
                && String.isNotBlank( templateId )){
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(templateId);
            email.setTargetObjectId(customerId);
            email.setWhatId(productId);
            
            if( getSObjectTypeFromId(customerId) == Schema.Lead.SObjectType ){
                email.setSaveAsActivity(False);
            }
            
            if(listAdditionalEmailIds!= null && !listAdditionalEmailIds.isEmpty()){    // additional addresses
                email.setToAddresses(listAdditionalEmailIds);
            }
            return email;
        }
        return null;
    }
    
    /*
    @description - Send emails
    @inputParam  - List of SingleEmailMessages
    @outputParam - Error response if exists
    */
    private static String sendEmails( List<Messaging.SingleEmailMessage> listEmails ){
    String errors = '';
        if( listEmails != null && !listEmails.isEmpty() ){
            Messaging.SendEmailResult[] results;
            try{
                results = Messaging.sendEmail( listEmails );
            }
            catch(Exception e){
                System.debug('Exception in sending emails ::: '+ e);
                errors = '<li>' + e.getMessage() +'</li>';
                return errors;
            }
            if(results != null && !results.isEmpty()){
                for( Messaging.SendEmailResult emailResult : results){
                    if( !emailResult.success ){
                        errors += '<li>' + emailResult.getErrors()[0].getMessage() + '</li>';
                    }
                }
            }
        }
        return errors;
    }
    
    /*
    @description - Get email Id for current Customer
    @inputParam  - Customer (Lead/Contact) Id    
    @outputParam - Email Id for current Customer
    */
    private static SObject getCustomerRecord( Id customerId ){
        if( String.isNotBlank(customerId)){
            Schema.SObjectType token = getSObjectTypeFromId(customerId);
            String strCustomerEmailId;
            Sobject objSobject;
            
            if( token == Schema.Lead.SObjectType ){
                objSobject = getLeadSObjectFromId(customerId);
            }
            else if( token == Schema.Contact.SObjectType ){
                objSobject = getContactSObjectFromId(customerId);
            }
            return objSobject;
        }
        return null;
    }
    
    /*
    @description - Get email Id for Lead record
    @inputParam  - Lead Id
    @outputParam - Email Id for Lead record
    */
    private static Sobject getLeadSObjectFromId( Id leadId ){
         if( String.isNotBlank(leadId)){
             try{
                 Lead lead = [SELECT Id, Email, OwnerId FROM Lead WHERE Id=:leadId];
                 return (Sobject)lead;
             }
             catch(Exception e){
                 System.debug('Exception in fetching Lead ::: '+ e);
             }
         }
         return null;
    }
    
    /*
    @description - Get email Id for Contact
    @inputParam  - Contact Id
    @outputParam - Email Id for Contact record
    */
    private static Sobject getContactSObjectFromId(Id contactId){
         if( String.isNotBlank(contactId)){
             try{
                 Contact contact = [ SELECT Id, Email, OwnerId FROM contact WHERE Id=:contactId ];
                 return (SObject)contact;
             }
             catch(Exception e){
                 System.debug('Exception in fetching contact ::: '+ e);
             }
         }
         return null;
    }
    
    /*
    @description - Create task records from emails
    @inputParam  - 1. Customer Id
                   2. Email Id for Customer record
                   3. List of Products
                   4. Map of product Id to corresponding email
    */
    private static void createTasksFromEmails( Id customerId,
                                                    String strRecipientEmailId,
                                                    List<Product2> listProducts,
                                                    Map<Id, Messaging.SingleEmailMessage> mapProductIdsToEmails){
        if( String.isNotBlank(customerId)
                && listProducts != null && !listProducts.isEmpty()
                && mapProductIdsToEmails != null && !mapProductIdsToEmails.isEmpty() ){
            
            List<Task> listTasks = new List<Task>();
            Task task;
            String strEmailSubject;
            Messaging.SingleEmailMessage email;
            Date dateToday = System.Today();
            
            for(Product2 currentProduct : listProducts){
                email = mapProductIdsToEmails.get(currentProduct.Id);
                
                task = new Task();
                task.ActivityDate = dateToday;
                task.Priority = 'Normal';
                task.Status = 'Completed';
                task .Type = 'Email';
                task.WhoId = customerId;
                strEmailSubject = email.getSubject();
                task.Subject = strEmailSubject;
                task.Description = getDescriptionForEmail( strRecipientEmailId, email.getToAddresses(), email.getPlainTextBody(), strEmailSubject );
                listTasks.add(task);
            }
            
            insertTasks(listTasks);
        }
    }
    
    /*
    @description - Insert tas records
    @inputParam  - List of tasks
    */
    private static void insertTasks(List<Task> listTasks){
        if( listTasks != null && !listtasks.isEmpty() ){
            try{
                insert listTasks;
            }
            catch(Exception e){
                System.debug('Exception in inserting tasks ::: '+ e);
            }
        }
    }
    
     /*
    @description - Get description for creating task record from product info
    @inputParam  - 1. Email Id of recipient
                   2. List of email additional addresses
                   3. Email body
                   4. Email subject
    @outputParam - String - subject 
    */
    private static String getDescriptionForEmail( String strRecipientEmailId, List<String> listExtraAddresses, String strEmailBody, String strEmailSubject ){
        if( String.isNotBlank(strRecipientEmailId) && String.isNotBlank(strEmailBody) ){
            String strExtraAddresses =  listExtraAddresses != null 
                                        ? String.join(listExtraAddresses,',') 
                                        : '';
            List<String> listArguments =  new List<String>{ strRecipientEmailId, strExtraAddresses, strEmailSubject, strEmailBody };
            return String.format('To:{0}\nAdditional To:{1}\n\nSubject:{2}\n\nBody:\n{3}}', listArguments);
        }
        return null;
    }
        
    /*
    @description - Create Truck inquiry records for each product selected
    @inputParam  - 1. Customer (Lead/Contact) Id    
                   2. List of Products
    @outputParam - Error response if exists from inserting truck inquiries
    */
    private static String createTruckInquiries( Sobject customerRec, List<Product2> listProducts ){
        if( customerRec != null && listProducts != null && !listProducts.isEmpty() ){
            Id customerId = (Id)customerRec.get('Id');
            List<Truck_Inquiries__c> listTruckInquiries = new List<Truck_Inquiries__c>();
            Truck_Inquiries__c truckInquiry;
            Id userId = UserInfo.getUserId();
            Schema.SObjectType token = getSObjectTypeFromId(customerId);
            
            for(Product2 currentProduct : listProducts){
                truckInquiry = new Truck_Inquiries__c();
                
                if( token == Schema.Contact.SObjectType ){
                    truckInquiry.Contact__c = customerId;
                }
                else if( token == Schema.Lead.SObjectType ){
                    truckInquiry.Lead__c = customerId;
                }
                truckInquiry.Product__c = currentProduct.Id;
                truckInquiry.Seller_Contact__c = currentProduct.Seller_Contact__c;
                truckInquiry.Intro_Email_Sender__c = userId;
                truckInquiry.Name = currentProduct.Name;
                truckInquiry.Inquiry_Type__c = 'Phone';
                
                listTruckInquiries.add(truckInquiry);
            }
            //String strMsg = insertTruckInquiries(listTruckInquiries);
            return insertTruckInquiries(listTruckInquiries);
            
            //strMsg += createInquiryTasksForOwner( (String)customerRec.get('OwnerId'), listTruckInquiries );
            //return strMsg;
        }
        return null;
    }
    
    /*
        Create Tasks related to truck inquiry for the owner of Contact /Lead record
        @param Owner Id for the tasks
        @param Truck inquiry records for creating tasks
        @outputParam - Error response if exists from creating tasks
    *//*
    private static String createInquiryTasksForOwner( Id OwnerId, List<Truck_Inquiries__c> listTruckInquiries ){
        if( String.isNotBlank(OwnerId) && listTruckInquiries != null && !listTruckInquiries.isEMpty() ){
            
            List<Task> listTasks = new List<Task>();
            for( Truck_Inquiries__c truckInquiry : listTruckInquiries ){
                Task task = new Task();
                task.OwnerId = OwnerId;
                task.Priority = 'Low';
                task.status = 'Not Started';
                task.Type = 'Sales - New Inquiry';
                task.ActivityDate = System.today();
                task.Subject = 'Truck Inquiry';
                task.Truck_Inquiry__c = truckInquiry.Id;
                task.Response_Type__c = 'Truck Inquiry';
                task.WhoId = String.isNotBlank(truckInquiry.Contact__c) ? truckInquiry.Contact__c : truckInquiry.Lead__c;
                listTasks.add(task);
            }
            
            try{
                insert listTasks;
            }
            catch(Exception e){
                System.debug('Exception in creating inquiry tasks for owners :' +e);
                return '<li>Could not create truck Inquiry tasks for owner!<br/>'+e.getMessage()+'</li>';
            }
        }
        return '';
    }*/
    
    /*
    @description - Insert Truck Inquiry Records
    @inputParam  - List of Truck Inquiries
    @outputParam - Error response if exists from inserting truck inquiries
    */
    private static String insertTruckInquiries(List<Truck_Inquiries__c> listTruckInquiries){
        if( listTruckInquiries != null && !listTruckInquiries.isEmpty() ){
            try{
                insert listTruckInquiries;
            }
            catch(Exception e){
                System.debug('Exception in inserting Truck Inquiries ::: '+ e);
                return '<li>Could not insert Truck Inquiry records. '+ e +'</li>';
            }
        }
        return '';
    }
    
    /*
    @description - Send emails
    @inputParam  - Customer (Lead/Contact) Id 
    @outputParam - Email Template Id
    */
    private static Id getEmailTemplateIdForSObjectType(Id customerId){
        if(String.isNotBlank(customerId)){
            Schema.SObjectType token = getSObjectTypeFromId(customerId);
            String strTemplateName;
            
            if( token == Schema.Contact.SOBjectType ){
                strTemplateName = 'Truck_Intro_Email_Contact';
            }
            else if( token == Schema.Lead.SOBjectType ){
                strTemplateName = 'Truck_Intro_Email_Lead';
            }
            return fetchEmailTemplateIdFromDevName(strTemplateName);
        }
        return null;
    }
    
    /*
    @description - get Type token of Sobject with given Id
    @inputParam  - Customer (Lead/Contact) Id 
    @outputParam - Schema.SObjectType
    */
    private static Schema.SObjectType getSObjectTypeFromId(Id customerId){
        if(String.isNotBlank(customerId)){
            return customerId.getSObjectType();
        }
        return null;
    }
    
    /*
    @description - Get template Id with given developer name
    @inputParam  - Developer name for template id
    @outputParam - Template Id
    */
    private static Id fetchEmailTemplateIdFromDevName(String strTemplateDevName){
        if(String.isNotBlank(strTemplateDevName)){
            try{
                return [SELECT Id FROM EmailTemplate WHERE DeveloperName=:strTemplateDevName].Id;
            }
            catch(Exception e){
                System.debug('Exception in fetching Email Template Id ::: '+ e);
            }
        }
        return null;
    }
    
        /*
    @description - Process the criteria, create query and fetch Product records
    @inputParam  - 1. keyword to search
                   2. Json for List of CriteriaWrapper records
    @outputParam - List of products
    */
    @remoteAction
    public static String processCriteriaAndFetchProducts( String strKeyword, String strJsonObjects){
        
        List<CriteriaWrapper> listCriteriaWrapper;
        try{
            listCriteriaWrapper = ( List<CriteriaWrapper> )System.JSON.deserialize(strJsonObjects, List<CriteriaWrapper>.class);
        }
        catch(Exception e){
            System.debug('Exception in deserializing wrapper records ::: '+ e);
            return 'Error : <ul><li>Exception in parsing the filter values </li></ul>'+e.getMessage();
        }
        //System.debug(JSON.serialize(listCriteriaWrapper));
        
        if( listCriteriaWrapper != null && !listCriteriaWrapper.isEmpty() ){
            String strKeywordCriteria = createCriteriaForKeyword(strKeyword);
            String strCriteria = createQueryStringFromWrapperRecords(listCriteriaWrapper);
            
            String strQuery = createProductsQuery( strCriteria, strKeywordCriteria);
            return fetchProducts(strQuery);
        }
        return null;
    }
    
    /*
    @description - fetch Product records
    @inputParam  - String to be used for query
    @outputParam - Jsonserialized list of Products
    */
    private static String fetchProducts( String strQuery ){
        if(String.isNotBlank(strQuery)){
            try{
                return JSON.serialize(Database.Query(strQuery));            // return result in json format
            }
            catch( Exception e ){
                System.debug('Exception in fetching Products ::: '+ e);
                return '<b>Error</b> :<br/> Could not fetch Product records<br/>' + e.getMessage();
            }
        }
        return null;
    }
    
    /*
    @description - Create query used to fetch product records
    @inputParam  - String containing query criteria by users choice
    @outputParam - query for fetching products
    */
    private static String createProductsQuery( String strCriteria, String strKeywordCriteria ){
        strCriteria = String.isBlank(strCriteria) ? '' : ' AND '+ strCriteria;
        strKeywordCriteria = String.isBlank(strKeywordCriteria) ? '' : ' AND ('+ strKeywordCriteria + ')';
        
        String strQuery = String.join(new List<String>{
                                        'SELECT Id, Stock_Number__c, Name, typeOfSale__c, status__c, apparatusType__c, FT_Main_Title__c,',
                                        'FT_Pump_GPM__c, FT_Water_Tank_Size_only__c, VF_Website_Price__c, Retail_Price__c, Earlybird_Price__c',
                                        'FROM Product2',
                                        'WHERE RecordType.Name=\'Trucks\'',
                                         strCriteria, strKeywordCriteria,
                                        'LIMIT 50000'
                                      }, ' ');
        //System.debug('strQuery:'+strQuery);
        return strQuery;
    }
    
    /*
    @description - Create query criteria for keyword. Get the fields to be searched on for keyword value and the 
                   criteria to query.
    @inputParam  - String keyword
    @outputParam - string with query criteria conditions
    */
    private static String createCriteriaForKeyword(String strKeyword){
        if(String.isNotBlank(strKeyword)){
            List<Keyword_Criteria_Field__c> listCriteriaFields = getListKeywordCriteriaFields();
            
            if(listCriteriaFields != null && !listCriteriaFields.isEmpty()){
                String strKeywordCriterion = '', strFieldAPIName, strFieldType;
                String strMultiPicklistTypes = 'MULTIPICKLIST',
                       strStringTypes = 'STRING URL ID PICKLIST',
                       strBooleanType = 'BOOLEAN',
                       strOtherTypes = 'CURRENCY DOUBLE';
                Double doubleValue;
                
                Map <String, Schema.SObjectField> fieldMap = getMapProductFields();
                Schema.SObjectField SObjectField;
                
                for(Keyword_Criteria_Field__c currentCriteriaField : listCriteriaFields ){
                    strFieldAPIName = currentCriteriaField.Field_API_Name__c;
                    SObjectField = fieldMap.get( strFieldAPIName );
                    
                    if(SObjectField != null){
                        strFieldType = String.valueOf(SObjectField.getDescribe().getType());
                        
                        if( strStringTypes.contains(strFieldType) ){                                            // string datatype
                            strKeywordCriterion +=  strFieldAPIName +' = \''+ strKeyword +'\' OR ';
                        }
                        else if( strMultiPicklistTypes.contains(strFieldType)){                                 // multipicklist datatype
                            strKeywordCriterion += strFieldAPIName +' includes (\''+ strKeyword +'\') OR ';
                        }
                        else if( strBooleanType.contains(strFieldType)
                                    && ( strKeyword.equalsIgnoreCase('true')
                                        || strKeyword.equalsIgnoreCase('false') )){                             // boolean datatype
                                strKeywordCriterion += strFieldAPIName +' = '+ strKeyword +' OR ';
                        }
                        else if( strOtherTypes.contains(strFieldType)){                                         // Other datataypes
                            try{
                                doubleValue = Double.ValueOf(strKeyword);
                                strKeywordCriterion += strFieldAPIName +' = '+ strKeyword +' OR ';
                            }
                            catch(Exception e){
                                System.debug('Incompatible value for a double type ::: '+ e);
                            }
                        }
                    }
                }
                return strKeywordCriterion.removeEnd(' OR ');
            }
        }
        return null;
    }
    
    /*
    @description - get List of field names for the keyword will be searched on
    @outputParam - List of Keyword_Criteria_Field__c ( custom settings )
    */
    private static List<Keyword_Criteria_Field__c> getListKeywordCriteriaFields(){
        return Keyword_Criteria_Field__c.getAll().values();
    }
    
    /*
    @description - Create criteria query string obtained from user's selection
    @inputParam  - List of CriteriaWrapper records
    @outputParam - String containing query criteria by users choice
    */
    private static String createQueryStringFromWrapperRecords( List<CriteriaWrapper> listCriteriaWrapper ){
        if( listCriteriaWrapper != null && !listCriteriaWrapper.isEmpty() ){
            String strQueryCriteria = '';
            
            for( CriteriaWrapper wrapperObj : listCriteriaWrapper ){
            
                if( String.isNotBlank(wrapperObj.strFieldAPIName) && String.isNotBlank(wrapperObj.strOperator)){
                    strQueryCriteria += String.format('{0} {1} {2} AND ', new List<String>{ wrapperObj.strFieldAPIName, wrapperObj.strOperator, wrapperObj.strValue } );
                }
            }
            strQueryCriteria = strQueryCriteria.removeEnd(' AND ');
            //System.debug('strQueryCriteria:'+strQueryCriteria);
            return strQueryCriteria;
        }
        return null;
    }
    
    @remoteAction
    public static List<String> getPicklistValsFromFieldAPIName(String strFieldAPIName){
        if(String.isNotBlank(strFieldAPIName)){
            Map< String, Schema.SObjectField > mapSObjectFields = Product2.getSObjectType().getDescribe().fields.getMap(); //get map of fields for the sObject
            List< Schema.PicklistEntry > listFieldOptions = mapSObjectFields.get(strFieldAPIName).getDescribe().getPickListValues();
            
            List<String> listPicklistOptions = new List<String>();
            for( Schema.PicklistEntry ple : listFieldOptions ){
                listPicklistOptions.add(ple.getValue());
            }
            //System.debug('JSON:'+JSON.serialize(listPicklistOptions));
            return listPicklistOptions;
        }
        return null;
    }
        
    /*
    @description - Wraper class to bind Field label, API name and Datatype for creating picklists on client side
    */
    public class FieldWrapper{
        public String strFieldlabel{get; set;}
        public String strFieldAPIName{get; set;}
        public String strFieldDataType{get; set;}
        
        public FieldWrapper( String strFieldlabel, String strFieldAPIName, String strFieldDataType ){
            this.strFieldlabel = strFieldlabel;
            this.strFieldAPIName = strFieldAPIName;
            this.strFieldDataType = strFieldDataType;
        }
    }
    
    /*
    @description - Wraper class to bind Field API name, Operator and value selected for filterign product records
    */
    public class CriteriaWrapper{
        public String strFieldAPIName{get; set;}
        public String strOperator{get; set;}
        public String strValue{get; set;}
    }
}