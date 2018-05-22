/*
 * @description - Utility class for VF controllers of BMFA website pages
 * @dateCreated - 24/8/2015
 * @createdBy   - Dreamwares
 * @lastModifiedBy - Dreawares 
 * @lastModifiedDate - 20/07/2016
 */
public class Utilities{
    
    public static List<SelectOption> getPriceOptions(){     // get price options for picklists
        List<SelectOption> listOptions = new List<SelectOption>();
        for( Integer count=0;count<=1200000;count=count+5000 ){
            listOptions.add(new SelectOption( String.valueOf(count), '$'+String.valueOf(count)));
        }
        return listOptions;
    }
    
    public static List<SelectOption> getPicklistYearOptions(){           // Get year options for picklists
        List<SelectOption> listOptions = new List<SelectOption>();
        Integer maxYear = System.Today().Year();
        listOptions.add(new SelectOption('1970','1970'));
        listOptions.add(new SelectOption('1980','1980'));
        
        for( Integer count=1990;count<=maxYear;count++ ){
            listOptions.add(new SelectOption( String.valueOf(count), String.valueOf(count)));
        }
        return listOptions;
    }
    
    public static List<SelectOption> getPicklistPumpSizeOptions(){    // create picklist for pump size ranges
        return new List<SelectOption>{
                    new SelectOption('All', 'All'),
                    new SelectOption('0-500', '0 - 500 GPM'),
                    new SelectOption('500-750', '500 - 750 GPM'),
                    new SelectOption('750-1250', '750 - 1250 GPM'),
                    new SelectOption('1250-1500', '1250 - 1500 GPM'),
                    new SelectOption('1500-2000', '1500 - 2000 GPM'),
                    new SelectOption('2000', '2000+ GPM')
                };
    }
    
    public static List<SelectOption> getPicklistTankSizeOptions(){     // create picklist for tank size ranges
        return new List<SelectOption>{
                    new SelectOption('All', 'All'),
                    new SelectOption('0-250', '0 - 250 Gallons'),
                    new SelectOption('250-400', '250 - 400 Gallons'),
                    new SelectOption('400-750', '400 - 750 Gallons'),
                    new SelectOption('750-1100', '750 - 1100 Gallons'),
                    new SelectOption('1100-1800', '1100 - 1800 Gallons'),
                    new SelectOption('1800-2500', '1800 - 2500 Gallons'),
                    new SelectOption('2500', '2500+ Gallons')
                };
    }
    
    public static List<SelectOption> getPicklistWarrantyOptions(){    // Create picklist for Warranty options
        return new List<SelectOption>{
                    new SelectOption('All','All'),
                    new SelectOption('True','Trucks with warranty'),
                    new SelectOption('False', 'Trucks without warranty')
                };
    }
    
    /*
    @description  - get the string value for truck detail page
    @inputParams  - Product record
    @outputParams - String for url with value <stocknumber>/<Product - main title>
    @caller       - 1. WebsiteUrlRewriter   2. AvailableTruckDetailView 
    */
    public static String getTruckDetailPageUrlParams( Product2 objProduct ){
        String strStockNumber, strMainTitle;
        
        strStockNumber = objProduct.Stock_Number__c;
        strStockNumber = String.isNotBlank( strStockNumber )
            ? strStockNumber : '';
        
        strMainTitle = objProduct.VF_Main_Title__c;
        strMainTitle = String.isNotBlank( strMainTitle )   // hyphenate the names
            ? strMainTitle.replace(' ','-') : '';
        return strStockNumber + '/' + strMainTitle;
    }  
    
    public static String getLooseEqpmntDetailPageUrlparams(Product2 product){
        if( product != null ){
            String strEqpmntNumber, strTitle;
            
            strEqpmntNumber = product.Equipment_Number__c;
            strEqpmntNumber = String.isNotBlank( strEqpmntNumber )
                              ? strEqpmntNumber : '';
            
            strTitle = product.Name;
            strTitle = String.isNotBlank( strTitle )   // hyphenate the names
                        ? strTitle.replace(' ','-') : '';
            return strEqpmntNumber + '/' + strTitle;
        }
        return '';
    }
    
    /*
    @description - Get option values for picklist fields
    @inputParam -   1. SObject        3. 1st picklist value(String)
    2. Field name 
    @outputParam - List of Select option values for picklist
    */
    public static List<SelectOption> generatePicklistFieldOptions(SObject SObjectName, String strFieldName, String strFirstVal){
        List<SelectOption> listPicklistValues = new List< SelectOption >(); // new list for holding all of the picklist options
        
        if ( String.isNotBlank( strFirstVal ) ) { // add the first value being provided
            listPicklistValues.add( new selectOption( strFirstVal, strFirstVal ));
        }
        List<Schema.PicklistEntry> listFieldOptions = getPicklistEntries( SObjectName, strFieldName );
        
        if( listFieldOptions != null && !listFieldOptions.isEmpty() ){
            
            for ( Schema.PicklistEntry currOption : listFieldOptions ) {
                listPicklistValues.add(new selectOption(currOption.getLabel(), currOption.getValue()));  
            }
        }
        return listPicklistValues; //return the List
    }
    /*
    @description - Describe the SObject to return picklist valies
    @inputParam  - 1. SObject name    2. Field name
    @outputParam - List of Schema.PicklistEntry
    */
    public static List<Schema.PicklistEntry> getPicklistEntries( SObject SObjectName, String strFieldName ){
        List<Schema.PicklistEntry> listFieldOptions;
        
        if(SObjectName != null && String.isNotBlank(strFieldName)){
            Schema.SObjectType SObjectType = SObjectName.getSObjectType(); 
            Schema.DescribeSObjectResult sobject_describe = SObjectType.getDescribe(); //describe the sobject
            
            Map<String, Schema.SObjectField> mapSObjectFields = sobject_describe.fields.getMap(); //get map of fields for the sObject
            listFieldOptions = mapSObjectFields.get( strFieldName ).getDescribe().getPickListValues();
        }
        return listFieldOptions;
    }
    
    /*
    @description - Get map of Category codes to Category value
    @outputParam - map of Category URL codes to category value
    */
    public static Map<String, String> getCategoryUrlcodesMap( SObject sobjectType, String strFieldName  ){
        if( sobjectType != null && String.isNotBlank(strFieldName) ){
            List< String > listCategoryValues = generatePicklistValues( sobjectType, strFieldName );    //get category picklist values
            Map<String, String> mapCategoryToUrlcode;                // map category url codes to category values
            
            if( listCategoryValues != null && !listCategoryValues.isEmpty() ){
                mapCategoryToUrlcode = new Map<String, String>();
                String strUrlcode;
                for( String strCategory : listCategoryValues){    // create map of url codes 
                    // replace 'Used' and ',' with a blank, also ' and ', ' & ' and <space> with a '-'
                    strUrlcode = getCanonicalCategoryValue( strCategory );
                    mapCategoryToUrlcode.put( strUrlcode, strCategory );
                }
            }
            return mapCategoryToUrlcode;
        }
        return null;
    }
    
    public static String getCanonicalCategoryValue( String category ){
        if( String.isNotBlank( category ) ){
            return category.replaceAll('(Used )|(,)','').replaceAll('( and )|( & )|( )','-');
        }
        return null;
    }
        
    /*
    @description - Get wrapper list of Category codes to Category value
    @outputParam - List of CategoryURLCodeWrapper
    */
    public static List<CategoryURLCodeWrapper> getCategoryUrlcodesWrapperList(SObject objectType, String fieldName ){
        List<String> listCategoryValues = generatePicklistValues(objectType,fieldName);    //get category picklist values
        List<CategoryURLCodeWrapper> listCategoryWrapper;
        
        if( listCategoryValues != null && !listCategoryValues.isEmpty() ){
            listCategoryWrapper = new List<CategoryURLCodeWrapper>();
            CategoryURLCodeWrapper objCategoryWrapper;
            String strUrlcode;
            for( String strCategory : listCategoryValues){    // create map of url codes 
                // replace 'Used' and ',' with a blank, also ' and ' and <space> with a '-'
                strUrlcode = getCanonicalCategoryValue(strCategory);
                objCategoryWrapper = new CategoryURLCodeWrapper( strUrlcode, strCategory );
                listCategoryWrapper.add( objCategoryWrapper );
            }
        }
        return listCategoryWrapper;
    }
        
    /*
    @description - generate List of picklist values for Category field
    @outputParam - List of Category picklist values
    */
    public static List<String> generatePicklistValues( SObject sobjectType, String strFieldName ){
        if(sobjectType != null && String.isNotBlank(strFieldName)){
            List<Schema.PicklistEntry> listFieldOptions = getPicklistEntries(sobjectType, strFieldName);    // get picklist values for Category field
            List<String> listPicklistValues;
            
            if( listFieldOptions != null && !listFieldOptions.isEmpty() ){
                listPicklistValues = new List< String >();
                
                for ( Schema.PicklistEntry currOption : listFieldOptions ) { //for all values in the picklist list
                    listPicklistValues.add( currOption.getValue() );  //add the value and label to our final list
                }
            }
            return listPicklistValues;
        }
        return null;
    }
    
    /*
    @description - Send email via Email Template
    @inputParam  - 1. Template Id   2. Target ObjectId      3. What Id  4. Boolean save as Activity
    @outputParam - Boolean Result
    @calledFrom  - 1. FireTruckFinderController
    */
    
    public static Boolean sendEmailViaTemplate(String idTemplate, Id idTargetObject, Id idWhatId, Boolean saveAsActivity, Id orgWideEmailAddressId){
        
        if(String.isNotBlank(idTemplate) && String.isNotBlank(idTargetObject) && String.isNotBlank(idWhatId)){
            System.debug('user'+UserInfo.getUserId());
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            System.debug('**idTargetObject'+idTargetObject);
            message.setTargetObjectId(idTargetObject);//0030n000005OSxX 
            System.debug('**idTemplate'+idTemplate);
            message.setTemplateId(idTemplate);//00X0n000000QJia
            System.debug('**idWhatId'+idWhatId);
            message.setWhatId(idWhatId);//a3Y0n0000000Bp7
            message.setSaveAsActivity(false);
            System.debug('**orgWideEmailAddressId'+orgWideEmailAddressId);
            message.setOrgWideEmailAddressId(orgWideEmailAddressId);
            System.debug('message'+message);
            List<Messaging.SingleEmailMessage> listMessages = new List<Messaging.SingleEmailMessage>{message};
            System.debug('listMessages'+listMessages);
            Messaging.SendEmailResult[] results;
            try{
                results = Messaging.sendEmail(listMessages);
            }
            catch(Exception e){
                System.debug('Exception occured while sending email'+e.getMessage());
                insert new FTF_Submission_Error__c( Related_To__c = 'FireTruckFinderCriteria', 
                                                    Error_Message__c = displayExceptionMessage(e) 
                                                  );
            }
            System.debug('results'+results);
            
            if( results != null && !results.isEmpty() ){
                if( results[0].isSuccess() ){
                    System.debug('Email Sent Successfully!!');
                }
                else{
                    System.debug('Email not Sent!!\n'+results[0].errors[0].message);
                }
                return results[0].isSuccess();
            }
        }       
        return null;
    }
    
    /*
    @description - Get Template Id for Email with the given developer name parameter
    @inputParam  - String Developer name
    @calledFrom  - 1. FireTruckFinderController
    */
    public static Id getEmailTemplateId(String strDevName){
        if(String.isNotBlank(strDevName)){
            try{
                return [ SELECT Id
                        FROM EmailTemplate
                        WHERE DeveloperName =: strDevName ].Id;
            }
            catch(Exception e){
                System.debug('Could not fetch email template ::: '+ e);
            }             
        }
        return null;
    }
    
    /*
    @description - Send Email message
    @inputParam  - 1. Subject   2. HTML Body    3. Email Ids
    @outputParam - Boolean denoting Success
    */
    public static Boolean sendEmailMessage( String strSubject, String strHTMLBody, String emailIds ){
        if( String.isNotBlank(strSubject) && String.isNotBlank(strHTMLBody) && String.isNotBlank(emailIds)){
            List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses( emailIds.split(','));                                  // split emailIds by ',' to get all email Ids
            email.setSubject(strSubject);
            email.setHtmlBody(strHTMLBody);
            listEmails.add(email);
            
            Messaging.SendEmailResult[] results;
            try{
                results = Messaging.sendEmail(listEmails);
            }
            catch(Exception e){
                System.debug('Exception in sending emails ::: '+ e);
            }
            if( results != null && !results.isEmpty() ){
                if( results[0].isSuccess() ){
                    System.debug('Email Sent Successfully!!');
                }
                else{
                    System.debug('Email not Sent!!\n'+results[0].errors[0].message);
                }
                return results[0].isSuccess();
            }
        }
        return null;
    }
    
    /*
    @description - Get Email Id of Sales rep from Company Contact Info Custom Settings
    @outputParam - Sales rep's Email
    */
    public static String getSalesRepsEmail(){
        try{
            return CompanyContactInformation__c.getAll().values()[0].Sales_Email__c;
        }
        catch(Exception e){
            System.debug('Exception in getting Sales Rep email from Custom Settings ::: '+ e);
        }
        return null;
    }
    
    /*
    @description - Get OrgWideEmailAddress record for given Email Id
    @inputParam  - 1. Email Id
    @outputParam - OrgWideEmailAddress
    */
    public static OrgWideEmailAddress getOrgWideEmailAddress(String strEmail){
        if(String.isNotBlank(strEmail)){
            try{
                return [ SELECT Id, DisplayName, IsAllowAllProfiles, Address
                         FROM OrgWideEmailAddress
                         WHERE Address =: strEmail
                         LIMIT 1];
            }
            catch(Exception e){
                System.debug('Exception in fetching User ::: '+ e);
            }
        }
        return null;
    }
    
    /*
    @description - Get User recor for given email Id
    @inputParam  - 1. Email Id 
    @outputParam - User
    */
    public static User getUserFromUserName(String strUserName){
        if(String.isNotBlank(strUserName)){
            try{
                return [SELECT Id FROM User WHERE UserName=:strUserName LIMIT 1];    
            }
            catch(Exception e){
                System.debug('Exception in fetching User ::: '+ e);
            }
        }
        return null;
    }
    
    /*
    @description - returns the Id for product record type - 'Trucks'
    */
    public static Id getTruckRecordTypeId(){
        return Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
    }
    
    /*
        Returns the Id for product record type
        @param Product Record type name
        @return Id of the record type
    */
    public static Id getProductRecordTypeId(String rtName){
        if( String.isNotBlank(rtName) ){
            try{
                return Schema.SObjectType.Product2.getRecordTypeInfosByName().get(rtName).getRecordTypeId();
            }
            catch(Exception e){
                System.debug('Could not fetch record type Id with name -'+rtName+'\n'+e);
            }
        }
        return null;
    }
    
     /*
        @ Purpose     : Fetches and displays an exception message.
        @ Parameter   : Exception.
        @ Return Type : String [ Details of the exception ].
    */
    public static String displayExceptionMessage( Exception e ) {
    
        String strErrorMessage = '\nError Message:-{0}\nError LineNumber:-{1}';
        List<String> listOfMessageTokens = new List<String>{ e.getMessage(), String.valueOf( e.getLineNumber() ) };
        
        strErrorMessage = String.format( strErrorMessage, listOfMessageTokens );
        System.debug( strErrorMessage );
        return strErrorMessage;
    } 
    
    /*
    @description - Wrapper class to get urlcodes for picklist values
    */
    public class CategoryURLCodeWrapper{
        public String urlCode{get;set;}
        public String picklistValue{get;set;}
        
        public CategoryURLCodeWrapper( String urlCode, String picklistValue ){
            this.urlCode = urlCode;
            this.picklistValue = picklistValue;
        }
    }
}