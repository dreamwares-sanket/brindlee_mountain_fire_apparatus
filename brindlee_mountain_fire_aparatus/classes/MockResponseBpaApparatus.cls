/**
    @ Purpose : Tests the mock response for BpaApparatusTest class.
*/

@isTest
global class MockResponseBpaApparatus implements HttpCalloutMock {
    
    global HTTPResponse respond( HTTPRequest request ) {
         
        if( request != NULL ) {
            return getResponse( request );
        }
        return NULL;
    }
    
    //Function to check endpoint & return mock response 
    public HTTPResponse getResponse( HTTPRequest request ) { 
    
        HTTPResponse response = new HTTPResponse();
        response.setHeader( 'Content-Type', 'application/json' );
        response.setStatusCode( 200 );
        
        if( request.getEndpoint().equalsIgnoreCase( 'http://bpapparatus.com' ) ) {
            response.setBody( '<div class="ht-service-post-wrap"><div class="ht-service-post ht-clearfix"><div class="ht-service-icon"><i class="fa fa-check"></i></div><div class="ht-service-excerpt"><h5>PUMPERS AND ENGINES</h5><div class="ht-service-text">&nbsp;Click on the highlighted name below for more information. Thank you.<br/><a href="http://bpapparatus.com/pumpers-and-engines/">Read More <i class="fa fa-angle-right" aria-hidden="true"></i></a></div></div></section>' );
        }
        else if( request.getEndpoint().equalsIgnoreCase( 'http://bpapparatus.com/pumpers-and-engines/' ) ) {
            response.setBody( '<table id="tablepress-1" class="tablepress tablepress-id-1"><thead><tr class="row-1 odd"><th class="column-1">Item #</th><th class="column-2">Name</th><th class="column-3">Picture</th><th class="column-4">Model Year</th><th class="column-5">Chassis</th><th class="column-6">Engine</th><th class="column-7">Transmission</th><th class="column-8">Body</th><th class="column-9">Pump</th><th class="column-10">Tank</th><th class="column-11">List Price</th></tr></thead><tbody class="row-hover"><tr class="row-2 even"><td class="column-1">PE-1512</td><td class="column-2"><a href="http://bpapparatus.com/pumpers-and-engines/pe-1512/" rel="noopener" target="_blank">#PE-1512</a></td><td class="column-3"><img src="http://bpapparatus.com/wp-content/uploads/2017/12/2000-PE-1512-E-One-Hurricane0003-300x225.jpg" alt="" width="300" height="225" class="alignright size-medium wp-image-687" /></td><td class="column-4">2000</td><td class="column-5">E-One Hurricane</td><td class="column-6">Cummins ISM 450</td><td class="column-7">Allison HD 4060</td><td class="column-8">E-One</td><td class="column-9">Hale 1500 G.P.M.</td><td class="column-10">750 Gallon</td><td class="column-11">$35,000.00</td></tr></tbody></table>' );
        }
        else if( request.getEndpoint().equalsIgnoreCase( 'http://bpapparatus.com/pumpers-and-engines/pe-1512/' ) ) {
            response.setBody( '<h1 class="ht-main-title">Item # PE-1512 2000 E-One Hurricane</h1><table border="0" width="100%" cellspacing="0" cellpadding="0" align="left"><tbody><tr><td class="text1" align="left" valign="top">List Price $35,000.00<img class="alignright size-medium wp-image-812" src="http://bpapparatus.com/wp-content/uploads/2018/03/2000-PE-1512-E-One-Hurricane0017-300x115.jpg" alt="" width="300" height="115" srcset="http://bpapparatus.com/wp-content/uploads/2018/03/2000-PE-1512-E-One-Hurricane0017-300x115.jpg 300w, http://bpapparatus.com/wp-content/uploads/2018/03/2000-PE-1512-E-One-Hurricane0017.jpg 639w" sizes="(max-width: 300px) 100vw, 300px" /></span></strong></p><p>&nbsp;</p><div><strong>Year:</strong> 2000</div><div><strong>Miles:</strong> 82446</div><div><strong>Hours:</strong> 7844<br /><strong>Chassis:</strong> E-One Hurricane</div><div><strong>Air Pack Seats:</strong> 3</div><div><strong>Body:</strong> E-One<br /><strong>Engine:</strong> Cummins ISM 450</div><div><strong>Trans.:</strong> Allison HD4060</div><div><strong>Pump:</strong> Hale 1500 G.P.M., Stages: 1 Discharges Left: 2-2 1/2&#8243; Discharges Right: 1-2 1/2, 1-4&#8243;<br /><strong>Discharges Rear:</strong> 2-2 1/2&#8243;, LDH Discharge: Right Side</div><div><strong>Pre-Pipe Deck Gun:</strong> Yes,</div><div><strong>Front Suction:</strong> 5&#8243;</div><div><strong>Aux. Suction:</strong> 1-2 1/2 each Side Foam System: Yes</div><div><strong>Foam Tanks: </strong>30 Gallon</div><div><strong>Tank:</strong> 750 Gallon</div><div><strong>Ground Ladders:</strong> Yes</div><div><strong>Warning Lights:</strong> Federal</div><div><strong>Siren:</strong> Q2B</div><div><strong>Condition:</strong> Good</div></td></tr></tbody></table>' );
        }
        return response; 
    }
}