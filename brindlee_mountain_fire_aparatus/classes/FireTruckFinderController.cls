/*
 @description - Controller for Fire Truck Finder vf page. Used to create and update FTF records and link them up to Contact, Account, Opportunity
 @createdDate - 29/03/2016
 @createdBy   - Dreamwares
 @lastModifiedDate - 05/04/2016
 */
public class FireTruckFinderController{
    
    public String strFTFCriteriaRec{get; set;}

    public FireTruckFinderController(){            // Constructor
        Fire_Truck_Finder_Criteria__c ftfCriteria = getFTFCriteriaFromUrlParams();        // fetch FTF Criteria record
        if(ftfCriteria != null){
            strFTFCriteriaRec = JSON.Serialize(ftfCriteria);
        }
    }
    
    /*
    @description - get FTF Criteria recordfor assoc. parameters in url
    */
    private Fire_Truck_Finder_Criteria__c getFTFCriteriaFromUrlParams(){
        Map<String, String> mapPageParams = ApexPages.CurrentPage().getParameters();
        
        String strFTFSecret = mapPageParams.get('ftf_Id');
        Decimal decFTFSecret;
        try{
            decFTFSecret = (String.isNotBlank(strFTFSecret)) ? Decimal.valueOf(strFTFSecret.remove(',')) : null;
        }
        catch(Exception e){
            System.debug('Exception while fetching ftf_Id from url :' + e);
        }
        
        return fetchFTFCriteria(mapPageParams.get('Id'), decFTFSecret);
    }
    
    /*
    @description - fetch FTF Criteria record from database
    */
    private Fire_Truck_Finder_Criteria__c fetchFTFCriteria( Id idFTF, Decimal decFTFSecret ){
        if( String.isNotBlank(idFTF) && decFTFSecret != null ){
            try{
                return [SELECT Id, Add_to_Fire_Truck_Finder__c, FTF_Aerial_Length_Min__c, FTF_Aerial_Length_Max__c, FTF_Brands__c, FTF_Keyword__c,
                               FTF_Apparatus_Type__c, FTF_Budget_Max__c, FTF_Budget_Min__c, FTF_Chassis__c, FTF_Geographic_Region__c,
                               FTF_Tank_Size__c, FTF_Mileage__c, FTF_Year_Min__c, FTF_Year_Max__c, FTF_Trucks_With_Warranty__c, FTF_Four_By_Four__c,
                               Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Phone, Contact__r.Email, FTF_Pump_Size__c,
                               Contact__r.AccountId, Contact__r.Account.Name, Contact__r.Account.Website, Contact__r.Account.BillingState, 
                               Opportunity__c, Opportunity__r.StageName
                        FROM Fire_Truck_Finder_Criteria__c
                        WHERE Id=:idFTF AND FTF_Id__c=:decFTFSecret
                              LIMIT 1];
            }
            catch(Exception e){
                System.debug('Exception in fetching FTF Record ::: '+ e);
            }
        }
        return null;
    }
    
    /*
    @description - get serialized picklist values for fields related to given SObject
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
    
    public String getChassisTypes(){    // get serialized picklist options for chassis types
        return getSerializedPicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Chassis__c');
    }
    
    public String getBrands(){    // get serialized picklist options for brands
        return getSerializedPicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Brands__c');
    }
    
    public String getMileageOptions(){    // get serialized picklist options for Mileage
        return getSerializedPicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Mileage__c');
    }
    
    public String getGeographicRegns(){    // get serialized picklist options for Geographic regions
        return getSerializedPicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Geographic_Region__c');
    }
    
    public String getAerialLengthMin(){    // get serialized picklist options for Aerial Length Min
        return getSerializedPicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Aerial_Length_Min__c');
    }
    
    public String getAerialLengthMax(){    // get serialized picklist options for Aerial Length Max
        return getSerializedPicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Aerial_Length_Max__c');
    }
    
    public String getWarrantyOptions(){    // get serialized picklist options for Warranty
        return getSerializedPicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Trucks_With_Warranty__c');
    }
    
    public Map<String, String> getMapApparatusTypes(){    // create picklist values for brands
        List<String> listEntries = Utilities.generatePicklistValues(new Fire_Truck_Finder_Criteria__c(), 'FTF_Apparatus_Type__c');
        
        Map<String, String> mapOptions = new Map<String, String>();    // map of unspaced 
        for(String currentEntry : listEntries){
            mapOptions.put(currentEntry.replaceAll(' ',''), currentEntry);
        }
        return mapOptions;
    }
        
    /*
    @description - Submit request for updation of FTF Criteria record
    @inputParam  - 1. FTF Criteria record
                   2. Account 
                   3. Contact
    @outputParam - Boolean - result denoting success
    @calledFrom - VF page (for update if ftf criteria record)
    */
    @remoteAction
    public static Boolean updateFTFCriteriaRequest(Fire_Truck_Finder_Criteria__c FTFCriteria, Account account, Contact contact){
        System.debug('1FTF:'+Json.serialize(FTFCriteria));
        upsertAccountAndContact(account, contact);
        Id UserId = getUserIdForRecordOwnership();
        contact = fetchContactByCriteria('Id', contact.Id);
        if(contact != null){
            Id idOpp;

            Opportunity opp = createOpportunity(contact, FTFCriteria);        // create Opportunity with given fields for update

            if(String.isNotBlank(FTFCriteria.Opportunity__c) ){
                
                // if ftf record has Opportunity__C is closed won or closed lost then create new opportunity.

                if( (FTFCriteria.Opportunity__r !=null &&
                    FTFCriteria.Opportunity__r.StageName !=null) && 
                    
                    (FTFCriteria.Opportunity__r.StageName != 'Closed Won' 
                    && FTFCriteria.Opportunity__r.StageName != 'Closed Lost')){

                    System.debug('FTFCriteria.Opportunity__r.StageName:::'+FTFCriteria.Opportunity__r.StageName);
                    opp.Id = FTFCriteria.Opportunity__c;
                }
            }
            idOpp = upsertOpp(opp);                // update Opportunity
            // we are passing Opportunity__r.stageName to null . if we dnt then got upsert fails.
            FTFCriteria.Opportunity__r = null;

            Id idFTFCriteria = modifyAndUpsertFTFCriteria(contact.Id, FTFCriteria, idOpp, UserId);
            return String.isNotBlank(idFTFCriteria);
        }
        return null;
    }
    
    
    /*
    @description - Submit request for creation of FTF Criteria record
    @inputParam  - 1. FTF Criteria record
                   2. Account 
                   3. Contact
    @outputParam - Boolean - result denoting success
    @calledFrom - VF page
    */
    @remoteAction
    public static Boolean submitFTFCriteriaRequest(Fire_Truck_Finder_Criteria__c FTFCriteria, Account account, Contact contact){
        Boolean hasActiveOpp = false;                // denotes whether the Contact has active Opp (to send email to Sales rep)

        // we are passing Opportunity__r.stageName to null .
        FTFCriteria.Opportunity__r = null;

        Id UserId = getUserIdForRecordOwnership();
        System.debug('UserId'+UserId);
        System.debug('contact'+contact);
        System.debug('contact'+contact.Email);
        Contact existingContact = fetchContactByCriteria('Email', contact.Email);
        System.debug('existingContact'+existingContact);
        Id idContact, idOpp;
        if(existingContact != null){                                // duplicate Contact found
            if(existingContact.Opportunities__r.isEmpty()){         // no active Opportunities
                idOpp = createAndUpsertOpp(existingContact, FTFCriteria);
            }
            else{
                hasActiveOpp = true;
            }
            idContact = existingContact.Id;
        }
        else{
            
            Id idAccount = modifyAndUpsertAccount(account, UserId);        // create new Contact and Account
            System.debug('idAccount'+idAccount);
            if(String.isNotBlank(idAccount)){
                idContact = modifyAndUpsertContact(idAccount, contact, UserId);
                System.debug('idContact'+idContact);
                contact = fetchContactByCriteria('Id', idContact);    // fetch extra fields from Contact
                System.debug('contact'+contact);
                idOpp = createAndUpsertOpp(contact, FTFCriteria);
            }
        }
                
        if(String.isNotBlank(idContact)){
            System.debug('idContact'+idContact);
            System.debug('FTFCriteria'+FTFCriteria);
            System.debug('idOpp'+idOpp);
            System.debug('hasActiveOpp'+hasActiveOpp);
            System.debug('UserId'+UserId);
            return processFTFCreation(idContact, FTFCriteria, idOpp, hasActiveOpp, UserId);
        }
        return false;
    }
    
    /*
    @description - Create FTF Criteria record. 
    @inputParam  - 1. Contact Id
                   2. FTF Criteria record
                   3. Opportunity Id    
                   4. Boolean - denotes whether the Contact has active Opp rec or not. If yes then send email to Sales Rep notifying new FTF request
    @outputParam - Boolean - result denoting success
    */
    private static Boolean processFTFCreation( Id idContact, Fire_Truck_Finder_Criteria__c FTFCriteria, Id idOpp, Boolean hasActiveOpp, Id OwnerId ){
        System.debug('process');
        System.debug('idContact'+idContact);
        System.debug('FTFCriteria'+FTFCriteria);
        System.debug('idOpp'+idOpp);
        System.debug('hasActiveOpp'+hasActiveOpp);
        System.debug('OwnerId'+OwnerId);
        
        if(String.isNotBlank(idContact)){
            Id idFTFCriteria = modifyAndUpsertFTFCriteria(idContact, FTFCriteria, idOpp, OwnerId);
            
            if(String.isNotBlank(idFTFCriteria)){
                if(hasActiveOpp){            // send email to SalesRep if active Opp exists
                    sendEmailToSalesDept(idFTFCriteria);                        
                }
                return sendFTFLinkEmailToCustomer(idContact, idFTFCriteria);    // Send email for a new customer
            }
        }
        return false;
    }
        
    /*
    @description - Send Email containing edit link for the  to customer 
    @inputParam  - 1. Customer Id     2. FTF Criteria Id
    */
    private static Boolean sendFTFLinkEmailToCustomer(Id idContact, Id idFTFCriteria){
        System.debug('sendFTFLinkEmailToCustomer');
        System.debug('idContact:'+idContact+'targ:'+idFTFCriteria);
        if(String.isNotBlank(idContact) && String.isNotBlank(idFTFCriteria)){
            Id idTemplate = Utilities.getEmailTemplateId('FTF_Criteria_Email_Notification_Custom');            
            OrgWideEmailAddress orgWideEmail = Utilities.getOrgWideEmailAddress(Label.FTF_Notification_OrgWideEmailAddress);
            System.debug('OrgWideEmailAddress'+orgWideEmail);
            if( String.isNotBlank(idTemplate) && orgWideEmail != null ){                
                return Utilities.sendEmailViaTemplate(idTemplate, idContact, idFTFCriteria, false, orgWideEmail.Id);                            
            }   
        }
        return false;
    }
    
    /*
    @description - Upsert account and Contact record
    @inputParam  - 1. Account 2. Contact
    @outputParam - Boolean result for success
    */
    private static Boolean upsertAccountAndContact(Account account, Contact contact){
        if(account != null && contact != null){
            Id idAccount = upsertAccount(account),
               idContact = upsertContact(contact);
               
            return String.isNotBlank(idAccount) && String.isNotBlank(idContact);
        }
        return false;
    }
    
    /*
    @description - Insert FTF Criteria record
    @inputParam  - 1. Customer Id     2. FTF Criteria record
                   3. Opportunity Id
    @outputParam - FTF Criteria Id
    @calledFrom  - submitFTFCriteriaRequest method
    */
    private static Id modifyAndUpsertFTFCriteria(Id idContact, Fire_Truck_Finder_Criteria__c FTFCriteria, Id idOpp, Id OwnerId){
        if(String.isNotBlank(idContact) && FTFCriteria != null){
            FTFCriteria.Contact__c = idContact;
            
            if(String.isBlank(FTFCriteria.Id)){
                FTFCriteria.OwnerId = OwnerId; 
            }
            if(String.isNotBlank(idOpp)){
                FTFCriteria.Opportunity__c = idOpp;
            }
            return upsertFTFCriteria(FTFCriteria);
        }
        return null;
    }
    
    /*
    @description - Upsert FTF Criteria record
    @inputParam  - 1. FTF Criteria
    @outputParam - Boolen result for success
    */
    private static Id upsertFTFCriteria(Fire_Truck_Finder_Criteria__c FTFCriteria){
        if(FTFCriteria != null){
            try{
                upsert FTFCriteria;
                return FTFCriteria.Id;
            }
            catch(Exception e){
                System.debug('Exception in upserting FTF Criteria record ::: '+ e);
                insert new FTF_Submission_Error__c( Related_To__c = 'FireTruckFinderCriteria', 
                                                    Error_Message__c = Utilities.displayExceptionMessage(e) 
                                                  );
                sendErrorEmailToSalesDept(e.getMessage());
            }
        }
        return null;
    }
    
    /*
    @description - Fetch Contact with given criteria in field name and field value
    @inputParam  - 1. Field Name     2. Field value 
    @outputParam - Contact
    */
    private static Contact fetchContactByCriteria(String strFieldName, String strFieldValue){
        if( String.isNotBlank(strFieldName) && String.isNotBlank(strFieldValue) ){
            String strQuery = 'SELECT Id, Name, AccountId, OwnerId,'
                              +'(SELECT Id FROM Opportunities__r WHERE StageName NOT IN (\'Closed Won\',\'Closed Lost\'))'
                              +'FROM Contact';
            strQuery = String.format( '{0} WHERE {1}=\'\'{2}\'\' LIMIT 1', new List<String>{ strQuery, strFieldName, strFieldValue });
            try{
                return Database.query(strQuery);
            }
            catch(Exception e){
                System.debug('Exception in fetching Contact ::: '+ e);
            }
        }
        return null;
    }
    
    /*
    @description - Create and upsert Opportunity record
    @inputParam  - 1. Contact     2. FTF Criteria
    @outputParam - Opportunity Id
    */
    private static Id createAndUpsertOpp(Contact contact, Fire_Truck_Finder_Criteria__c FTFCriteria){
        Opportunity opp = createOpportunity(contact, FTFCriteria);
        System.debug('opp'+opp);
        return upsertOpp(opp);
    }
    
    /*
    @description - Create Opportunity record from fields taken from Contact and FTF criteria
    @inputParam  - 1. Contact     2. FTF Criteria
    @outputParam - Opportunity
    */
    private static Opportunity createOpportunity(Contact contact, Fire_Truck_Finder_Criteria__c FTFCriteria){
        if( contact != null && FTFCriteria != null ){
            Opportunity opp = new Opportunity();
            opp.Name = contact.Name;
            opp.OwnerId = contact.OwnerId;
            opp.AccountId = contact.AccountId;
            opp.Contact_at_Department__c = contact.Id;
            
            opp.Trucks_With_Warranty__c = FTFCriteria.FTF_Trucks_With_Warranty__c;
            opp.Year_Min__c = FTFCriteria.FTF_Year_Min__c;
            opp.Year_Max__c = FTFCriteria.FTF_Year_Max__c;
            opp.Budget_Min__c = FTFCriteria.FTF_Budget_Min__c;
            opp.Budget_Max__c = FTFCriteria.FTF_Budget_Max__c;            
            opp.Pump__c = FTFCriteria.FTF_Pump_Size__c;
            opp.Brand__c = FTFCriteria.FTF_Brands__c.replace(',',';');
            opp.Chassis__c = FTFCriteria.FTF_Chassis__c;
            opp.Tank_Size__c = FTFCriteria.FTF_Tank_Size__c;
            opp.Type_of_Apparatus__c = FTFCriteria.FTF_Apparatus_Type__c;
            opp.FTF_Mileage__c = FTFCriteria.FTF_Mileage__c;
            opp.Geographic_Region__c = FTFCriteria.FTF_Geographic_Region__c;
            opp.Four_By_Four__c = FTFCriteria.FTF_Four_By_Four__c;
            
            opp.StageName = 'Fire Truck Finder';
            opp.CloseDate = System.today().addYears(1);
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
            return opp;
        }
        return null;
    }
    
    /*
    @description - Modify Opportunity fields from Contact and FTF Criteria rec adn upsert the record
    @inputParam  - 1. Contact     2. FTF Criteria
    @outputParam - Opportunity Id
    */
    private static Id upsertOpp(Opportunity opp){
        if(opp != null){
            try{
                upsert opp;
                return opp.Id;
            }
            catch(Exception e){
                System.debug('Exception in creating Opportunity ::: '+ e);
                insert new FTF_Submission_Error__c( Related_To__c = 'Opportunity', 
                                                    Error_Message__c = Utilities.displayExceptionMessage(e) 
                                                  );
                sendErrorEmailToSalesDept(e.getMessage());
            }
        }
        return null;
    }
    
    /*
    @description - Modify fields and insert new Account
    @inputParam  - Account
    @outputParam - Account Id
    */
    private static Id modifyAndUpsertAccount(Account account, Id OwnerId){
        System.debug('account'+account);
        System.debug('OwnerId'+OwnerId);
        if(account != null){
            //account.Company_Type__c = 'Fire Department';
            
            if(String.isBlank(account.Id)){
                account.OwnerId = OwnerId;
            }
            account.Company_Type__c = 'Fire Department';
            return upsertAccount(account);
        }
        return null;
    }
    
    /*
    @description - Upsert Account record 
    @inputParam  - Account 
    @outputParam - Account Id
    */
    private static Id upsertAccount(Account account){
        if(account != null){
            try{                
                upsert account;
                return account.Id;
            }
            catch(Exception e){
                System.debug('Exception in upserting Account ::: '+ e);
                insert new FTF_Submission_Error__c( Related_To__c = 'Account', 
                                                    Error_Message__c = Utilities.displayExceptionMessage(e) 
                                                  );
                sendErrorEmailToSalesDept(e.getMessage());
            }
        }
        return null;
    }
    
    /*
    @description - Upsert Contact with given Account Id
    @inputParam  - 1. Account Id     2. Contact
    @outputParam - Contact Id
    */
    private static Id modifyAndUpsertContact(Id idAccount, Contact contact, Id OwnerId){
        System.debug('modifyAndUpsertContact');
        System.debug('idAccount'+idAccount);
        System.debug('contact'+contact);
        System.debug('OwnerId'+OwnerId);
        
        if(String.isNotBlank(idAccount) && contact != null){
            contact.AccountId = idAccount;
            
            if(String.isBlank(contact.Id)){
                contact.OwnerId = OwnerId;
            }
            return upsertContact(contact);
        }
        return null;
    }
    
    /*
    @description - Upsert Contact record 
    @inputParam  - Contact 
    @outputParam - Contact Id
    */
    private static Id upsertContact(Contact contact){
        if(contact != null){
            try{
                upsert contact;
                return contact.Id;
            }
            catch(Exception e){
                System.debug('Exception in upserting Contact ::: '+ e);
                insert new FTF_Submission_Error__c( Related_To__c = 'Contact', 
                                                    Error_Message__c = Utilities.displayExceptionMessage(e) 
                                                  );
                sendErrorEmailToSalesDept(e.getMessage());
            }
        }
        return null;
    }
    
    /*
    @description - Send Notification to Salesrep regarding existing active Opportunities for the Contact record.
    @inputParam  - FTF Criteia Id
    @outputParam - Boolean result
    */
    private static Boolean sendEmailToSalesDept(Id idFTFCriteria){
        System.debug('sendEmailToSalesDept');
        System.debug('idFTFCriteria'+idFTFCriteria);
        if(String.isNotBlank(idFTFCriteria)){            
            String strBody = String.format('{0} Click <a href="{1}/{2}">here</a> to visit the FTF criteria record.',
                                                new List<String>{ Label.New_Opp_Notification,
                                                                  Label.SalesforceInstanceUrl,
                                                                  idFTFCriteria });
            String strSubject = 'Fire Truck Finder - New Opportunity Notification';
            return Utilities.sendEmailMessage(strSubject, strBody, Utilities.getSalesRepsEmail());
        }
        return false;
    }
    
    public static Id getUserIdForRecordOwnership(){
        System.debug('hi'+Label.User_Name_For_FTFCriteria_Owner);
        User user = Utilities.getUserFromUserName(Label.User_Name_For_FTFCriteria_Owner);
        return (user != null) ? user.Id : null;        
    }
    
    /*
    @description - Send Notification to Salesrep regarding Error Message
    @inputParam  - Error 
    @outputParam - Void
    */
    private static Boolean sendErrorEmailToSalesDept(String strMessage){
        if(String.isNotBlank(strMessage)){            
            String strBody = String.format('Fire Truck Finder Process failed. Please check following details:<br/><br/><br/><Strong>Error Message</Strong> : {0}', new List<String>{ strMessage});
            String strSubject = 'Fire Truck Finder -Process failed Notification';
            return Utilities.sendEmailMessage(strSubject, strBody, Utilities.getSalesRepsEmail());
        }
        return false;
    }
}