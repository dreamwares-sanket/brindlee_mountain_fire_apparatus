/**
 * @Purpose  	: Class to set mock response for FireTruckSunLimitedListViewBatchTest
 * @Name 		: MockResponseFireTruckBatchTest
 * @Created date: 15/05/2018
 */
@isTest
global class MockResponseFireTruckBatchTest implements HttpCalloutMock{
    
    //Return mock response
    global HTTPResponse respond(HTTPRequest request){
         
        if (request != null){
            return getResponse(request);
        }
        
        return null;
    }
    
    //Function to check endpoint & return mock response 
    public HTTPResponse getResponse(HTTPRequest request){ 
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(301);
        
        if (request.getEndpoint().equalsIgnoreCase('http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/')){
        	response.setBody('{"example":"Truck test batch"}'); 
            response.setHeader('Location', 'Test');
        }else if (request.getEndpoint().equalsIgnoreCase('Test')){
        	response.setBody('{<html> <body> <div class="help"> <a href="/www.google.com">Search Google</a> </div>} </body> </html>');    
        }else if (request.getEndpoint().equalsIgnoreCase('http://www.firetrucksunlimited.com/www.google.com')){
        	response.setBody('{"example":"test Batch"}');
        	response.setHeader('Location', 'TestPageList');    
        }else if (request.getEndpoint().equalsIgnoreCase('TestPageList')){
        	response.setBody('{<html> <body> <div class="help"> <a href="/www.googlemap.com">Search Google Map</a> <span class="truck-loop-con" href="www.test.com" value=This is for testing/ >' +  
                         		'<span class="truck-item-con" href="www.testTruck.com" /></div> </body> </html>}');    
        }else if (request.getEndpoint().equalsIgnoreCase('www.testTruck.com')){
        	response.setBody('{"example":"test detail info Batch"}');
        	response.setHeader('Location', 'TestTruckPage');    
        }else if (request.getEndpoint().equalsIgnoreCase('TestTruckPage')){
        	response.setBody('{<html> <body> <div> <p>Mileage 50</p> <p>Make TATA</p> <p>Asking Price:90000</p> <p>Model Fox4.5</p> ' + 
                             'Stock # <li>700</li> <div class="spec1 first"> <ul>Apparatus Info Truck for testing </ul> ' +
                             '<ul>Chassis 4507</ul> <ul>Transmission Road <li>Model:T1001 </li> <li> Type:T1.5 </li></ul> <ul>Pump Make:Rt3 Model:T75 GPM:Test</ul>' +
                             '<ul>Water Tank Gallons:457</ul> <ul>Foam Make: Tesd567</ul> <ul>Discharges Driver&#8217;s Side: 25 Officer&#8217;s Side: 50 Front: 40</ul> '+
                             '<ul>Lighting <ul> This is additional info </ul> </ul> <ul>Additional Features <ul> These are additional features</ul></ul>'+
                             '<ul>Suctions Drivers Side:gh6437 Driver&#8217;s Side:sd3 Officer&#8217;s Side:s3s4</ul>'+
                             '<p><h3>Location > <Test/> </p> </div> </div> </body> </html>');    
        }
        
        return response; 
    }
}