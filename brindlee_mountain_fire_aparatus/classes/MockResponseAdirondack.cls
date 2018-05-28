/**
    @ Purpose : Tests the mock response for AdirondackTest class.
*/

@isTest
global class MockResponseAdirondack implements HttpCalloutMock {
    
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
        
        if( request.getEndpoint().equalsIgnoreCase( 'http://adirondackfire.com' ) ) {
            response.setBody( '<div class="collapse navbar-collapse" id="myNavbar"><div class="menu-main-menu-container"><ul id="menu-main-menu" class="main_nav"><li id="menu-item-472" class="menu-item menu-item-type-taxonomy menu-item-object-product_cat menu-item-472"><a href="http://adirondackfire.com/product_cat/new-listing/">New Listings</a></li></ul></div>' );
        }
		else if( request.getEndpoint().equalsIgnoreCase( 'http://adirondackfire.com/product_cat/new-listing/' ) ) {
            response.setBody( '<h1 class="page-title">Category: New Listings</h1></header><article id="post-3897" class="post-3897 product type-product status-publish has-post-thumbnail hentry product_cat-heavy-rescues product_cat-new-listing"><header class="entry-header"><h2 class="entry-title"><a href="http://adirondackfire.com/product/1997-spartan-smeal-105-aerial-ladder/" rel="bookmark">1994 Spartan /Saulsbury walk-around rescue</a></h2></header></article><nav class="navigation posts-navigation" role="navigation"></nav>' );
        }
		else if( request.getEndpoint().equalsIgnoreCase( 'http://adirondackfire.com/product/1997-spartan-smeal-105-aerial-ladder/' ) ) {
            response.setBody( '<title>1994 Spartan /Saulsbury walk-around rescue &#8211; Adirondack Fire Equipment website</title><ul class="single_pro_price"><li>ID# 768C-01-38 Asking $75,000</li></ul><p>&nbsp;</p><p>Engine:  Detroit Series 60  &#8211; 6,220 hrs</p><p>Transmission:  Allison HD4060P</p><p>Allison Trans Retarder</p><p>Total GVW:  65,500 lbs</p><p>Mileage: 21,154</p><p>Overall  Width:  8’ 8”</p><p>Overall Length: 39’ 2”</p><p>Overall  Height: 11’ 10”</p><p>Wheel Base: 230”</p><p>Front Tires:  425/65R22.5</p><p>Rear Tires:  IIR22.5</p><p>Ladders – 14’ Combo, 35’ Ext. 20’ Roof, 10’ Folding (ALL DUO SAFTEY)</p><p>2 – 28’ Ext Hose</p><p>Ladder Pipe with Pre-connect 3” Hose in Bed</p><p>Fire-Com System – No headsets</p><p>3/20/13 – Installed New Generator</p><p>Fed Signal View Paint Lightbar</p><p>Fed Signal &amp; Whelen 700s Warning Lights</p><p>Q2B Siren</p><p>Code 3 Model 3672 Siren</p><p>Onan Commercial SI 7.5 Generator</p>' );
        }
        return response; 
    }
}