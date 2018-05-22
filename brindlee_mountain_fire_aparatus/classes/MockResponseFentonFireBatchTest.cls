/**
 * @Purpose  	: Class to set mock response for FentonFireListViewBatchTest
 * @Name 		: MockResponseFireTruckBatchTest
 * @Created date: 15/05/2018
 */
@isTest
global class MockResponseFentonFireBatchTest implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request){
        System.debug('request::'+request);
        if (request.getEndpoint().equalsIgnoreCase('http://www.firetrucksunlimited.com/') && request.getMethod().equalsIgnoreCase('GET')){
            return getResponse1();
        }
        
        if (request.getEndpoint().equalsIgnoreCase('Test1') && request.getMethod().equalsIgnoreCase('GET')){ 
            return getResponse2();
        }
        
        if (request.getEndpoint().equalsIgnoreCase('sample category/ test ? .com') && request.getMethod().equalsIgnoreCase('GET')){ 
            return getResponse3();
        }
        
        if (request.getEndpoint().equalsIgnoreCase('sample category/ test ? .com?page=1') && request.getMethod().equalsIgnoreCase('GET')){
            return getResponse4();
        }
        
        if (request.getEndpoint().equalsIgnoreCase('fenton') && request.getMethod().equalsIgnoreCase('GET')){
            return getResponse5();
        }
            
        if (request.getEndpoint().equalsIgnoreCase('MockTest') && request.getMethod().equalsIgnoreCase('GET')){
            return getResponse6();
        }    
        
        if (request.getEndpoint().equalsIgnoreCase('www.testgoogle.com') && request.getMethod().equalsIgnoreCase('GET')){
            return getResponse7();
        } 
        
        if (request.getEndpoint().equalsIgnoreCase('MockFenton') && request.getMethod().equalsIgnoreCase('GET')){
            return getResponse8();
        }
        
        return null;
    }
            
	public HTTPResponse getResponse1(){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type',  'application/json');
        response.setBody('{<ul class="sidebar__menu"> <li> Test1 href="Test1.com category/ Truck ?"</li> </ul>}');
        response.setStatusCode(301);
        response.setHeader('Location', 'Test1');
        return response; 
	} 

	public HTTPResponse getResponse2(){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type',  'application/json');
        response.setBody('{<html lang="en-US" prefix="og: http:"//ogp.me/ns# fb: http://ogp.me/ns/fb#"> <head > <meta charset="UTF-8" /> <meta name="viewport" content="width=device-width, initial-scale=1" /> <title>Firetrucks Unlimited - Fire Trucks For Sale | Fire Apparatus Service</title>'+
						'<meta name="description" content="Firetrucks Unlimited is the leader in affordable fire apparatus service and equipment. It&#039;s our mission to keep your fire trucks in service and in top condition!"/> <link rel="canonical" href="http://www.firetrucksunlimited.com/" /> <link rel="publisher" href="https:'+ '//plus.google.com/118027400639639800537/"/> <meta property="og:locale" content="en_US" /> <meta property="og:type" content="website" /> <meta property="og:title" content="Firetrucks Unlimited - The Refurb Leader!" /> <meta property="og:description" content="Firetrucks Unlimited is the leading fire truck refurbishment company. We also sell used fire trucks, brush trucks &amp; equipment" /> <meta property="og:url" content="http://www.firetrucksunlimited.com/" /> <meta property="og:site_name" content="Firetrucks Unlimited" /> <meta property="fb:app_id" content="597753036919499" />' +
						'<meta property="og:image" content="http://www.firetrucksunlimited.com/wp-content/uploads/Firetrucks-Unlimited-Logo-Small.png" /> <meta name="twitter:card" content="summary_large_image" /> <meta name="twitter:description" content="Firetrucks Unlimited is the leader in affordable fire apparatus service and equipment. It&#039;s our mission to keep your fire trucks in service and in top condition!" /> <meta name="twitter:title" content="Firetrucks Unlimited - Fire Trucks For Sale | Fire Apparatus Service" /> <meta name="twitter:site" content="@firetrucksunltd" /> <meta name="twitter:image" content="http://www.firetrucksunlimited.com/wp-content/uploads/Firetrucks-Unlimited-Logo-Small.png" /> <link rel=\'dns-prefetch\' href=\'//www.firetrucksunlimited.com\' /> '+
						'<link rel=\'dns-prefetch\' href=\'//fonts.googleapis.com\' /> <link rel=\'dns-prefetch\' href=\'//s.w.org\' /> <link rel="alternate" type="application/rss+xml" title="Firetrucks Unlimited &raquo; Feed" href="http://www.firetrucksunlimited.com/feed/" /> <link rel="alternate" type="application/rss+xml" title="Firetrucks Unlimited &raquo; Comments Feed" href="http://www.firetrucksunlimited.com/comments/feed/" /> <link rel=\'stylesheet\' id=\'parallax-pro-theme-css\'  href=\'http://www.firetrucksunlimited.com/wp-content/themes/parallax-pro/style.css?ver=1.9.10262016\' type=\'text/css\' media=\'all\' /> <link rel=\'stylesheet\' id=\'foobox-min-css\'  href=\'http://www.firetrucksunlimited.com/wp-content/plugins/fooboxV2/css/foobox.min.css?ver=2.4.0.0\' type=\'text/css\' media=\'all\' />' +
                        '<link rel=\'stylesheet\' id=\'et_monarch-open-sans-css\'  href=\'http://fonts.googleapis.com/css?family=Open+Sans:400,700\' type=\'text/css\' media=\'all\' />' +
						'<link rel=\'stylesheet\' id=\'et_monarch-css-css\'  href=\'http://www.firetrucksunlimited.com/wp-content/plugins/monarch/css/style.css?ver=1.2.2\' type=\'text/css\' media=\'all\' /> <link rel=\'stylesheet\' id=\'dashicons-css\'  href=\'http://www.firetrucksunlimited.com/wp-includes/css/dashicons.min.css?ver=4.9.5\' type=\'text/css\' media=\'all\' /> <link rel=\'stylesheet\' id=\'parallax-google-fonts-css\'  href=\'//fonts.googleapis.com/css?family=Lato:400,700,400italic&#038;ver=1.9.10262016\' type=\'text/css\' media=\'all\' /> <link rel=\'https://api.w.org/\' href=\'http://www.firetrucksunlimited.com/wp-json/\' /> <link rel="EditURI" type="application/rsd+xml" title="RSD" href="http://www.firetrucksunlimited.com/xmlrpc.php?rsd" /> <link rel="wlwmanifest" type="application/wlwmanifest+xml" href="http://www.firetrucksunlimited.com/wp-includes/wlwmanifest.xml" /> <meta name="generator" content="WordPress 4.9.5" /> '+
                         '<link rel="pingback" href="http://www.firetrucksunlimited.com/xmlrpc.php" /> <link rel="image_src" href="/wp-content/themes/firetrucks/images/FTU-Thumbnail.jpg" /> <meta name="msvalidate.01" content="F72B7C500E150B350440D98BDBDAADD9" />' +
                         '<link rel="icon" href="http://www.firetrucksunlimited.com/wp-content/uploads/cropped-FiretrucksUnlimited-Logo-Black-Square-favicon-32x32.png" sizes="32x32" /> ' +
						'<link rel="icon" href="http://www.firetrucksunlimited.com/wp-content/uploads/cropped-FiretrucksUnlimited-Logo-Black-Square-favicon-192x192.png" sizes="192x192" /> <link rel="apple-touch-icon-precomposed" href="http://www.firetrucksunlimited.com/wp-content/uploads/cropped-FiretrucksUnlimited-Logo-Black-Square-favicon-180x180.png" /> ' +
						'<meta name="msapplication-TileImage" content="http://www.firetrucksunlimited.com/wp-content/uploads/cropped-FiretrucksUnlimited-Logo-Black-Square-favicon-270x270.png" />' +
						'</head> <body class="home blog et_monarch header-image full-width-content parallax-home" itemscope itemtype="https://schema.org/WebPage"><div class="site-container"><div class="company-info widget-area"><section id="text-45" class="widget widget_text"><div class="widget-wrap"> <div class="textwidget"><div class="wrap"><span class="hdrphn">Call Us: (866) 876-0979</span><img class="hdrimgprnt" src="http://www.firetrucksunlimited.com/wp-content/uploads/web-header-logo-print.jpg" /></div></div>  </div></section> '+
						'</div><header class="site-header" itemscope itemtype="https://schema.org/WPHeader"><div class="wrap"><div class="title-area"><h1 class="site-title" itemprop="headline"><a href="http://www.firetrucksunlimited.com/">Firetrucks Unlimited</a></h1><p class="site-description" itemprop="description">Fire Trucks For Sale | Fire Apparatus Services</p></div><div class="widget-area header-widget-area"><section id="nav_menu-4" class="widget widget_nav_menu"><div class="widget-wrap"><nav class="nav-header" itemscope itemtype="https://schema.org/SiteNavigationElement"><ul id="menu-main" class="menu genesis-nav-menu"><li id="menu-item-28564" class="menu-item menu-item-type-custom menu-item-object-custom current-menu-item current_page_item menu-item-home menu-item-28564"><a href="http://www.firetrucksunlimited.com" itemprop="url"><span itemprop="name">Home</span></a></li> '+
						'<li id="menu-item-19763" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-has-children menu-item-19763"><a href="http://www.firetrucksunlimited.com/fire-truck-service/" itemprop="url"><span itemprop="name">Services</span></a>' +
						'<ul class="sub-menu"> <li id="menu-item-19764" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-19764"><a href="http://www.firetrucksunlimited.com/fire-truck-refurbishment/" itemprop="url"><span itemprop="name">Fire Truck Refurbishment</span></a></li> <li id="menu-item-19765" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-19765"><a href="http://www.firetrucksunlimited.com/ambulance-remounts/" itemprop="url"><span itemprop="name">Ambulance Remounts</span></a></li> '+
						'<li id="menu-item-33806" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-33806"><a href="http://www.firetrucksunlimited.com/fire-truck-repair/" itemprop="url"><span itemprop="name">Service &#038; Repairs</span></a></li> </ul> </li>' +
						'<li id="menu-item-19752" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-has-children menu-item-19752"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/" itemprop="url"><span itemprop="name">Fire Trucks For Sale</span></a> <ul class="sub-menu"> <li id="menu-item-19753" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-has-children menu-item-19753"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/" itemprop="url"><span itemprop="name">Used Fire Trucks For Sale</span></a> '+
						'<ul class="sub-menu"> <li id="menu-item-19754" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-19754"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/used-fire-engines-pumper-trucks/" itemprop="url"><span itemprop="name">Engines &#038; Pumpers</span></a></li> <li id="menu-item-19755" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-19755"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/used-ladder-trucks-aerials-sale/" itemprop="url"><span itemprop="name">Aerials &#038; Ladders</span></a></li> <li id="menu-item-19757" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-19757"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/used-fire-tankers-tenders-sale/" itemprop="url"><span itemprop="name">Tankers &#038; Tenders</span></a></li>'+
                        '<li id="menu-item-19756" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-19756"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/used-ambulances-rescue-vehicles-sale/" itemprop="url"><span itemprop="name">Rescues &#038; Ambulances</span></a></li> <li id="menu-item-19758" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-19758"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/used-wildland-vehicles-sale/" itemprop="url"><span itemprop="name">Brush Trucks</span></a></li> <li id="menu-item-24891" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-24891"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/used-command-vehicles-sale/" itemprop="url"><span itemprop="name">Command Vehicles</span></a></li> <li id="menu-item-19759" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-19759"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/used-oshkosh-trucks-arff-vehicle-sale/" itemprop="url"><span itemprop="name">ARFF</span></a></li>' +
                         '<li id="menu-item-30769" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-30769"><a href="http://www.firetrucksunlimited.com/used-fire-trucks-for-sale/other-vehicles/" itemprop="url"><span itemprop="name">Other Vehicles</span></a></li> <li id="menu-item-20160" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-20160"><a href="http://www.firetrucksunlimited.com/firetrucks-unlimited-certified/" itemprop="url"><span itemprop="name">FTU Certified Trucks</span></a></li> </ul> </li> </header><div class="site-inner"><div class="content-sidebar-wrap"><main class="content"><div class="home-odd home-section-1 widget-area"><div class="wrap"><section id="text-21" class="widget widget_text"><div class="widget-wrap"><h4 class="widget-title widgettitle">The Apparatus Services and Equipment You Need at a Price You Can Afford.</h4>  <div class="textwidget"><div class="two-thirds first alignleft"> ' +
                         '<h2>Fire Truck Refurbishment</h2> <p>Refurbishment saves you money and gives your truck a second life! You choose which upgrade and repair options meet your specific needs. Refurbs cost up to 60% less than buying new and extend the life of your truck 10+ years.</p> <p><a class="button homebutton" href="/fire-truck-refurbishment/">Learn More About Refurbs</a></p> </div> <div class="one-third"><a href="/fire-truck-refurbishment/"><img class="alignnone size-full wp-image-31642" src="http://www.firetrucksunlimited.com/wp-content/uploads/fire-truck-refurbishment-thumb.jpg" alt="Fire Truck Refurbishment" width="417" height="275" /></a></div> <div class="clearfix"></div> </div> </div></section> </div></div><div class="home-even home-section-2 widget-area"><div class="wrap"><section id="text-23" class="widget widget_text"><div class="widget-wrap"><h4 class="widget-title widgettitle">Used Fire Trucks For Sale</h4> <div class="textwidget">Our certified pre-owned fire apparatus can be modified in any way to meet your needs. If you don\'t see the truck you are looking for, <a href="/buying-used-fire-truck/">contact us</a> and we will find the truck you need!'+
						'<br /> <div class="one-third first "> <a href="/used-fire-engines-pumper-trucks/"><img src="/wp-content/uploads/used-pumpers.jpg" alt="Used Pumpers" width="300" height="178" /><br /> Pumpers</a></div> <div class="one-third"> <a href="/used-ladder-trucks-aerials-sale/"><img src="/wp-content/uploads/used-aerials.jpg" alt="Used Aerials" width="300" height="178" /><br /> Aerials</a></div> <div class="one-third"> <a href="/used-ambulances-rescue-vehicles-sale/"><img src="/wp-content/uploads/used-rescues.jpg" alt="Used Rescue Trucks" width="300" height="178" /><br /> Rescues </a></div> <div class="one-third first"> <a href="/used-fire-trucks-for-sale/used-fire-tankers-tenders-sale"><img src="/wp-content/uploads/used-water-tankers.jpg" alt="Used Water Tankers" width="300" height="178"  /><br /> Tankers </a></div> <div class="one-third"> <a href="/used-wildland-vehicles-sale/"><img src="/wp-content/uploads/used-wildland.jpg" alt="Used Wildland Vehicles" width="300" height="178"  /><br /> Wildland </a></div> <br /> <div class="one-third "> <a href="/used-oshkosh-trucks-arff-vehicle-sale/"><img  src="/wp-content/uploads/used-arff.jpg" alt="Used Oshkosh ARFF" width="300" height="178" /><br /> ARFF </a></div> <div class="clearfix"></div>'+  
                         'a href="/used-fire-trucks-for-sale/" class="fortypxbuffer  button  homebutton">Used Fire Trucks For Sale</a> </div> </div></section> </div></div><div class="home-odd home-section-3 widget-area"><div class="wrap"><section id="text-24" class="widget widget_text"><div class="widget-wrap"><h4 class="widget-title widgettitle">REBEL Brush Trucks</h4> <div class="textwidget">When lives are on the line, you need equipment you can count on. REBEL brush trucks are the perfect solution for quick response  situations and can be customized in any way to meet your needs. <br /> <img src="/wp-content/uploads/custom-brush-trucks.jpg" alt="REBEL Type 6 Brush Trucks" width="450" height="200" /> <br /> <a href="/brush-trucks-type-6-wildland-fire-apparatus/" class="button  homebutton" >Customize Your Truck</a></div> </div></section> </div></div><div class="home-even home-section-4 widget-area"><div class="wrap"><section id="text-25" class="widget widget_text"><div class="widget-wrap"><h4 class="widget-title widgettitle">Ambulance Remounts</h4> <div class="textwidget">Why discard the patient module on your ambulance when all you really need is a new chassis? Our remount service gives your patient module a second life and costs much less than buying new. <br /> <img src="/wp-content/uploads/ambulance-remount-before.jpg" alt="Before Ambulance Remount" width="352" height="200"  /><img src="/wp-content/uploads/ambulance-remount-after.jpg" alt="After Ambulance Remount" width="348" height="200"  /> <br />'+
						'<a href="/ambulance-remounts/" class="button  homebutton">Learn More About Ambulance Remounts</a></div> </div></section> </div></div><div class="home-odd home-section-5 widget-area"><div class="wrap"><section id="text-26" class="widget widget_text"><div class="widget-wrap"><h4 class="widget-title widgettitle">Completed Projects</h4> <div class="textwidget"><p>We have completed hundreds of projects and provide our customers with complete photo archives of the work performed. Take a look at our photo galleries to see what Firetrucks Unlimited can do for you!</p> <div class="clearfix completedprjpic"></div> <div class="one-fourth first completedprjpic"><a href="/pumper-photos/"><img src="/wp-content/uploads/refurbished-pumper.jpg" alt="refurbished-pumper" width="300" height="200" /></p> <p>Pumpers</a></div> <div class="one-fourth completedprjpic"><a href="/ladder-truck-photos/"><img src="/wp-content/uploads/refurbished-aerial.jpg" alt="refurbished-aerial" width="300" height="200" /></p> <p>Aerials</a></div> '+
                         '<div class="one-fourth completedprjpic"><a href="/wildland-truck-photos/"><img src="/wp-content/uploads/rebel-brush-truck.jpg" alt="rebel-brush-truck" width="300" height="200" /></p> <p>Wildland</a></div> <div class="one-fourth completedprjpic"><a href="/rescue-truck-photos/"><img src="/wp-content/uploads/refurbished-rescue.jpg" alt="refurbished-rescue" width="300" height="200" /></p> <p>Rescues</a></div> <div class="one-fourth first completedprjpic"><a href="/ambulance-remount-photos/"><img src="/wp-content/uploads/ambulance-remounted.jpg" alt="ambulance-remounted" width="300" height="200" /></p> <p>Ambulance Remounts</a></div> <div class="one-fourth completedprjpic"><a href="/tanker-truck-photos/"><img src="/wp-content/uploads/refubished-water-tanker.jpg" alt="refubished-water-tanker" width="300" height="200" /></p> <p>Tankers</a></div> <div class="one-fourth completedprjpic"><a href="/arff-truck-photos/"><img src="/wp-content/uploads/rebuilt-arff.jpg" alt="rebuilt-arff" width="300" height="200" /></p> <p>ARFF</a></div> <div class="one-fourth completedprjpic"><a href="/emergency-lighting-photos/"><img src="/wp-content/uploads/lighting-upfit.jpg" alt="lighting-upfit" width="300" height="200" /></p> <p>Lighting Upfits</a></div> '+
						'<div class="clearfix"></div> <div class="clearfix"></div> <p><a class="fortypxbuffer button homebutton" href="/work-in-progress/">Check Out the Work in Progress</a></p> </div> </div></section> </div></div></main></div></div><div class="footer-widgets"><div class="wrap"><div class="widget-area footer-widgets-1 footer-widget-area"><section id="text-44" class="widget widget_text"><div class="widget-wrap"><h4 class="widget-title widgettitle">Used Fire Truck Finder</h4> <div class="textwidget"><img src="http://www.firetrucksunlimited.com/wp-content/uploads/fire-truck-finder2.jpg" alt="Fire Truck Finder" width="350" height="162" class="alignleft size-full wp-image-33956" />Don\'t see the used fire trucks for sale you need in our inventory? Let us know what you are looking for and our team will find the truck you need through our connections with other dealers. You\'ll also receive updates when we add used fire trucks to our inventory that match your needs! <br /><br /> <strong><a  href="http://www.firetrucksunlimited.com/buying-used-fire-truck/">Use the Fire Truck Finder Now</a></strong> </div> </div></section> <section id="featured-post-7" class="widget featured-content featuredpost"><div class="widget-wrap"><h4 class="widget-title widgettitle">Latest News</h4> <article class="post-73396 post type-post status-publish format-standard has-post-thumbnail category-news entry"><a href="http://www.firetrucksunlimited.com/refurbished-engine-helps-stretch-bhcfds-money-mohave-valley-daily-news/" class="alignleft" aria-hidden="true"><img width="300" height="200" src="http://www.firetrucksunlimited.com/wp-content/uploads/59ba315c4c1cc.image_-300x200.jpg" class="entry-image attachment-post" alt="&#8220;Refurbished engine helps stretch BHCFD’s money&#8221; Mohave Valley Daily News" itemprop="image" srcset="http://www.firetrucksunlimited.com/wp-content/uploads/59ba315c4c1cc.image_-300x200.jpg 300w, http://www.firetrucksunlimited.com/wp-content/uploads/59ba315c4c1cc.image_.jpg 360w" sizes="(max-width: 300px) 100vw, 300px" /></a><header class="entry-header"><h2 class="entry-title" itemprop="headline"><a href="http://www.firetrucksunlimited.com/refurbished-engine-helps-stretch-bhcfds-money-mohave-valley-daily-news/">&#8220;Refurbished engine helps stretch BHCFD’s money&#8221; Mohave Valley Daily News</a></h2></header><div class="entry-content"><p>“Use it up, wear it out, make it do, or do without.” —&nbsp; Boyd K. Packer'+'BULLHEAD CITY — The Bullhead City Fire Department simply does not have the latter option, when it comes to fire engines. But with the cost of a new engine at about $600,000 and the fund from which such apparatus would be paid for looking meager, department leaders had to search for another way to meet that &#x02026; <a href="http://www.firetrucksunlimited.com/refurbished-engine-helps-stretch-bhcfds-money-mohave-valley-daily-news/" class="more-link">[Read More]</a></p></div></article></div></section> <section id="text-43" class="widget widget_text"><div class="widget-wrap">	<div class="textwidget"><div class="footernav"> <h3>Services</h3> <a href="/fire-truck-refurbishment/">Fire Truck Refurbishment</a><br /> <a href="/ambulance-remounts/">Ambulance Remounts</a><br /> <a href="/fire-truck-repair/">Service & Repairs</a> </div> <div class="footernav"> <h3>Fire Trucks For Sale</h3> <a href="/used-fire-trucks-for-sale/">Used Fire Trucks For Sale</a><br /> <a href="/brush-trucks-type-6-wildland-fire-apparatus/">REBEL Brush Trucks</a><br />'+
                         '<a href="/sell-fire-truck/">Sell a Used Fire Truck</a> </div> <div class="footernav"> <h3>Equipment</h3> <a href="/fire-fighting-equipment/">New Equipment & Parts</a><br /> <a href="/used-fire-truck-equipment/">Used Fire Equipment</a> </div> <div class="footernav"  id="footernav4"> <h3>Photos</h3> <a href="/work-in-progress/">Work in Progress</a><br /> <a href="/completed-fire-truck-photos/">Completed Projects</a> </div> <div class="footernav"> <h3>About FTU</h3> <a href="/contact-firetrucks-unlimited/">Contact Us</a><br /> <a href="/about-firetrucks-unlimited/">About Us</a><br /> <a href="/news/">Latest News</a><br /> <a href="/job-opportunites/">Jobs</a><br /> <a href="/privacy-policy/">Privacy Policy</a> </div> <div class="clearfix"></div> <div class="footerlogos"> <a href="http://www.evtcc.org/" target="_blank"><img src="/wp-content/uploads/EVT-Logo.png" alt="Emergency Vehicle Technician" width="191" height="142" class="alignnone size-full wp-image-15349" /></a><a href="http://www.fama.org/" target="_blank"><img src="/wp-content/uploads/FAMA-Logo.png" alt="Memebr of the Fire Apapratus Manufacturers Association" width="262" height="141" class="alignnone size-full wp-image-15348" /></a> </div> </div> </div></section> </div></div></div><footer class="site-footer" itemscope itemtype="https://schema.org/WPFooter"><div class="wrap"><div class="creds"><p>Copyright &copy; 2018 &middot; <a href="http://www.FiretrucksUnlimited.com">Firetrucks Unlimited</a><br /><a href="http://www.firetrucksunlimited.com/sitemap/">Sitemap</a></p></div><p></p></div></footer></div> </body></html> }' );                        response.setStatusCode(301);
        return response; 	
	} 

	public HTTPResponse getResponse3(){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type',  'application/json');
        response.setBody('{<div class="btn-group"> <li> Page1 </li> </div> <div class="col-md-4 col-sm-6"> Sample Test Truck1 href="www.testgoogle.com" </div>}');
        response.setStatusCode(301);
        response.setHeader('Location', 'fenton');
        return response; 
    }

    public HTTPResponse getResponse4(){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type',  'application/json');
        response.setBody('{<div> <h2>Dimensions</h2> Mileage: 80 <br /> <ul class="listing_details"> <li> Price: <div> $7500 </div> </li> category/ MH ?  </div>');
        response.setStatusCode(301);
        response.setHeader('Location', 'FentonTruck');
        return response; 
    }  
    
    public HTTPResponse getResponse5(){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type',  'application/json');
        response.setBody('{<div class="col-md-4 col-sm-6"> Sample Test Truck1 href="www.testgoogle.com" category/ TATA ? </div>}'+
                        '<div class="col-md-4 col-sm-6"> Sample Test Truck2 href="www.testgooglescholar.com" category/ FOX ? </div>');
        response.setStatusCode(301);
        response.setHeader('Location', 'MockTest');
        return response; 
    }  
    
    public HTTPResponse getResponse6(){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type',  'application/json');
        //response.setBody('{<div> <h2>Dimensions</h2> Mileage: 80 <br /> <ul class="listing_details"> <li> Price: <div> $7500 </div> </li> href="Test fenton" </div>}');
        response.setBody('<div class="col-md-4 col-sm-6"> Sample Test Truck1 href="www.testgoogle.com" category/ FOX ? </div>}');
                        //'<div class="col-md-4 col-sm-6"> Sample Test Truck2 href="www.testgooglescholar.com" category/ </div>');
        response.setStatusCode(301);
        //response.setHeader('Location', 'MockTest');
        return response; 
    } 
    
    public HTTPResponse getResponse7(){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type',  'application/json');
        response.setBody('{<div> Test sample fenton truck </div>}');
        //response.setBody('{<div> <h2>Dimensions</h2> Mileage: 80 <br /> <ul class="listing_details"> <li> Price: <div> $7500 </div> </li> href="Test fenton" </div>}');
        //response.setBody('<div class="col-md-4 col-sm-6"> Sample Test Truck1 href="www.testgooglescholar.com" category/ </div>}');
                        //'<div class="col-md-4 col-sm-6"> Sample Test Truck2 href="www.testgooglescholar.com" category/ </div>');
        response.setStatusCode(301);
        response.setHeader('Location', 'MockFenton');
        return response; 
    }  
    
    public HTTPResponse getResponse8(){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type',  'application/json');
        response.setBody('{<div> <h2>Dimensions</h2> Mileage: 80 <br /> <ul class="listing_details"> <li> Price: <div> $7500 </div> </li> href="Test fenton" </div>}');
        //response.setBody('<div class="col-md-4 col-sm-6"> Sample Test Truck1 href="www.testgooglescholar.com" category/ </div>}');
                        //'<div class="col-md-4 col-sm-6"> Sample Test Truck2 href="www.testgooglescholar.com" category/ </div>');
        response.setStatusCode(301);
        //response.setHeader('Location', 'MockFenton');
        return response; 
    }  
}