/**
    @ Purpose : Tests the mock response for CommandFireApparatusTest class.
*/

@isTest
global class MockResponseCommandFireApparatus implements HttpCalloutMock {
    
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
        response.setHeader( 'Location', request.getEndpoint() );
        response.setStatusCode( 301 );
        
        if( request.getEndpoint().equalsIgnoreCase( 'https://www.commandfireapparatus.com/inventory/' ) ) {
            response.setBody( '<ul class=\'page-numbers\'><li><a class=\'page-numbers\' href=\'https://www.commandfireapparatus.com/inventory/page/1/?availability=now-available\'>1</a></li></ul>' );
        }
        else if( request.getEndpoint().startsWithIgnoreCase( 'https://www.commandfireapparatus.com/inventory/page/1/' ) ) {
            response.setBody( '<div class="stm-isotope-sorting stm-isotope-sorting-list"><div class="title heading-font"><a href="https://www.commandfireapparatus.com/listing/2003-freightliner-e-one-1500-750-pumper/" class="rmv_txt_drctn">2003 Freightliner E-One 1500/750 Pumper  </a></div> </div><div class="stm_ajax_pagination stm-blog-pagination"></div>' );
        }
        else if( request.getEndpoint().equalsIgnoreCase( 'https://www.commandfireapparatus.com/listing/2003-freightliner-e-one-1500-750-pumper/' ) ) {
            response.setBody( '<div class="single-regular-price text-center"><span class="h3">89,000 $ USD</span></div><div class="stm-car-location cmd-vc-el"> <h4 class="unit-location">Unit Location:</h4><span>Illinois</span></div><ul class="wpb_tabs_nav ui-tabs-nav vc_clearfix"><li><a href="#tab-90676444-d4f2-8b357-39d49eb5-32ee5312-a51b">Vehicle overview</a></li><li><a href="#tab-1446536320841-4-6b357-39d49eb5-32ee5312-a51b">Request Info Now</a></li></ul><div id="tab-90676444-d4f2-8b357-39d49eb5-32ee5312-a51b" class="wpb_tab ui-tabs-panel wpb_ui-tabs-hide vc_clearfix"><div class="wpb_text_column wpb_content_element " ><div class="wpb_wrapper"><p>2003 Freightliner/E-One rural pumper, Freightliner 4 door enclosed cab powered by a Cummins 300 HP diesel engine and Allison automatic transmission, 4 seats with 3 SCBA seats, 37,600 lb. GVWR, Hale 1500 GPM QMax fire single stage side mounted fire pump, extended front bumper with front suction intake, 2 crosslays, preconnected deck gun with stacked tips, 2 rear discharges, 750 gallon POLY tank, right side LDH discharge, E-One aluminum body with high side compartments on BOTh sides, overhead ladder rack with 2 aluminum ground ladders, stainless steel wheel covers, 6&#8243; hard suction hose, 3 hose bed dividers, SCBA holders in wheel wells, reflective chevrons on rear, warning lights, air horns and electronic siren, 89,000 miles, excellent condition&#8230;$ 89,000</p><p>&nbsp;</p><p>Dimensions: 34&#8242; Long X 9&#8217;7&#8243; High</p></div></div></div><h1 class="title h2">2003 Freightliner E-One 1500/750 Pumper</h1><div class="single-car-data"><table><tr><td class="t-label">Unit Type</td>   <td class="t-value h6">Pumpers</td></tr><tr><td class="t-label">Manufacturer</td><td class="t-value h6">E-One, Freightliner</td></tr><tr><td class="t-label">Year</td><td class="t-value h6">2003</td></tr><tr><td class="t-label">Mileage</td><td class="t-value h6">89000</td></tr></table></div>' );
        }
        return response; 
    }
}