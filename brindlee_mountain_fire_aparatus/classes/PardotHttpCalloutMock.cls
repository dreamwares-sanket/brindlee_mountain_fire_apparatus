/*
* @description - Test class for FireTruckFinder_Scheduler
* @createdby   - Dreamwares
* @createdDate - 7/12/2015
*/

global class PardotHttpCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond( HTTPRequest req ) {
        if( req != null ){
            String strBody;
            HttpResponse hres;
            if( req.getEndpoint().contains( 'https://pi.pardot.com/api/login/version/3' ) ){
                hres = new HttpResponse();
                strBody = '{"@attributes":{"stat":"ok","version":1},"api_key":"4ed6b59d49de157774107aec3a11b856"}';
                hres.setBody( strBody );
                hres.setHeader('Content-Type', 'application/json');
                hres.setStatusCode(200);
                return hres;
            }
            else if( req.getEndpoint().contains( 'https://pi.pardot.com/api/prospect/version/3/do/batchUpdate?prospects=' ) ){
                hres = new HttpResponse();
                strBody = '{"errors":[]}';
                hres.setBody( strBody );
                hres.setHeader('Content-Type', 'application/json');
                hres.setStatusCode(200);
                return hres;
            }
            else if( req.getEndpoint().contains( 'https://pi.pardot.com/api/email/version/3/do/send/prospect_id/' ) ){
                hres = new HttpResponse();
                strBody = '{ "@attributes": { "stat": "ok", "version": 1 }, "email": { "id": 112275565, "name": "Email - FTF Match Notification",'+
                    '"isOneToOne": true, "subject": "See Matching Fire Trucks", "message": { "text": "Hello,The Fire Truck'+
                    'Finder at Brindlee has found a" }, "created_at": "2015-12-07 07:18:37" }}';
                hres.setBody( strBody );
                hres.setHeader('Content-Type', 'application/json');
                hres.setStatusCode(200);
                return hres;
            }
        }
        return null;
    }
    // error generation class
    global class PardotErrors implements HttpCalloutMock{
        global HTTPResponse respond( HTTPRequest req ) {
            String strBody;
            HttpResponse hres;
            if( req.getEndpoint().contains( 'https://pi.pardot.com/api/login/version/3' ) ){
                hres = new HttpResponse();
                strBody = '{"@attributes":{"stat":"ok","version":1},"api_key":"4ed6b59d49de157774107aec3a11b856"}';
                hres.setBody( strBody );
                hres.setHeader('Content-Type', 'application/json');
                hres.setStatusCode(200);
                return hres;
            }
            else if( req.getEndpoint().contains( 'https://pi.pardot.com/api/prospect/version/3/do/batchUpdate?prospects=' ) ){
                hres = new HttpResponse();
                strBody = '{"errors":{"3453443":"Invalid prospect email address"}}';
                hres.setBody( strBody );
                hres.setHeader('Content-Type', 'application/json');
                hres.setStatusCode(200);
                return hres;
            }
            else if( req.getEndpoint().contains( 'https://pi.pardot.com/api/email/version/3/do/send/prospect_id/' ) ){
                hres = new HttpResponse();
                strBody = '{"@attributes":{"stat":"fail","version":1,"err_code":3},"err":"Invalid prospect ID"}';
                hres.setBody( strBody );
                hres.setHeader('Content-Type', 'application/json');
                hres.setStatusCode(200);
                return hres;
            }
        	return null;
        }
    }
}