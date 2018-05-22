/*
 * @description - Fetch and filter Contact and Lead records having matching Product records.
 *                Send API requests to pardot API to send emails for matching Products to Prospects.
 * @createdBy   - Dreamwares 
 * @createdDate - 30-11-2015 
 * @lastModifiedDate - 20/4/2016
 */
global class FireTruckFinder_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful{
    
    private String strAPIKey;
    private String strErrors;
    private Pardot_API_Settings__c objPardotAPISetting;
    private List<Product2> listProducts;
    
    /*
     * @description - 1. Fetch existing fire truck finder records and create a map
     *                2. Fetch Fire Truck Finder Criteria records for batch execution 
     * 
     */
    global Database.QueryLocator start( Database.BatchableContext bc ){
        strErrors = '';
        listProducts = FireTruckFinder_Handler.fetchProducts();     // fetch Products with Add to truck Truck Finder
        
        return Database.getQueryLocator([ SELECT Id, Contact__c, Customer_Pardot_Id__c, Edit_Link__c, FTF_Aerial_Length_Max__c, FTF_Aerial_Length_Min__c,
                                                 FTF_Apparatus_Type__c, FTF_Budget_Max__c, FTF_Budget_Min__c, FTF_Chassis__c, FTF_Geographic_Region__c,
                                                 FTF_Id__c, FTF_Mileage__c, FTF_Tank_Size__c, FTF_Year_Max__c, FTF_Year_Min__c, FTF_Brands__c,
                                                 Contact__r.pi__url__c, FTF_Trucks_With_Warranty__c, FTF_Keyword__c, FTF_Four_By_Four__c, FTF_Pump_Size__c
                                          FROM Fire_Truck_Finder_Criteria__c
                                          WHERE Add_to_Fire_Truck_Finder__c = True ]);
    }
    
    /* 
     * @description - 1. Filter records for new matches of Product and Fire Truck Finder Criteria .
     *                2. Authorize pardot account to obtain API key
     *                3. Batch update Pardot prospect records.
     *                4. Trigger pardot template to send emails to Pardot prospects
     */ 
    global void execute( Database.BatchableContext bc, List<Fire_Truck_Finder_Criteria__c> listFTFCriteria ){
        List<Pardot_API_Settings__c> listPardotAPIsetting = Pardot_API_Settings__c.getAll().values();
        
        if( listPardotAPIsetting != null && !listPardotAPIsetting.isEmpty() ){	// get Pardot API key
            objPardotAPISetting = listPardotAPIsetting[0];
            strAPIKey = authorizePardot();
        }
        
        if( String.isNotBlank( strAPIKey )
                && listProducts != null && !listProducts.isEmpty() ){
           List<Fire_Truck_Finder__c> listTruckFinders = FireTruckFinder_Handler.fetchTruckFinders(listProducts);   // fetch existing truck finder records
           //System.debug(Json.serialize(listTruckFinders));         
           Map<Id, Set<Id>> mapProductIdToSetFTFCriteriaId =
                        FireTruckFinder_Handler.createMapProductIdToSetFTFCriteriaId(listTruckFinders);             // Create matches from existing Fire truck Finder records
           
           // Find new matches by comparsion
           Map<Id, Set<Product2>> mapFTFCriteriaIdToProducts = FireTruckFinder_Handler.findNewMatches(listFTFCriteria,
                                                                                                        listProducts,
                                                                                                        mapProductIdToSetFTFCriteriaId);
           
           FireTruckFinder_Handler.findProductsByKeywords( listFTFCriteria , mapFTFCriteriaIdToProducts, mapProductIdToSetFTFCriteriaId );	// Find matches for keyword by querying
           
           if( mapFTFCriteriaIdToProducts != null && !mapFTFCriteriaIdToProducts.isEmpty() ){
               Map<Id, Fire_Truck_Finder_Criteria__c> mapFTFCriteria = new Map<Id, Fire_Truck_Finder_Criteria__c>(listFTFCriteria); // create map of Id to FTFCriteria
               updatePardotProspectsHtmlField(mapFTFCriteria, mapFTFCriteriaIdToProducts);
               
               String method = 'POST', SfBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
               PardotIntegration.EmailSendAPIResponse emailResponse;
               List<Fire_Truck_Finder__c> listFireTruckFinders = new List<Fire_Truck_Finder__c>();
               List<Contact> listUnsubscribedContacts = new List<Contact>();
               
               Fire_Truck_Finder_Criteria__c currentFTFCriteria;
               for(Id FTFCriteriaId : mapFTFCriteriaIdToProducts.keySet()){
                   emailResponse = new PardotIntegration.EmailSendAPIResponse();
                   currentFTFCriteria = mapFTFCriteria.get(FTFCriteriaId);
                   
                   try{
                       if(Test.isRunningTest()){
                            String strEmailResponse = '{ "attributes": { "stat": "ok", "version": 1 }, "email": { "id": 112275565, "name": "Email - FTF Match Notification",'+
                                                        '"isOneToOne": true, "subject": "See Matching Fire Trucks", "message": { "text": "Hello,The Fire Truck'+
                                                        'Finder at Brindlee has found a" }, "created_at": "2015-12-07 07:18:37" }}';
                            emailResponse = new PardotIntegration.EmailSendAPIResponse();
                            emailResponse = emailResponse.parse( strEmailResponse );
                       }
                       else{
                           emailResponse = PardotIntegration.sendEmailRequest( currentFTFCriteria.Customer_Pardot_Id__c,
                                                                               objPardotAPISetting.Single_Email_Url__c,
                                                                               method,
                                                                               objPardotAPISetting.User_Key__c,
                                                                               strAPIKey,
                                                                               objPardotAPISetting.Truck_Match_Pardot_Campaign_Id__c,
                                                                               objPardotAPISetting.Email_Template_Id__c );
                       }
                       
                       if( emailResponse != null ){
                           if( PardotIntegration.isStatusOK( emailResponse.attributes ) ){
                               listFireTruckFinders.addAll(createTruckFinderRecords(currentFTFCriteria, mapFTFCriteriaIdToProducts));       // Create truck finder if email is sent
                           }
                           else{
                               if( PardotIntegration.isProspectIdInvalid( emailResponse.attributes ) ){
                                   listUnsubscribedContacts.add( currentFTFCriteria.Contact__r );
                               }
                               strErrors += String.format('<br/>Email Send failed for Prospect Id : {0},<br/>status:{1},err_code:{2}<br/>'+
                                                          'Error:{3}<br/>Pardot Url : {4}<br/>Salesforce Url:{5}/{6}<br/>',
                                                           new List<String>{ currentFTFCriteria.Customer_Pardot_Id__c,
                                                                             emailResponse.attributes.stat,
                                                                             String.valueOf( emailResponse.attributes.err_code ),
                                                                             emailResponse.err,
                                                                             currentFTFCriteria.Contact__r.pi__url__c,
                                                                             SfBaseUrl,
                                                                             currentFTFCriteria.Id });
                           }
                       }
                   }
                   catch( Exception e ){
                       System.debug('Exception in sending Email :::'+ e +'\n Record Id:'+ currentFTFCriteria.Id );
                       strErrors += ('<br/><b>Exception in sending email:</b><br/>'+e+'<br/>for FTF Criteria at : <br/>'+SfBaseUrl + '/' +currentFTFCriteria.Id);
                   }
               }
               insertFireTruckFinders( listFireTruckFinders );                      // Create Fire Truck Finder records
               modifyAndUpdateUnsubscribedProspects(listUnsubscribedContacts);      // update Pardot Email Subscription field   
           }/*
           else{
                System.debug('No New Matches found!');             
           }*/
       }
   }
    
    /*
     * @description - 1. Call batch for Lead if the Contact batch is over
     *                2. Send error email ( if errors exist ) at the end of both batches
     */ 
    global void finish(Database.BatchableContext bc){
        if( String.isNotBlank( strErrors ) && objPardotAPISetting != null
                && String.isNotBlank(objPardotAPISetting.Error_Report_Email_Ids__c) ){
            FireTruckFinder_Handler.sendErrorMails( strErrors, objPardotAPISetting.Error_Report_Email_Ids__c );
        }
        FireTruckFinder_Handler.updateProducts( listProducts );     // reset Add to Truck Finder field to false
    }
    
    /*
    @description - Set SObject field - Pardot Email Subscription to 'unsubscribed'
    @inputParam  - List of SOBjects 
    @calledFrom  - Execute method of batch
    */
    @testVisible
    private void modifyAndUpdateUnsubscribedProspects( List<Contact> listUnsubscribedContacts ){
        if( listUnsubscribedContacts != null && !listUnsubscribedContacts.isEmpty() ){
            
            for( Contact currentContact : listUnsubscribedContacts ){
                currentContact.Pardot_Email_Subscription__c = 'Unsubscribed';
            }
            updateContacts( listUnsubscribedContacts );
        }
    }
    
    /*
    @description - Update list of Contacts
    @inputParam  - List of Contacts
    @calledFrom  - modifyAndUpdateUnsubscribedProspects
    */
    private void updateContacts( List<Contact> listContacts ){
        if( listContacts != null && !listContacts.isEmpty() ){
            try{
                update listContacts;
            }
            catch( Exception e ){
                System.debug('Exception in updating Contacts ::: '+ e);
                strErrors += ('<br/><b>Exception in updating Contact List :</b><br/>'+e+'<br/>');
            }
        }
    }
    
    /*
    @description  - Create Json for Updating prospects
    @inputParams  - 1. Map of Fire Truck Finder Criteria 
                    2. Map FTF Criteria Id to Set of Products
    @calledFrom   - Execute method
     */     
    private void updatePardotProspectsHtmlField( Map<Id, Fire_Truck_Finder_Criteria__c> mapIdToFTFCriteria,
                                                     Map<Id, Set<Product2>> mapFTFCriteriaIdToProducts ){
        Map<Id, String> mapFTFCriteriaIdToTruckHtml = FireTruckFinder_Handler.createMatchingTrucksHtml( mapFTFCriteriaIdToProducts, mapIdToFTFCriteria );
        if( mapFTFCriteriaIdToProducts != null && !mapFTFCriteriaIdToProducts.isEmpty()
                && mapFTFCriteriaIdToTruckHtml != null && !mapFTFCriteriaIdToTruckHtml.isEmpty()
                && mapIdToFTFCriteria != null && !mapIdToFTFCriteria.isEmpty()){
            
            String prospectJson='', requestJson, jsonTemplate, prospectTemplate, pardotId;
            prospectTemplate = '"{0}":\'{\'"FTF_Matching_Truck_HTML":"{1}"\'}\',';
                
            Integer countFTFCriteria = 0;     
            Fire_Truck_Finder_Criteria__c FTFCriteria;
            List<String> listArguments;
            for( Id FTFCriteriaId : mapFTFCriteriaIdToProducts.keySet() ){
                
                if( mapIdToFTFCriteria.containsKey(FTFCriteriaId)){
                    FTFCriteria = mapIdToFTFCriteria.get(FTFCriteriaId);
                    pardotId = FTFCriteria.Customer_Pardot_Id__c;
                    
                    if( FTFCriteria != null
                            && mapFTFCriteriaIdToTruckHtml.containsKey(FTFCriteriaId)
                            && String.isNotBlank(pardotId)){
                                
                         listArguments = new List<String>{ pardotId, mapFTFCriteriaIdToTruckHtml.get(FTFCriteriaId) };
                         prospectJson += String.format(prospectTemplate, listArguments);
                         countFTFCriteria++;
                         pardotId = '';
                    }
                }
                if( countFTFCriteria == 48 ){
                    requestJson = createRequestJson( prospectJson.removeEnd(',') );
                    processBatchUpdateRequest( requestJson );
                    countFTFCriteria = 0;
                    prospectJson = '';
                }
            }
            if( countFTFCriteria < 48 ){
                requestJson = createRequestJson( prospectJson.removeEnd(',') );
                processBatchUpdateRequest(requestJson);    
            }
        }
    }
    
    /*
    @description - Create json string for request 
    @inputParam  - Json data of prospects
    @outputparam - complete Json data of prospects
    @calledFrom  - updatePardotProspectsHtmlField
     */
    private String createRequestJson( String prospectJson ){
        return String.isNotBlank(prospectJson) ? '{"prospects":{'+ prospectJson +'}}' : null;
    }
    
    /*
    @description  - URl encode and send API request of batch update
    @inputParams  - Json data
    @calledFrom  - updatePardotProspectsHtmlField
     */
    private void processBatchUpdateRequest( String jsonText ){
        if(String.isNotBlank( jsonText )){
            jsonText = EncodingUtil.urlEncode( jsonText, 'UTF-8');      // URL Encode data
            
            PardotIntegration.ProspectBatchUpdate batchRes;
            if(Test.isRunningTest()){
                batchRes = new PardotIntegration.ProspectBatchUpdate();
                batchRes.attributes = new PardotIntegration.attributes( 'ok', 1, null );
            }
            else{
                batchRes = PardotIntegration.batchUpdatePardotProspects( objPardotAPISetting.Batch_Update_Url__c,
                                                                          jsonText, 'POST',
                                                                          objPardotAPISetting.User_Key__c, strAPIKey );
            }
            if( batchRes != null ){
                if( PardotIntegration.isStatusOK( batchRes.attributes ) ){
                    System.debug('Batch Update Successful!!');
                }
                else if( String.isNotBlank( batchRes.err )){
                    strErrors += String.format('<br/><b>Batch Update Errors:</b><br/>{0}<br/>',
                                               new List<String>{ batchRes.err });
                }
            }
        }
    }
    
    /*
    @description - Create Fire Truck Finder records
    @inputParam  - 1. FTF Criteria    2. Map - FTF Criteria Id to Set of Products
    @outputparam - Fire Truck Finder records
    @calledFrom  - Execute method
    */
    @testVisible
    private List< Fire_Truck_Finder__c > createTruckFinderRecords(Fire_Truck_Finder_Criteria__c FTFCriteria, Map<Id, Set<Product2>> mapFTFCriteriaIdToProducts){
        if( FTFCriteria != null ){
            Fire_Truck_Finder__c truckFinder;
            List<Fire_Truck_Finder__c> listFireTruckFinders = new List<Fire_Truck_Finder__c>();
            
            if( mapFTFCriteriaIdToProducts.containsKey( FTFCriteria.Id ) ){
                for(Product2 currentProd : mapFTFCriteriaIdToProducts.get(FTFCriteria.Id)){
                    truckFinder = createTruckFinder(FTFCriteria, currentProd.Id);
                    
                    if( truckFinder != null ){
                        listFireTruckFinders.add( truckFinder );
                    }
                }
            }
            return listFireTruckFinders;
        }
        return null;
    }
    
    /*
    @description    - create Fire Truck Finder record
    @incoming Param - 1. FTF Criteria  2. Prsoduct Id
    @calledFrom     - createTruckFinderRecords
     */
    @testVisible
    private Fire_Truck_Finder__c createTruckFinder( Fire_Truck_Finder_Criteria__c FTFCriteria, Id ProductId ){
        if(FTFCriteria != null && String.isNotBlank(ProductId)){
            Fire_Truck_Finder__c truckFinder = new Fire_Truck_Finder__c();
            truckFinder.Product__c = ProductId;
            truckFinder.Contact__c = FTFCriteria.Contact__c;
            truckFinder.Fire_Truck_Finder_Criteria__c = FTFCriteria.Id;
            truckFinder.FTF_Apparatus_Type__c = FTFCriteria.FTF_Apparatus_Type__c;
            truckFinder.FTF_Brands__c = FTFCriteria.FTF_Brands__c;
            truckFinder.FTF_Mileage__c = FTFCriteria.FTF_Mileage__c;
            truckFinder.FTF_Chassis__c = FTFCriteria.FTF_Chassis__c;
            truckFinder.FTF_Pump_Size__c = FTFCriteria.FTF_Pump_Size__c;
            truckFinder.FTF_Tank_Size__c = FTFCriteria.FTF_Tank_Size__c;
            truckFinder.FTF_Budget_Max__c = FTFCriteria.FTF_Budget_Max__c;
            truckFinder.FTF_Budget_Min__c = FTFCriteria.FTF_Budget_Min__c;
            truckFinder.FTF_Year_Max__c = FTFCriteria.FTF_Year_Max__c;
            truckFinder.FTF_Year_Min__c = FTFCriteria.FTF_Year_Min__c;
            truckFinder.FTF_Aerial_Length_Max__c = FTFCriteria.FTF_Aerial_Length_Max__c;
            truckFinder.FTF_Aerial_Length_Min__c = FTFCriteria.FTF_Aerial_Length_Min__c;
            truckFinder.FTF_Geographic_Region__c = FTFCriteria.FTF_Geographic_Region__c;
            truckFinder.FTF_Warranty__c = FTFCriteria.FTF_Trucks_With_Warranty__c;
            truckFinder.FTF_Four_By_Four__c = FTFCriteria.FTF_Four_By_Four__c;
            return truckFinder;
        }
        return null;
    }
    
    /*
    @description - Insert List of Fire Truck Finder records
    @inputParam  - List of Fire Truck Finder records
    @calledFrom  - Execute method from Batch
    */
    @testVisible
    private void insertFireTruckFinders(List<Fire_Truck_Finder__c> listFireTruckFinder ){
        if( listFireTruckFinder != null && !listFireTruckFinder.isEmpty()){
            try{
                insert listFireTruckFinder;
            }
            catch( Exception e ){
                System.debug( 'Exception in inserting FireTruckFinders ::: '+ e );
                strErrors += '<br/><b>Exception in inserting FireTruckFinders : </b><br/>'+e;
            }
        }
    }
    
    /*
    @description - get API key for making callouts to Pardot
    @outputParam - API Key
    @calledFrom  - Start method
    */
    @testVisible
    private String authorizePardot(){        
        if( objPardotAPISetting != null ){
            PardotIntegration.PardotAuthResponse authResponse;
            
            if(test.isRunningTest()){
                authResponse = new PardotIntegration.PardotAuthResponse();
                authResponse.attributes = new PardotIntegration.attributes( 'ok', 1, null );
                authResponse.api_key ='4ed6b59d49de157774107aec3a11b856';
            }
            else{
                authResponse = PardotIntegration.getPardotAPIkey( objPardotAPISetting.Email__c, objPardotAPISetting.Password__c,
                                                                    objPardotAPISetting.User_Key__c, objPardotAPISetting.Authentication_url__c, 'POST' );
            }
                                                                                                                
            if( authResponse != null && authResponse.attributes != null ){
                if( PardotIntegration.isStatusOK( authResponse.attributes ) &&
                        String.isNotBlank( authResponse.api_key )){
                    System.debug( '**** Received API key ****' );
                    return authResponse.api_key;
                }
                else{
                    strErrors += String.format('<br/><b>Authentication Error:</b><br/>status:{0},err_code:{1}<br/>Error:{2}',
                                                new List<String>{ authResponse.attributes.stat,
                                                                  String.valueOf( authResponse.attributes.err_code ),
                                                                  authResponse.err });
                }
            }
        }
        return null;
    }
}