/*
 * @Description     - Batch class for updating Pardot Prospects and then making API calls to invoke email sends.
 *                    Truck records with required criteria are fetched and emails are sent to the prospect associated with the product at the field Seller Contact.
 *                    Email template Id is selected depending on the number of days that have passed for the trucks( 7/30/60 )
 * @CreatedBy       - Dreamwares
 * @CreatedDate     - 14/01/2016
 * @LastUpdatedDate - 21/03/2016
 * @LastUpdatedBy   - Dreamwares
 */ 
global class SellerSegmentationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful {
    
    private String strApiKey, strErrors;
    private Pardot_API_Settings__c objPardotAPISetting;
    
    /*
    @description - Fetch Seller Segmentation Emails Settings(Custom Settings)
    @calledFrom  - 1. Start method                 
     */
    public List<Seller_Segmentation_Emails_Setting__c> fetchSegmentationSettings(){
        return Seller_Segmentation_Emails_Setting__c.getAll().values();
    }
    
    /*
    @description - get Date values for Interval dates from Seller Email Segmentation Settings(Custom Settings)
    @calledFrom  - 1. Start method
     */
    public Set<Date> getIntervalDatesForEmailSegmentation( List<Seller_Segmentation_Emails_Setting__c> listEmailSegmentationSettings ){
        if( listEmailSegmentationSettings != null && !listEmailSegmentationSettings.isEmpty() ){
            Set<Date> setSegmentationDates = new Set<Date>();
            Date dateToday = System.today();
            
            for(Seller_Segmentation_Emails_Setting__c currentSetting : listEmailSegmentationSettings ){
                setSegmentationDates.add(dateToday.addDays(-Integer.valueOf(currentSetting.Interval_Days__c)));
            }
            return setSegmentationDates;
        }
        return null;
    }
    
    /*
    @description - 1. Authenticate to Pardot and obtain API key
                   2. Generate query for Product
     */ 
    global Database.QueryLocator start( Database.BatchableContext bc ){
        strErrors = '';     // Initialize error strings
        fetchPardotSettings();
        authorizePardot();  // Provide authentication and recieve API key for Pardot
                                                                        
        Set<Date> setIntervalDates = getIntervalDatesForEmailSegmentation(fetchSegmentationSettings());
        return Database.getQueryLocator([ SELECT Id, Name, Posting_Date__c, Truck_Public_URL__c, Seller_Contact__c, Seller_Contact__r.Pardot_Id__c,
                                                 Seller_Contact__r.pi__url__c,
                                                 ( SELECT Id, Contact__c, Inquiry_Type__c FROM Product2.Truck_Inquiries__r ),
                                                 ( SELECT Id FROM Product2.Fire_Truck_Finder__r )
                                          FROM Product2
                                          WHERE IsActive = True
                                                AND status__c = 'Available'
                                                AND TypeOfSale__c = 'Broker'
                                                AND Posting_Date__c IN :setIntervalDates ]);
    }
    
    /*
    @description - Count the number of Truck Inquiries and Fire Truck Finder records associated with each Product.
                   Html value is created from the same, which would be populated to the associated Prospect in Pardot.
                   Then API calls are made to trigger email sends from pardot
     */ 
    global void execute( Database.BatchableContext bc, List< Product2 > listProducts ){
        if( listProducts != null && !listProducts.isEmpty() && objPardotAPISetting != null ){
            //System.debug('PRoductS:'+listProducts);
                    
            Map<String, Map<Id, Integer>> MapInquiryTypeToMapInquiryCount;
            MapInquiryTypeToMapInquiryCount = createInquiryTypeToProductInquiriesCountMap(listProducts);
            
            Map<Id, Integer> mapProductIdToPhoneInquiries, mapProductIdToWebInquiries;
            mapProductIdToPhoneInquiries = MapInquiryTypeToMapInquiryCount.get('phone');
            mapProductIdToWebInquiries = MapInquiryTypeToMapInquiryCount.get('web');  
                        
            Map<Id, Integer> mapProductIdToTruckFinderCount;                // Map of Product Id and count of truck finder
            mapProductIdToTruckFinderCount = getMapProductIdToTruckFinderCount( listProducts );
                    
            Map<Id, String> mapProductIdToHTMLValue;                        // Map of Product Id and related HTML
            mapProductIdToHTMLValue = createMapProductIdToHTMLValue( listProducts,
                                                                        mapProductIdToPhoneInquiries,
                                                                        mapProductIdToWebInquiries,
                                                                        mapProductIdToTruckFinderCount );
            //System.debug( 'TRuck HTML:'+ Json.serialize( mapProductIdToHTMLValue ) );
            
            //List<Seller_Segmentation_Emails_Setting__c> listEmailSegmentationSettings = fetchSegmentationSettings();
            Map<Date, Seller_Segmentation_Emails_Setting__c> mapDateToPardotSetting = createMapDateToPardotSetting( fetchSegmentationSettings() );
            
            // create mapping of segmentatation interval days to Map of Contact Ids and associated Products        
            Map<Date, Map<Id, Set<Product2>>> mapDateToMapContactIdsProducts;
            mapDateToMapContactIdsProducts = createMapPostingDayToContactsProducts( listProducts, mapDateToPardotSetting.keySet() );
            System.debug('mapDateToMapContactIdsProducts:\n'+Json.serialize(mapDateToMapContactIdsProducts));
            
            if( mapDateToMapContactIdsProducts != null && !mapDateToMapContactIdsProducts.isEmpty() ){
                Map<Id, String> mapContactIdToPardotId = new Map<Id, String>();     // Map of Contact Id and corresponding Pardot Prospect Id
                mapContactIdToPardotId = createMapContactToProspectId( listProducts );
                
                List<String> listProspectJson = createJsonForBatchUpdatingProspects( mapContactIdToPardotId,
                                                                                     mapDateToMapContactIdsProducts,
                                                                                     mapProductIdToHTMLValue,
                                                                                     mapDateToPardotSetting );
                
                //System.debug('listProspectJson:\n'+Json.serialize(listProspectJson));
                if( listProspectJson != null && !listProspectJson.isEmpty()){
                    // Make update requests to pardot through each string which contains a batch of upto 50 prospects  
                    for( String jsonData : listProspectJson ){
                        makeProspectBatchUpdateReq( jsonData );
                    }
                    Map<Id, Set<Product2>> mapContactIdToProducts;
                    
                    // make API requests for sending emails to Pardot Prospects
                    for( Date currentDate : mapDateToMapContactIdsProducts.keySet() ){
                        mapContactIdToProducts = mapDateToMapContactIdsProducts.get(currentDate);
                        
                        if( !mapContactIdToProducts.isEmpty() ){
                            handlePardotEmailRequests( mapContactIdToPardotId,
                                                       mapContactIdToProducts.keySet(),
                                                       String.ValueOf( mapDateToPardotSetting.get(currentDate).Pardot_Template_Id__c ));
                        }
                    }
                }                
                // Update count of Truck Inquiries in products 
                listProducts = modifyProducts( listProducts, mapProductIdToPhoneInquiries, mapProductIdToWebInquiries );
                updateProducts( listProducts );
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        if( String.isNotBlank( strErrors )
                && objPardotAPISetting != null
                && String.isNotBlank( objPardotAPISetting.Error_Report_Email_Ids__c )){
            
            strErrors = String.format('<ol>{0}</ol>', new List<String>{ strErrors });
            //System.debug( 'Errors:'+strErrors );
            sendErrorMails( strErrors, objPardotAPISetting.Error_Report_Email_Ids__c );  // send errors via emails
        }
    }   
    
    /*
    @description - make email requests to pardot Prospects with the Template Id specified in the call
    @inputparam  - 1. Map of Contact Id to Prospect Id
                   2. Set of Contact Ids
                   3. Pardot template Id
    @calledFrom  - Execute method
     */
    private void handlePardotEmailRequests( Map<Id, String> mapContactIdToPardotId, Set<Id> setContactIds, String templateId ){
        if( mapContactIdToPardotId != null && !mapContactIdToPardotId.isEmpty()
                && setContactIds != null && !setContactIds.isEmpty()
                && String.isNotBlank( templateId )){
                    
            String strMethod = 'POST';
            for( Id ContactIds : setContactIds ){
                makePardotEmailRequests( ContactIds, mapContactIdToPardotId.get( ContactIds ), templateId, strMethod );
            }
        }
    }
    
    /*
    @description - Make email request to Pardot and also generate errors' string and handle api response
    @inputParam  - 1. Contact Id
                   2. Pardot Prospect Id for Contact
                   3. Template Id
                   4. Send method
    @calledFrom  - Method handlePardotEmailRequests
     */
    private void makePardotEmailRequests( Id ContactId, String strProspectId, String strTemplateId, String strMethod ){
        if( String.isNotBlank( ContactId ) && String.isNotBlank( strProspectId )
                && String.isNotBlank( strMethod ) && objPardotAPISetting != null ){
                    
            String SalesforcebaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            try{
                PardotIntegration.EmailSendAPIResponse emailResponse;
                
                if( !Test.isRunningTest() ){
                    emailResponse = PardotIntegration.sendEmailRequest( strProspectId, objPardotAPISetting.Single_Email_Url__c,
                                                                           strMethod, objPardotAPISetting.User_Key__c,
                                                                           strApiKey, objPardotAPISetting.Truck_Match_Pardot_Campaign_Id__c,
                                                                           strTemplateId );
                }
                else{
                    String strEmailResponse = '{ "attributes": { "stat": "ok", "version": 1 }, "email": { "id": 112275565, "name": "Email - FTF Match Notification",'+
                                                '"isOneToOne": true, "subject": "See Matching Fire Trucks", "message": { "text": "Hello,The Fire Truck'+
                                                'Finder at Brindlee has found a" }, "created_at": "2015-12-07 07:18:37" }}';
                    emailResponse = new PardotIntegration.EmailSendAPIResponse();
                    emailResponse = emailResponse.parse( strEmailResponse );
                }
                
                if( emailResponse != null ){
                    if( PardotIntegration.isStatusOK( emailResponse.attributes ) ){
                        System.debug('Email Send successful for Contact: '+ ContactId);
                    }
                    else{
                        strErrors += String.format('<li>Email Send failed for Prospect Id : {0},<br/>status:{1},err_code:{2}<br/>Error:{3}<br/>Salesforce Url :{4}/{5}<br/>'
                                                   +'Prospect Url :https://pi.pardot.com/prospect/read?id={0}<br/><br/></li>',
                                                         new List<String>{ strProspectId,
                                                                           emailResponse.attributes.stat,
                                                                           String.valueOf( emailResponse.attributes.err_code ),
                                                                           emailResponse.err,
                                                                           SalesforcebaseUrl,
                                                                           ContactId
                                                                        });
                    }
                }
            }
            catch( Exception e ){
                System.debug('Exception in API call for email send request ::: '+ e);
                strErrors += String.format('<li><br/><b>Exception in sending email:</b><br/>{0}<br/>Contact Url:{1}/{2}<br/><br/></li>',
                                                new List< String >{ e.getMessage(), SalesforcebaseUrl, ContactId });
            }
        }
    }
    
    /*
    @description - Create Json Strings for batch Update of prospect records
    @inputparam  - 1. Map Contact to Prospect Id
                   2. Map of Date to Map Contact Ids to Set of Products
                   3. Map of Product Id to HTML value
    @outputParam - List of Prospect batch update requests ( 1 request must contain upto 50 prospects ) 
    @calledFrom  - Execute method
     */
    private List<String> createJsonForBatchUpdatingProspects( Map< Id, String > mapContactIdToPardotId,
                                                               Map<Date, Map<Id, Set<Product2>>> mapDateToMapContactIdsProducts,
                                                               Map<Id, String> mapProductIdToHTMLValue,
                                                               Map<Date, Seller_Segmentation_Emails_Setting__c> mapDateToPardotSetting ){

        if( mapContactIdToPardotId != null && !mapContactIdToPardotId.isEmpty() 
                && mapDateToMapContactIdsProducts != null && !mapDateToMapContactIdsProducts.isEmpty() ){
            String strTruckReport, strBatchUpdateJson = '';
            Integer countContact = 0;
            List<String> listBatchRequests = new List<String>();
            Map<Id, Set<Product2>> mapContactIdToProduct;
            Map<Date, String> mapDayToTruckReportHTML;

            for( Id ContactId : mapContactIdToPardotId.keySet() ){
                mapDayToTruckReportHTML = new Map<Date, String>();
                
                // Get Truck report for all Prospect Fields
                for( Date currentDate : mapDateToMapContactIdsProducts.keySet() ){
                    mapContactIdToProduct = mapDateToMapContactIdsProducts.get(currentDate);
                    
                    if( !mapContactIdToProduct.isEmpty() && mapContactIdToProduct.containsKey(ContactId)){
                        strTruckReport = createHTMLReportForContactsProducts( mapContactIdToProduct.get(ContactId), mapProductIdToHTMLValue );
                        mapDayToTruckReportHTML.put(currentDate, strTruckReport);
                    }
                }
                //System.debug('mapDayToTruckReportHTML:\n'+json.serialize(mapDayToTruckReportHTML));
                
                if( !mapDayToTruckReportHTML.isEmpty() ){
                    // Consolidate the json field values for all prospect fields 
                    strBatchUpdateJson += createJsonForProspectUpdate( mapContactIdToPardotId.get( ContactId ), mapDayToTruckReportHTML, mapDateToPardotSetting );
                    countContact++;
                    
                    if( countContact == 48 ){       // add the batch request for current contact to the list
                        listBatchRequests.add( createBatchUpdateProspectsjson( strBatchUpdateJson ));
                        strBatchUpdateJson = '';
                        countContact = 0;
                    }
                }
            }
            
            if( countContact > 0 && countContact < 48 ){
                listBatchRequests.add( createBatchUpdateProspectsjson( strBatchUpdateJson )); 
            }
            return listBatchRequests;                     
        }
        return null;   
    }
    
    /*
    @description - Create map of Date formed to Seller Email Segmentation Setting record
    @inputparam  - Seller Email Segmentation Setting (Custom Setting)
    @outputParam - map of Date to assoc. Seller Email Segmentation Setting
    @calledFrom  - Execute method
     */
    private Map<Date, Seller_Segmentation_Emails_Setting__c> createMapDateToPardotSetting(List<Seller_Segmentation_Emails_Setting__c> listEmailSegmentationSettings){
        if(listEmailSegmentationSettings!= null && !listEmailSegmentationSettings.isEmpty()){
            Map<Date, Seller_Segmentation_Emails_Setting__c> mapDateToPardotSetting = new Map<Date, Seller_Segmentation_Emails_Setting__c>();
            Date dateToday = System.today();
            
            for(Seller_Segmentation_Emails_Setting__c currentSetting : listEmailSegmentationSettings ){
                mapDateToPardotSetting.put( dateToday.addDays(-Integer.valueOf(currentSetting.Interval_Days__c)), currentSetting );
            }
            return mapDateToPardotSetting;
        }
        return null;
    }
    
    /*
    @description - Create json field value pair for all the fields used in Prospect update 
    @inputparam  - 1. Prospect Id
                   2. Map of Date to Sellers Truck Report HTML for a prospect
                   3. Map Date to record Seller Email Segmentation Setting (Custom Setting)
    @outputParam - JSON including all the fields' values for single prospect
    @calledFrom  - method createJsonForBatchUpdatingProspects
     */
    private String createJsonForProspectUpdate( String strProspectId,
                                                    Map<Date, String> mapDayToTruckReportHTML,
                                                    Map<Date, Seller_Segmentation_Emails_Setting__c> mapDateToPardotSetting ){
        if( String.isNotBlank( strProspectId ) 
                && mapDayToTruckReportHTML != null && !mapDayToTruckReportHTML.isEmpty()
                && mapDateToPardotSetting != null && !mapDateToPardotSetting.isEmpty()  ){
            String strJsonTemplate = '';
            
            for( Date currentDate : mapDayToTruckReportHTML.keySet() ){
                strJsonTemplate = formatJsonTemplate(strJsonTemplate, mapDateToPardotSetting.get(currentDate).Name, mapDayToTruckReportHTML.get(currentDate));
            }
            strJsonTemplate = strJsonTemplate.removeEnd(',');       // remove the extra comma added in the function
            return String.format('"{0}":\'{\'{1}\'}\',', new List<String>{ strProspectId, strJsonTemplate });
        }
        return null;
    }
       
    /*
    @description - Loop over The set of Products associated to a Contact and append HTML value from the Map
    @inputparam  - 1. Set of Products
                   2. map of Product Id to HTML report
    @outputParam - The HTML value to be updated to the Prospect( Contact )
    @calledFrom  - Method createJsonForBatchUpdatingProspects
     */
    private String createHTMLReportForContactsProducts( Set<Product2> setProducts, Map<Id,String> mapProductIdToHTMLValue ){
        if( setProducts != null && !setProducts.isEmpty()
                && mapProductIdToHTMLValue != null && !mapProductIdToHTMLValue.isEmpty() ){
            String strSellerTruckReport = '';
            Id ProductId;
            
            for( Product2 currentProduct : setProducts ){
                ProductId = currentProduct.Id;
                
                if( mapProductIdToHTMLValue.containsKey( ProductId )){
                    strSellerTruckReport += mapProductIdToHTMLValue.get( ProductId );
                }
            }
            return createHTMLForProspectReportField( strSellerTruckReport );
        }
        return null;
    }
    
    /*
    @description - Create json for a single prospect
    @inputparam  - json string for Product(s)
    @outputParam - json string for a Prospect
    @calledFrom  - Method createJsonForBatchUpdatingProspects
    */
    private String createHTMLForProspectReportField( String prospectHTML ){
        if( String.isNotBlank( prospectHTML )){
            String prospectJson = String.format('TRUCK REPORT:<br/><ul>{0}</ul>', new List<String>{prospectHTML});      // Append ul tag and title
            return JSON.serialize( prospectJson ).removeStart('"').removeEnd('"');
        }
        return null;
    }
    
    /*
    @description - Create outer json structure for batch update request
    @inputparam  - inner Json string 
    @outputParam - outer json string
    @calledFrom  - Method createJsonForBatchUpdatingProspects
    */
    private String createBatchUpdateProspectsjson( String strJson ){
        if( String.isNotBlank( strJson )){                  // create json for api call
            return '{"prospects":{'+ strJson.removeEnd(',') +'}}';
        }
        return null;
    }
       
    /*
    @description - Format the name value pair json for prospects
    @inputparam  - 1. String with current json  
                   2. Prospect Field Name 
                   3.Prospect Field Value
    @outputParam - Json with modified input Params
    @calledFrom  - method createJsonForProspectUpdate
     */
    private String formatJsonTemplate( String strCurrentJson, String strFieldName, String strFieldValue ){
        if( String.isNotBlank( strFieldName ) && String.isNotBlank( strFieldValue )){
            if( String.isNotBlank( strCurrentJson )){
                strCurrentJson += ',';
            }
            strCurrentJson += String.format( '"{0}":"{1}"', new List<String>{ strFieldName, strFieldValue });
        }
        return strCurrentJson;
    }
    
    /*
    @description - Create Maps of Contact Id to set of Products where each map will be mapped 
                   with Interval Dates from Product's Posting Date for the Seller Contact.
    @inputParam  - 1. List of Products  2. Interval Dates from Seller Segemenatation Settings
    @outputParam - Map of Product's Posting Date to map of Seller Contact Ids to respective Products ( Sellers to trucks )
    @calledFrom  - Execute method
     */ 
    public Map<Date, Map<Id, Set<Product2>>> createMapPostingDayToContactsProducts( List<Product2> listProducts, Set<Date> setIntervalDates ){
        if( setIntervalDates != null && !setIntervalDates.isEmpty() ){
            //System.debug('setIntervalDates:'+Json.serialize(setIntervalDates));
                    
            Map<Date, Map<Id, Set<Product2>>> mapDateToMapContactIdsProducts = new Map< Date, Map< Id, Set<Product2>>>();
            String SalesforcebaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            Id ContactId;
            Map<Id, Set<Product2>> mapContactIdToProducts;
            Date dateTruckPosting;
            for( Product2 currentProduct : listProducts ){
                ContactId = currentProduct.Seller_Contact__c;
                
                if( String.isNotBlank(ContactId) ){    
                    
                    dateTruckPosting = currentProduct.Posting_Date__c;
                    if( mapDateToMapContactIdsProducts.containsKey(dateTruckPosting)){
                        mapContactIdToProducts = mapDateToMapContactIdsProducts.get(dateTruckPosting);
                    }
                    else{
                        mapContactIdToProducts = new Map<Id, Set<Product2>>();
                    }
                    
                    if( mapContactIdToProducts.containsKey(ContactId) ){
                        mapContactIdToProducts.get(ContactId).add(currentProduct);
                    }
                    else{
                        mapContactIdToProducts.put(ContactId, new Set<Product2>{currentProduct});
                    }
                    mapDateToMapContactIdsProducts.put(dateTruckPosting, mapContactIdToProducts);
                }
                else{
                    strErrors += String.format('<li>Seller Contact not found on Product: <a href="{0}/{1}">{2}</a><br/><br/></li>',
                                               new List<String>{SalesforcebaseUrl, currentProduct.Id, currentProduct.Name});
                }
            }
            return mapDateToMapContactIdsProducts;
        }
        return null;
    }
    
    /*
    @description - Used to find the number of truck Enquiry records related to Product.
                   Truck Inquiries of type 'web' and 'phone' are stored in map.
    @inputParam  - List of Products
    @outputParam - Map strings values (web/phone) to map of Product Ids and Count of Truck Inquiries
    @calledFrom  - Execute method
     */ 
    private Map<String, Map<Id, Integer>> createInquiryTypeToProductInquiriesCountMap( List<Product2> listProducts ){
        Integer phoneCount, webCount, zeroValue = 0;            // Count number of phone and web inquiries
        Map<Id, Integer> mapProductIdToWebInquiries = new Map<Id, Integer>();
        Map<Id, Integer> mapProductIdToPhoneInquiries = new Map<Id, Integer>();
        
        for( Product2 currentProduct : listProducts ){          // Calculate number of web and phone inquiries 
            
            if( currentProduct.Truck_Inquiries__r != null
               && !currentProduct.Truck_Inquiries__r.isEmpty() ){
                   phoneCount = webCount = zeroValue;
                   
                   for( Truck_Inquiries__c truckInquiry : currentProduct.Truck_Inquiries__r ){
                       
                       if( String.isNotBlank( truckInquiry.Inquiry_Type__c ) ){
                           if( truckInquiry.Inquiry_Type__c.equalsIgnoreCase('phone') ){
                               phoneCount++;
                           }
                           else if( truckInquiry.Inquiry_Type__c.equalsIgnoreCase('web') ){
                               webCount++;
                           }
                       }
                   }
                   mapProductIdToPhoneInquiries.put( currentProduct.Id, phoneCount );        
                   mapProductIdToWebInquiries.put( currentProduct.Id, webCount );                    
               }
            else{
                mapProductIdToPhoneInquiries.put( currentProduct.Id, zeroValue );        
                mapProductIdToWebInquiries.put( currentProduct.Id, zeroValue );
            }
        }
        
        // Create a map to identify phone and web inquiry maps
        Map<String, Map<Id, Integer>> MapInquiryTypeToMapInquiryCount = new Map<String, Map<Id, Integer>>();
        MapInquiryTypeToMapInquiryCount.put( 'phone', mapProductIdToPhoneInquiries );
        MapInquiryTypeToMapInquiryCount.put( 'web', mapProductIdToWebInquiries );
        
        return MapInquiryTypeToMapInquiryCount;
    }
    
    /*
    @description - Map Product Ids to count of related Truck finder records
    @inputParam  - List of Products
    @outputParam - Map of Product Ids to Count of Truck Finders
    @calledFrom  - Execute method of batch class
     */
    private Map<Id, Integer> getMapProductIdToTruckFinderCount( List<Product2> listProducts ){
        Map<Id, Integer> mapProductIdToTruckFinderCount = new Map<Id, Integer>();
        Integer zeroValue = 0;
        
        for( Product2 currentProduct : listProducts ){
            if( currentProduct.Fire_Truck_Finder__r != null && !currentProduct.Fire_Truck_Finder__r.isEmpty() ){
                mapProductIdToTruckFinderCount.put( currentProduct.Id, currentProduct.Fire_Truck_Finder__r.size() );                           
            }
            else{
                mapProductIdToTruckFinderCount.put( currentProduct.Id, zeroValue );  
            }
        }
        return mapProductIdToTruckFinderCount;
    }
    
    /*
    @description  - Create Map of Product Id to associated HTML value for each product.
    @inputParams  - 1. List of Products
                    2. Map product Ids to Phone Inquiries
                    3. Map product Ids to Web Inquiries
                    4. Map product Ids to no. of Truck Finders
    @outputParams - Map of Product Id to asscociated HTML
    @calledFrom   - Execute method
     */ 
    private Map<Id, String> createMapProductIdToHTMLValue( List<Product2> listProducts,
                                                                    Map<Id, Integer> mapProductIdToPhoneInquiries,
                                                                    Map<Id, Integer> mapProductIdToWebInquiries,
                                                                    Map<Id, Integer> mapProductIdToTruckFinderCount ){
        Map<Id, String> mapProductIdToHTMLValue = new Map<Id, String>();
        Integer phoneCount, webCount, truckFinderCount;
        String productHTML;
        Id productId;
            
        for( Product2 currentProduct : listProducts ){
            productId = currentProduct.Id;
            phoneCount = webCount = truckFinderCount = 0;
            productHTML = '';
                
            if( mapProductIdToPhoneInquiries.containsKey(productId) ){
                phoneCount = mapProductIdToPhoneInquiries.get( productId );
            }
            if( mapProductIdToWebInquiries.containsKey(productId) ){
                webCount = mapProductIdToWebInquiries.get( productId );
            }
            if( mapProductIdToTruckFinderCount.containsKey(productId) ){
                truckFinderCount = mapProductIdToTruckFinderCount.get( productId );
            }
            
            productHTML = createProductHTML( currentProduct, phoneCount, webCount, truckFinderCount );
            mapProductIdToHTMLValue.put( productId, productHTML );
        }
        return mapProductIdToHTMLValue;                                                         
    }
    
    /*
    @description - Create HTML value for a product.
    @inputparam  - 1. Product       2. Phone Count 
                   3. Web Count     4. Truck Finder Count
    @outputParam - HTML string
    @calledFrom  - Method createMapProductIdToHTMLValue
    */
    private String createProductHTML( Product2 objProduct, Integer phoneCount, Integer webCount, Integer truckFinderCount ){
        if( objProduct != null ){
            String truckHTML = '<li>{0}</li><br/><ol><li>We have had {1} truck inquires by phone.</li><li>We have had {2} truck inquires online.</li>'+
                               '<li>We have had {3} Fire Truck Finder matches.</li></ol><br/>Click <a href="{4}">here</a> to view your truck.<br/><br/>';
            
            truckHTML = String.format( truckHTML, new List<String>{  objProduct.Name,
                                                                     String.valueOf(phoneCount),
                                                                     String.valueOf(webCount),
                                                                     String.valueOf(truckFinderCount),
                                                                     objProduct.Truck_Public_URL__c });
            return truckHTML;
        }
        return null;
    }
    
    /*
    @description - Create map of Contact Ids to Contact Prospect Ids from assoiated Prospects
    @inputParam  - List of Products
    @outputParam - Map of Contact Ids ( Sellers of Trucks ) to Pardot Urls
    @calledFrom   - Execute method
     */
    private Map<Id, String> createMapContactToProspectId( List<Product2> listProducts ){
        if( listProducts != null && !listProducts.isEmpty() ){
            
            String SalesforcebaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            Map<Id, String> mapContactToPardotId = new Map<Id, String>();
            
            for( Product2 currentProduct : listProducts ){
                //System.debug('currentProduct:::'+currentProduct);
                if( String.isNotBlank( currentProduct.Seller_Contact__c ) && String.isNotBlank( currentProduct.Seller_Contact__r.Pardot_Id__c ) ){
                    mapContactToPardotId.put( currentProduct.Seller_Contact__c, currentProduct.Seller_Contact__r.Pardot_Id__c );
                }
                else{
                    //System.debug('Errors:::'+strErrors);
                    strErrors += String.format('<li>Pardor Id not found for Seller ( Contact ) associated to Product : <a href="{0}/{1}">{2}</a><br/><br/></li>',
                                               new List<String>{SalesforcebaseUrl, currentProduct.Id, currentProduct.Name});
                }
            }
            return mapContactToPardotId;
        }
        return null;
    }
        
    /*
    @description - Fetch Pardot custom settings 
    @calledFrom  - Start method
     */ 
    private void fetchPardotSettings(){
        List<Pardot_API_Settings__c> listPardotSettings = Pardot_API_Settings__c.getAll().values();
        if( listPardotSettings != null && !listPardotSettings.isEmpty() ){
            objPardotAPISetting = listPardotSettings[0];
        }
        else{
            strErrors += '<li>Values not defined for custom settings : Pardot API Settings.<br/><br/></li>';
        }
    }
    
    /*
    @description - get the count of Truck Inquiry records for products 
    @inputparam  - 1. List of Product
                   2. Map of Product Ids to Phone Inquiries
                   3. map of Product Ids to Web inquiries
    @calledFrom  - Execute method
    */ 
    private static List<Product2> modifyProducts( List<Product2> listProducts, 
                                                    Map<Id, Integer> mapProductIdToPhoneInquiries, 
                                                    Map<Id, Integer> mapProductIdToWebInquiries){
        if( listProducts != null && !listProducts.isEmpty()
                && mapProductIdToPhoneInquiries != null && !mapProductIdToPhoneInquiries.keySet().isEmpty()
                && mapProductIdToWebInquiries != null && !mapProductIdToWebInquiries.keySet().isEmpty() ){
                    
            Integer webCount, phoneCount;
            Id ProductId;     
            for( Product2 currentProduct : listProducts ){
                phoneCount = webCount = 0;
                ProductId = currentProduct.Id;
                
                if( mapProductIdToPhoneInquiries.containsKey( ProductId )
                        && mapProductIdToPhoneInquiries.get( ProductId ) != null ){
                    phoneCount = mapProductIdToPhoneInquiries.get( ProductId );
                }
                
                if( mapProductIdToWebInquiries.containsKey( ProductId )
                        && mapProductIdToWebInquiries.get( ProductId ) != null ){
                    webCount = mapProductIdToWebInquiries.get( ProductId );
                }
                // update count of truck inquiries 
                currentProduct.of_Inquiries__c = webCount + phoneCount;
            }
            return listProducts;
        }
        return null;
    }
    
    /*
    @description - Update product records
    @inputParam  - List of Products
    @calledFrom  - Execute method
     */ 
    private void updateProducts( List<Product2> listProducts ){
        if( listProducts != null && !listProducts.isEmpty() ){
            List<Database.SaveResult> listDBResults;
            try{
                listDBResults = Database.update(listProducts, false);                
            }
            catch( Exception e ){
                System.debug('Exception in updating Products ::: '+ e);
                strErrors += '<li>Exception in updating Products:<br/>' + e + '<br/><br/></li>';
            }
            
            if(listDBResults != null && !listDBResults.isEmpty()){
                Database.SaveResult saveRes;
                for(Integer count=0; count<listProducts.size(); count++){
                    saveRes = listDBResults[count];
                    
                    if(!saveRes.isSuccess()){
                        for(Database.Error err : saveRes.getErrors()) {						// Operation failed, so get all errors  
                            strErrors += String.format('<li>Could not update Product with Id: {0}\nError Code : {1}\nError Msg : {2}<br/><br/></li>',
                                                       new List<String>{listProducts[count].Id, String.valueOf(err.getStatusCode()), err.getMessage()});
                        }
                    }
                }               
            }
        }
    }
    
    /*
    @description - Make Pardot Prospect Batch Update request
    @inputParam  - Json containing upto 50 prospect records for update
    @calledFrom  - Execute method
     */
    private void makeProspectBatchUpdateReq( String strJson ){
        if( String.isNotBlank( strJson )){
            strJson = EncodingUtil.urlEncode( strJson, 'UTF-8');        // URL Encode data
            
            PardotIntegration.ProspectBatchUpdate batchRes;
            if( !Test.isRunningTest() ){
                batchRes = PardotIntegration.batchUpdatePardotProspects( objPardotAPISetting.Batch_Update_Url__c,
                                                                         strJson,
                                                                         'POST',
                                                                         objPardotAPISetting.User_Key__c,
                                                                         strApiKey);
            }
            else{
                batchRes = new PardotIntegration.ProspectBatchUpdate();
                batchRes.attributes = new PardotIntegration.attributes( 'ok', 1, null );
            }
            if( batchRes != null ){
                if( PardotIntegration.isStatusOK( batchRes.attributes ) ){
                    System.debug('Batch Update Successful!!');
                }
                else if( String.isNotBlank( batchRes.err )){
                    strErrors += String.format('<li><b>Batch Update Errors:</b><br/>{0}<br/><br/></li>',
                                                    new List< String >{ batchRes.err });
                }
            }
        }
    }
    
    /*
    @description - Make authenticaion API request to obtain API key.
    @calledFrom  - Start Method
     */
    private void authorizePardot(){        
        if( objPardotAPISetting != null ){
            
            PardotIntegration.PardotAuthResponse authResponse;
            if( !test.isRunningTest() ){
                authResponse = PardotIntegration.getPardotAPIkey( objPardotAPISetting.Email__c, objPardotAPISetting.Password__c,
                                                                    objPardotAPISetting.User_Key__c, objPardotAPISetting.Authentication_url__c, 'POST' );
            }
            else{   // Test responses
                authResponse = new PardotIntegration.PardotAuthResponse();
                authResponse.attributes = new PardotIntegration.attributes( 'ok', 1, null );
                authResponse.api_key ='4ed6b59d49de157774107aec3a11b856';
            }   
            if( authResponse != null && authResponse.attributes != null ){
                if( PardotIntegration.isStatusOK( authResponse.attributes ) &&
                        String.isNotBlank( authResponse.api_key )){
                    
                    strApiKey = authResponse.api_key;
                    System.debug( '**** Recieved API key ****\n'+ strApiKey+'\n');
                }
                else{
                    strErrors += String.format('<li><b>Authentication Error:</b><br/>status:{0},err_code:{1}<br/>Error:{2}<br/><br/></li>',
                                                    new List<String>{ authResponse.attributes.stat,
                                                                      String.valueOf( authResponse.attributes.err_code ),
                                                                      authResponse.err });
                }
            }
        }
    }
    
    /*
    @description - Send email containing errors to all Users eith Email Ids in parameter
    @inputParam  - 1. Errors    2. Comma seperated Email Ids in a string
    @calledFrom  - Finish method of Batch class
    */
    private void sendErrorMails( String errors, String emailIds ){
        if( String.isNotBlank( emailIds )){
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String body;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses( emailIds.split(','));                                  // split emailIds by ',' to get all email Ids
            mail.setSubject('Seller Email Segmentation - Errors / Exceptions');
            body = 'Hi User,<br/><br/>' + 'The following errors occured in the batch job : <br/>' + errors + '<br/>';
            mail.setHtmlBody( body );
            mails.add( mail );
            
            Messaging.SendEmailResult[] results;
            try{
                results = Messaging.sendEmail(mails);
            }
            catch(Exception e){
                System.debug('Exception in sending error emails ::: '+ e);
            }
            if( results != null && !results.isEmpty() ){
                for( Messaging.SendEmailResult currentResult : results ){
                    if( currentResult.isSuccess() ){
                        System.debug('Errors-email Sent Successfully!!');
                    }
                    else{
                        System.debug('Errors-Email not Sent!!\n'+currentResult.getErrors());
                    }
                }
            }
        }
    }
}