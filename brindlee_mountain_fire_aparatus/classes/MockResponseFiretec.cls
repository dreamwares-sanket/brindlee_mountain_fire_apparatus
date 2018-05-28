/**
    @ Purpose : Tests the mock response for FiretecTest class.
*/

@isTest
global class MockResponseFiretec implements HttpCalloutMock {
    
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
        
        if( request.getEndpoint().equalsIgnoreCase( 'http://www.firetec.com' ) ) {
            response.setBody( '<div class="leftmenuWHITE"><ul><li><a href="/category/Pumping.html">USED&nbsp;PUMPERS</a></li><!--<li><a ref="/category/Demo.html">DEMOS</a></li><li><a href="/bid">FIRE&nbsp;TRUCKS&nbsp;FOR&nbsp;BID</a></li><li><a href="/category/soon">COMING IN 2019</a></li>--></ul></div>' );
        }
        else if( request.getEndpoint().startsWithIgnoreCase( 'http://www.firetec.com/category/Pumping.html' ) ) {
            response.setBody( '<div class="listingMenu"><h1>Used Pumping Engine</h1><table border="1" bordercolor=#82AC9B" cellpadding="2" align="center"><tr class="resultdetailplain" ><td valign=top align=center><a href="/detail/PE-11836.html">Click here for details on PE-11836</a><br><br></td></tr></table></div>' );
        }
        else if( request.getEndpoint().equalsIgnoreCase( 'http://www.firetec.com/detail/PE-11836.html' ) ) {
            response.setBody( '<div id="contentcolumn"><div class="innertube"><div>&nbsp;<a style="float: right" href="/detail/PE-12052.html">Next <b>></b></a>&nbsp;</div><br><h1>2014 HME Toyne</h1><br><div class="container"><div class="WebAd"><h3>PE-11836</h3> 2014 HME Toyne, Cummins turbo diesel, Allison automatic, air brakes, 1,500 gpm Hale, 500 gal tank, 15kw Onan hydraulic generator, (2) portable & (8) fixed scene lights, 9000# winch, deck gun, 200\' of 1.75" on crosslays, 150\' of 1.5" bumper, 1400\' of 4", 600\' of 2.5", (2) 10\' hard suction, 24\' & 16\' extension, 14\' roof & attic ladders, 8\' & 10\' pike poles and more! 3,722 miles. <font color=RED>Reduced!</font> Asking $375,000</b><br /><br /><b>Other Information relating to this Vehicle:</b><br /></style><br><br><div' );
        }
        return response; 
    }
}