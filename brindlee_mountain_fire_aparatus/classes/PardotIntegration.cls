/*
 * @description - Used for Salesforce Integration with Pardot in order to 
 *                  1. Update Pardot prospect field
 * @createdBy   - Dreamwares 
 * @createdDate - 1-12-2015
 */
global class PardotIntegration {
    
    /*
    @description - Send API request to Pardot for getting the API key
    @inputParams - 1. Email     2. Password    3. User key
                   4. url endpoint    5. request method
    @outputParam - PardotAuthResponse object
	@calledFrom  - 
		I) Fire Truck Finder
			authorizePardot method from batch class
	   II) Truck Segmentation Emails		 
			authorizePardot method from batch class
    */
    global static PardotAuthResponse getPardotAPIkey( String email, String password, String user_key,
                                                        String endpoint, String method ){
        if( String.isNotBlank( email ) && String.isNotBlank( password ) &&
                String.isNotBlank( user_key ) && String.isNotBlank( endpoint ) &&
                String.isNotBlank( method )){
             
            String strFormat = '{0}?email={1}&password={2}&user_key={3}&format=json';
            List< String > listArguments = new List< String > { endpoint, email, password, user_key };    
            String strUrl = String.format( strFormat, listArguments );
            //System.debug('Endpoint::'+strUrl);
            
            HttpResponse hres = sendHttpRequest( strUrl, method, null );
            //System.debug('Response:'+hres.getBody());
            if( hres != null ){
                Integer status = hres.getStatusCode();
                
                if( status >= 200 && status < 300 ){                // success
                    String response = hres.getBody().replace('"@attributes"','"attributes"'); 
                    
                    PardotAuthResponse objResponse = new PardotAuthResponse();
                    objResponse = objResponse.parse( response );
                    //System.debug('Response Object:'+objResponse);
                    return objResponse;                    
                }
                else{                                                // failure
                    System.debug('Authentication request failed ::: \n Status Code:' +
                                    status + ' : ' + hres.getStatus());
                    return new PardotAuthResponse( String.valueOf(hres), new attributes('fail', 3, status) );
                }
            }
        }
        return null;
    }
    
    /*
    @description  - Batch update the Prospect field FTF matching Trucks HTML
    @inputParams  - 1. Base Url 2. Prospect json data   3. Http method
                    4. User key 5. API key
    @outputParams - String result
	@calledFrom   -
		I) Fire Truck Finder
			processBatchUpdateRequest method from batch class
	   II) Truck Segmentation Emails
		 	makeProspectBatchUpdateReq method
    */ 
    global static ProspectBatchUpdate batchUpdatePardotProspects( String baseUrl, String jsonText, String method,
                                                        		  String user_key, String api_key ){
         
         if( String.isNotBlank( baseUrl ) && String.isNotBlank( jsonText ) && String.isNotBlank( method )
                && String.isNotBlank( user_key ) && String.isNotBlank( api_key ) ){
            
             String endPoint = String.format( '{0}user_key={1}&api_key={2}&format=json',
                                                    new List< String >{ baseUrl, user_key, api_key});
             jsonText = 'prospects=' + jsonText;			// concate key value pair
             System.debug('BatchEndPoint:'+endPoint);
             HttpResponse hres = sendHttpRequest( endPoint, method, jsonText );
             Integer status = hres.getStatusCode();
                    
                    
             if( status >= 200 && status < 300 ){
                 String response = hRes.getBody().replace('"@attributes"','"attributes"');
                 System.debug('Http response ::'+response);
                 
                 ProspectBatchUpdate result = new ProspectBatchUpdate();
                 try{
                     result = result.parse( response );
                 }
                 catch(Exception e ){
                     System.debug('Exception in parsing batch update response::: '+ e);
                 }
                 if( result != null ){
                    if( String.isNotBlank( result.err )){
                        System.debug( 'Batch update request failed with Errors : '+ result.err );
                        return result;
                    }
                    else{
                        String errors;
                        try{
                        	errors = parseBatchResponse( response );
                        }
                        catch(Exception e){
                            System.debug('Exception in parsing response :::'+ e);
                        }
                        if( String.isNotBlank( errors ) ){
                            return new ProspectBatchUpdate( errors, new attributes('fail' , 1, 0 ));
                        }
                        else{
                            return new ProspectBatchUpdate( errors, new attributes('ok' , 1, 0 ));
                        }
                    }
                 }
             }
             else{
             	 System.debug('Batch response :'+hres);          
             }
         }
         else{
            System.debug('**** Insufficient parameters for updating Pardot Prospect ****');
        }
        return null;
    }
    
    /*
    @description - parse batch Update errors (ones that are unable to be parsed from classes)
    @inputParam  - Json data
	@outputparam - Html String with  errors
	@calledFrom  - batchUpdatePardotProspects
     */ 
    private static String parseBatchResponse( String strJson ){
        if( String.isNotBlank( strJson )){
            strjson = strjson.replaceAll('[{|}]?["]?[\\[|\\]]?','').replace('errors:','');
            
            if( String.isNotBlank( strjson )){
                map< String, String > mapkeyValuePair = new Map< String, String >();
                List<String> keyValuePair;
                
                for( String prospect : strjson.split(',')){
                    keyValuePair = new List<String>(prospect.split(':'));
                    
                    if( mapkeyValuePair.containsKey( keyValuePair[0] ) && 
                       !mapkeyValuePair.get( keyValuePair[0] ).equalsIgnoreCase( keyValuePair[1] ) ){
                           
                           keyValuePair[1] = mapkeyValuePair.get( keyValuePair[0] ) + '; ' + keyValuePair[1];
                           mapkeyValuePair.put( keyValuePair[0], keyValuePair[1] );
                       }
                    else{
                        mapkeyValuePair.put( keyValuePair[0], keyValuePair[1] );
                    }
                }
                
                if( mapkeyValuePair != null && !mapkeyValuePair.keySet().isEmpty() ){
                    String errors='';
                    
                    for( String strkey : mapkeyValuePair.keySet() ){
                        errors += strkey + ' : ' + mapkeyValuePair.get(strKey) + '<br/>';
                    }
                    System.debug(errors);
                    return errors;
                } 
            }    
        }
        return null;
    }
    
    /*
    @description - Send single email request to Pardot API for prospect
    @inputParams - 1. Prospect Id   2. UrlEndpoint  3. Http Request Method
                    4. API key      5. Campaign Id  6. Email Template Id
    @outputParam - EmailSendAPIResponse object
	@calledFrom  - 
		I) Fire Truck Finder
				Execute method of batch class
	   II) Truck Segmentation
				makeEmailRequests
    */ 
    global static EmailSendAPIResponse sendEmailRequest( String prospect_id, String endpoint, String method, String user_key,
                                                            String api_key, String campaign_id, String email_template_id ){
        
        if( String.isNotBlank( prospect_id ) && String.isNotBlank( endpoint ) &&
                String.isNotBlank( method ) && String.isNotBlank( user_key ) &&
                String.isNotBlank( api_key ) && String.isNotBlank( campaign_id ) &&
                String.isNotBlank( email_template_id )){
                    
            String strFormat, strUrl, response;
            strFormat = '{0}{1}?user_key={2}&api_key={3}&campaign_id={4}&email_template_id={5}&format=json';
            
            List<String> listArguments = new List<String>{ endpoint, prospect_id, user_key,
                                                            api_key, campaign_id, email_template_id };      
            strUrl = String.format( strFormat, listArguments );
            System.debug('Email Send Url:'+strUrl);
            HttpResponse hRes = sendHttpRequest( strUrl, method, null );
            //System.debug('Email Response:'+hRes.getBody());
            response = hRes.getBody().replace('"@attributes"','"attributes"');
            EmailSendAPIResponse emailResponse = new EmailSendAPIResponse();
            emailResponse = emailResponse.parse( response );
            return emailResponse;
        }
        else{
            System.debug('****Insufficient parameters for sending Pardot email****');
        }
        return null;
    }
    
    /*
    @description - Send Http request
    @inputParams - 1. url endpoint    2. request method
    @outputParam - Httpresponse object
	@calledFrom  - 1. getPardotAPIKey	2. batchUpdatePardotProspects	3. sendEmailRequest
    */
    private static HttpResponse sendHttpRequest( String endpoint, String method, String body ){
        if( String.isNotBlank( endpoint ) && String.isNotBlank( method )){
            
            HttpRequest hreq = new HttpRequest();
            hreq.setEndpoint(endpoint);
            hreq.setMethod(method);
            
            if(String.isNotBlank( body )){
                hreq.setBody( body );
            }
            try{
                return new Http().send( hreq );
            }
            catch( Exception e ){
                System.debug('Exception ::: ' + e);
            }
        }
        return null;
    }
    
    /*
    @description - Check if the error status recieved for prospect email send is : 3 i.e invalid prospect Id.
				   It denotes that the Id is either invalid or the prospect has opted out of email service.
	@inputParam  - Object of PardotIntegration.attributes
    @outputParam - Boolean result
 	@calledFrom  - 1. Execute method of FireTruckFinder batch
    */ 
    public static Boolean isProspectIdInvalid( PardotIntegration.attributes attribs ){
        if( attribs != null && attribs.err_code == 3 ){
            return true;
        }
        return false;
    }
    
    /*
    @description - Check the status of callout for attribute value of stat = ok
    @inputParam  - Object of PardotIntegration.attributes
    @outputParam - Boolean result
	@calledFrom  -
		I) Fire Truck Finder
			1. Execute  2. authorizePardot  3. processBatchUpdateRequest
	   II) Truck Segmentation
			1. AuthorizePardot   2. makeEmailRequests method   3. makeProspectBatchUpdateReq
    */
    public static Boolean isStatusOK( PardotIntegration.attributes attribs ){
        if( attribs != null && String.isNotBlank( attribs.stat ) &&
                    attribs.stat.equalsIgnoreCase('ok') ){
            return true;
        }
        return false;
    }
    
    // DTO classes to parse json response

    global class PardotAuthResponse{
        public attributes attributes{ get; set;}
        public String api_key{ get; set;}
        public String err{ get; set; }
        
        public PardotAuthResponse(){
        }
        
        public PardotAuthResponse( String err, attributes attribs ){
        	this.err = err;
            this.attributes = attributes; 
        }
        
        global PardotAuthResponse parse(String json){
            return (PardotAuthResponse) System.JSON.deserialize( json, PardotAuthResponse.class);
        }
    }
    global class attributes {
        public String stat{ get; set;}
        public Integer version{ get; set;}
        public Integer err_code{ get; set;} 
        
        public attributes( String stat, Integer version, Integer err_code ){
            this.stat = stat;
            this.version = version;
            this.err_code = err_code;
        }
    }
    global class EmailSendAPIResponse{
        //public email email{get;set;}
        public String err{ get; set; }
        public attributes attributes{get;set;}        
		        
        global EmailSendAPIResponse parse( String json ){
            return (EmailSendAPIResponse) System.JSON.deserialize( json, EmailSendAPIResponse.class);
        }
    }
    global class ProspectBatchUpdate{
        public String err; //
        public attributes attributes{ get; set; }
        
        public ProspectBatchUpdate(){
        }
        
        public ProspectBatchUpdate(String err, attributes attr ){
            this.err = err;
            this.attributes = attr;
        }
        public ProspectBatchUpdate parse(String json){
            return (ProspectBatchUpdate) System.JSON.deserialize(json, ProspectBatchUpdate.class);
        }
    }
    /*
    global class message {
        public String html{get;set;}
        public String text{get;set;}
    }
    global class email {
        public String subject{get;set;}
        public String name{get;set;}
        public Boolean isOneToOne{get;set;}
        public Integer id{get;set;}
        public message message{get;set;}
        public String created_at{get;set;}
    }   
    */ 
}