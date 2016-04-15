<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
      
      <link rel="stylesheet" type="text/css" href="/scripts/shadowbox/shadowbox.css"/>
      	<script type="text/javascript" src="/includes_content/nextgen/scripts/jquery/jquery-latest.js"></script>
      <!-- START OF GLOBAL NAV -->

  <link rel="stylesheet" href="/matlabcentral/css/sitewide.css" type="text/css">
  <link rel="stylesheet" href="/matlabcentral/css/mlc.css" type="text/css">
  <!--[if lt IE 7]>
  <link href="/matlabcentral/css/ie6down.css" type="text/css" rel="stylesheet">
  <![endif]-->

      
      
      
      <meta http-equiv="content-type" content="text/html; charset=UTF-8">
<meta name="keywords" content="file exchange, matlab answers, newsgroup access, link exchange, matlab blog, matlab central, simulink blog, matlab community, matlab and simulink community">
<meta name="description" content="File exchange, MATLAB Answers, newsgroup access, Links, and Blogs for the MATLAB &amp; Simulink user community">
<link rel="stylesheet" href="/matlabcentral/css/fileexchange.css" type="text/css">
<link rel="stylesheet" type="text/css" media="print" href="/matlabcentral/css/print.css" />
<title> File Exchange - MATLAB Central</title>
<script src="/matlabcentral/fileexchange/assets/application.js" type="text/javascript"></script>
<link href="/matlabcentral/fileexchange/assets/application.css" media="screen" rel="stylesheet" type="text/css" />
<link href="/matlabcentral/fileexchange/assets/profile_link/application.css" media="all" rel="stylesheet" type="text/css" />
<link href="/includes_content/responsive/fonts/mw_font.css" media="all" rel="stylesheet" type="text/css" />
<script src="/matlabcentral/fileexchange/assets/profile_link/application.js" type="text/javascript"></script>
<link href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/ridiffci.m" rel="canonical" />


<link rel="search" type="application/opensearchdescription+xml" title="Search File Exchange" href="/matlabcentral/fileexchange/search.xml" />


<!-- BEGIN Adobe DTM -->
<script src="/scripts/dtm/d0cc0600946eb3957f703b9fe43c3590597a8c2c/satelliteLib-e8d23c2e444abadc572df06537e2def59c01db09.js"></script>
<!-- END Adobe DTM -->  </head>
    <body>
      <div id="header" class="site6-header">
  <div class="wrapper">
  <!--put nothing in left div - only 11px wide shadow --> 
    <div class="main">
        <div id="headertools">      


<script language="JavaScript1.3" type="text/javascript">

function submitForm(query){

	choice = document.forms['searchForm'].elements['search_submit'].value;
	
	if (choice == "entire1" || choice == "contest" || choice == "matlabcentral" || choice == "blogs"){
	
	   var newElem = document.createElement("input");
	   newElem.type = "hidden";
	   newElem.name = "q";
	   newElem.value = query.value;
	   document.forms['searchForm'].appendChild(newElem);
	      
	   submit_action = '/search/site_search.html';
	}
	
	switch(choice){
	   case "matlabcentral":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "c[]";
	      newElem.value = "matlabcentral";
	      document.forms['searchForm'].appendChild(newElem);
	
	      selected_index = 0;
	      break
	   case "fileexchange":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "term";
	      newElem.value = query.value;
	      newElem.classname = "formelem";
	      document.forms['searchForm'].appendChild(newElem);
	
	      submit_action = "/matlabcentral/fileexchange/";
	      selected_index = 1;
	      break
	   case "answers":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "term";
	      newElem.value = query.value;
	      newElem.classname = "formelem";
	      document.forms['searchForm'].appendChild(newElem);
	
	      submit_action = "/matlabcentral/answers/";
	      selected_index = 2;
	      break
	   case "cssm":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "search_string";
	      newElem.value = query.value;
	      newElem.classname = "formelem";
	      document.forms['searchForm'].appendChild(newElem);
	
		  submit_action = "/matlabcentral/newsreader/search_results";
	      selected_index = 3;
	      break
	   case "linkexchange":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "term";
	      newElem.value = query.value;
	      newElem.classname = "formelem";
	      document.forms['searchForm'].appendChild(newElem);
	
	      submit_action = "/matlabcentral/linkexchange/";
	      selected_index = 4;
	      break
	   case "blogs":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "c[]";
	      newElem.value = "blogs";
	      document.forms['searchForm'].appendChild(newElem);
	
	      selected_index = 5;
	      break
	   case "cody":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "term";
	      newElem.value = query.value;
	      newElem.classname = "formelem";
	      document.forms['searchForm'].appendChild(newElem);
	
	      submit_action = "/matlabcentral/cody/";
	      selected_index = 6;
	      break
	   case "contest":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "c[]";
	      newElem.value = "contest";
	      document.forms['searchForm'].appendChild(newElem);
	
	      selected_index = 7;
	      break
	   case "entire1":
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "c[]";
		  newElem.value = "entire_site";
	      document.forms['searchForm'].appendChild(newElem);
	      
	      selected_index = 8;
	      break
	   default:
	      var newElem = document.createElement("input");
	      newElem.type = "hidden";
	      newElem.name = "c[]";
	      newElem.value = "entire_site";
	      document.forms['searchForm'].appendChild(newElem);
	   
	      selected_index = 8;
	      break
	}

	document.forms['searchForm'].elements['search_submit'].selectedIndex = selected_index;
	document.forms['searchForm'].elements['query'].value = query.value;
	document.forms['searchForm'].action = submit_action;
}

</SCRIPT>


  <form name="searchForm" method="GET" action="" style="margin:0px; margin-top:5px; font-size:90%" onSubmit="submitForm(query)">
          <label for="search">Search: </label>
        <select name="search_submit" style="font-size:9px ">
         	 <option value = "matlabcentral">MATLAB Central</option>
          	<option value = "fileexchange" selected>&nbsp;&nbsp;&nbsp;File Exchange</option>
          	<option value = "answers">&nbsp;&nbsp;&nbsp;Answers</option>
            <option value = "cssm">&nbsp;&nbsp;&nbsp;Newsgroup</option>
          	<option value = "linkexchange">&nbsp;&nbsp;&nbsp;Link Exchange</option>
          	<option value = "blogs">&nbsp;&nbsp;&nbsp;Blogs</option>
          	<option value = "cody">&nbsp;&nbsp;&nbsp;Cody</option>
          	<option value = "contest">&nbsp;&nbsp;&nbsp;Contest</option>
          <option value = "entire1">MathWorks.com</option>
        </select>
<input type="text" name="query" size="10" class="formelem" value="">
<input type="submit" value="Go" class="formelem gobutton" >
</form>

      <ol id="access2">
  <li class="first">
    <a href="https://de.mathworks.com/accesslogin/createProfile.do?uri=http%3A%2F%2Fde.mathworks.com%2Fmatlabcentral%2Ffileexchange%2F47235-mstats-a-random-collection-of-statistical-functions%2Fcontent%2Fridiffci.m" id="create_account_link">Create Account</a>
  </li>
  <li>
    <a href="https://de.mathworks.com/accesslogin/index_fe.do?uri=http%3A%2F%2Fde.mathworks.com%2Fmatlabcentral%2Ffileexchange%2F47235-mstats-a-random-collection-of-statistical-functions%2Fcontent%2Fridiffci.m" id="login_link">Log In</a>
  </li>
</ol>


      </div>
        <div class="logo_container hidden-xs hidden-sm">
          <a href="/index.html?s_tid=gn_logo" class="svg_link pull-left">
            <img src="/images/responsive/global/pic-header-mathworks-logo.svg" class="mw_logo" alt="MathWorks">
          </a>
        </div>
        <div id="globalnav">
        <div class="navbar-header">
        <div class="navbar-collapse collapse hidden-xs hidden-sm">
          <ul class="nav navbar-nav" id="topnav">
            <li class="topnav_products "><a href="/products/?s_tid=gn_ps">Products</a></li>
            <li class="topnav_solutions "><a href="/solutions/?s_tid=gn_sol">Solutions</a></li>
            <li class="topnav_academia "><a href="/academia/?s_tid=gn_acad">Academia</a></li>
            <li class="topnav_support "><a href="/support/?s_tid=gn_supp">Support</a></li>
            <li class="topnav_community active"><a href="/matlabcentral/?s_tid=gn_mlc" class="dropdown-toggle"  role="button" aria-haspopup="true" aria-expanded="false">Community</a>
            </li>
            <li class="topnav_events "><a href="/company/events/?s_tid=gn_ev">Events</a></li>
            <li class="topnav_company "><a href="/company/?s_tid=gn_co">Company</a></li>
          </ul>
        </div>
      </div>
        <!-- from includes/global_nav.html -->
        
      </div>
    </div>
  </div>
</div>

      <div id="middle">
  <div class="wrapper">
  	<div class="fileexchange-header">
  		<a href="/matlabcentral/fileexchange/?s_tid=gn_mlc_fx">File Exchange Home</a>
  	</div>

    <div id="mainbody" class="columns2">
  
  

  <div class="manifest">

      <div id="download_zip_button">
            <div class="btnCont ctaBtn ctaBlueBtn btnSmall">
              <div class="btn download"><a href="https://de.mathworks.com/accesslogin/index_fe.do?uri=http%3A%2F%2Fde.mathworks.com%2Fmatlabcentral%2Ffileexchange%2F47235-mstats-a-random-collection-of-statistical-functions%2Fcontent%2Fridiffci.m" class="link--download" data-file-format="zip" data-logintodownload="true" title="Download Now">Download Zip</a></div>
            </div>
          </div>

      <p class="license">
      Code covered by the <a href="/matlabcentral/fileexchange/view_license?file_info_id=47235" popup="new_window height=500,width=640,scrollbars=yes">BSD License</a>
      <a href="/matlabcentral/fileexchange/help_license#bsd" class="info notext preview_help" onclick="window.open(this.href,'small','toolbar=no,resizable=yes,status=yes,menu=no,scrollbars=yes,width=600,height=550');return false;">&nbsp;</a>
  </p>



  
  <h3 class="highlights_title">Highlights from <br/>
    <a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions" class="manifest_title">MSTATS - a random collection of statistical functions</a>
  </h3>
  <ul class='manifest'>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/binocof.m" class="function" title="Function">binocof.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/binoform.m" class="function" title="Function">binoform.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/cell2vectors.m" class="function" title="Function">cell2vectors.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/fishertest.m" class="function" title="Function">fishertest.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/rci.m" class="function" title="Function">rci.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/sep.m" class="function" title="Function">sep.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/ridiffci.m" class="function" title="Function">ridiffci.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/sem.m" class="function" title="Function">sem.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/semipartialcorr.m" class="function" title="Function">semipartialcorr.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/rddiffci.m" class="function" title="Function">rddiffci.m</a></li>
      <li class='manifest'><a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/content/test_mstat_funcs.m" class="script" title="Script">test_mstat_funcs.m</a></li>
    <li class="manifest_allfiles">
      <a href="http://de.mathworks.com/matlabcentral/fileexchange/47235-mstats-a-random-collection-of-statistical-functions/all_files" id="view_all_files">View all files</a>
    </li>
  </ul>

</div>


  <table cellpadding="0" cellspacing="0" class="details file contents">
    <tr>
      <th class="maininfo">
        
  <div id="thumbnail" style="padding-bottom: 3px;">
    <a href="/matlabcentral/mlc-downloads/downloads/submissions/47235/versions/2/screenshot.jpg" border="0"><img itemprop="image" src="/responsive_image/150/0/0/0/0/cache/matlabcentral/mlc-downloads/downloads/submissions/47235/versions/2/screenshot.jpg" width=100 alt="image thumbnail"/></a>
  </div>


<div id="details">
  <h1 itemprop="name">MSTATS - a random collection of statistical functions</h1>
  <p id="author">
    by 
    <span itemprop="author" itemscope itemtype="http://schema.org/Person">
      <span itemprop="name"><a href="/matlabcentral/profile/authors/3550885-maik-stuttgen" class="author_inline results_author" data-cp-link-id="1">Maik Stüttgen</a>

<div class="profile mlc_author_popover" data-cp-popup-id="1" vocab="http://schema.org/" typeof="Person">
  <h3 class="profile__name" property="name"><a href="/matlabcentral/profile/authors/3550885-maik-stuttgen">Maik Stüttgen <span>(view profile)</span></a></h3>

    <div class="profile__image">
      <a href="/matlabcentral/profile/authors/3550885-maik-stuttgen"><img src="/matlabcentral/images/profilepic_default.gif" /></a>
    </div>
  <div class="profile__stats" typeof="CreativeWork">
    
  <ul>
    <li property="fileExchange">
      <span class="icon-fileexchange"></span> <a href="/matlabcentral/fileexchange/?term=authorid%3A262160"><span property="fileExchange_count">2</span> files</a>
    </li>
    <li property="downloads">
      <span class="icon-download"></span> <span property="downloads_count">42</span> downloads
    </li>
      <li property="rating">

        <div class="rating" title="5.0">
          <div class="rate_scale">
            <div class="rated" property="aggregateRating" style="width: 100.0%">5.0</div>
          </div>
        </div>

      </li>
  </ul>

  </div>
</div>
</span>
    </span>
  </p>
  <p>&nbsp;</p>
  <p>
    <span id="submissiondate" 
>
      15 Jul 2014
    </span>
      <span id="date_updated">(Updated 
        <span itemprop="datePublished" content="2014-07-18">18 Jul 2014</span>)
      </span>
  </p>

  <p id="summary">Set of functions for statistical analysis</p>


  
</div>

        </div>
      </th>
    </tr>
    <tr>
      <td class="file">
        <table cellpadding="0" cellspacing="0" border="0" class="fileview section">
          <tr class="title">
            <th><span class="heading">ridiffci.m</span></th>
          </tr>
          <tr>
            <td>
              <iframe id="content_iframe" style="width: 100%;min-height: 600px; border: none" onload="initIframe(this.id)" sandbox="allow-popups allow-same-origin " src="/matlabcentral/mlc-downloads/downloads/submissions/47235/versions/2/previews/ridiffci.m/index.html"></iframe>
              <script>
                function getDocHeight(doc) {
                    doc = doc || document;
                    // stackoverflow.com/questions/1145850/
                    var body = doc.body, html = doc.documentElement;
                    var height = Math.max( body.scrollHeight, body.offsetHeight,
                        html.clientHeight, html.scrollHeight, html.offsetHeight );
                    return height;
                }
                function initIframe(id) {
                  var ifrm = document.getElementById(id);
                  var doc = ifrm.contentDocument ? ifrm.contentDocument :
                      ifrm.contentWindow.document;
                  disableAbsoluteLinks(doc);
                  setIframeHeight(ifrm, doc);
                }
                function disableAbsoluteLinks(doc) {
                  $(doc).find('a[href^="http"],a[href^="https"]').attr('target', '_TOP');
                }
                function setIframeHeight(ifrm, doc) {
                    ifrm.style.visibility = 'hidden';
                    ifrm.style.height = "10px"; // reset to minimal height ...
                    // IE opt. for bing/msn needs a bit added or scrollbar appears
                    ifrm.style.height = getDocHeight( doc ) + 25 + "px";
                    ifrm.style.visibility = 'visible';
                }
              </script>
            </td>
          </tr>
        </table>
      </td>
    </tr>

  </table>
  <script src="/matlabcentral/fileexchange/assets/file_infos/show.js" type="text/javascript"></script>

<p id="contactus"><a href="/company/feedback/">Contact us</a></p>

      	
      
</div>
<div class="clearboth">&nbsp;</div>
</div>
</div>
<!-- footer.html -->
<!-- START OF FOOTER -->

<div id="mlc-footer">
  <script type="text/javascript">
function clickDynamic(obj, target_url, tracking_code) {
	var pos=target_url.indexOf("?");
	if (pos<=0) { 
		var linkComponents = target_url + tracking_code;
		obj.href=linkComponents;
	} 
}
</script>
  <div class="wrapper">
    <div>
      <ul id="matlabcentral">
        <li class="copyright first">&copy; 1994-2016 The MathWorks, Inc.</li>
        <li class="first"><a href="/company/aboutus/policies_statements/patents.html?s_tid=gf_pat" title="patents" rel="nofollow">Patents</a></li>
        <li><a href="/company/aboutus/policies_statements/trademarks.html?s_tid=gf_trd" title="trademarks" rel="nofollow">Trademarks</a></li>
        <li><a href="/company/aboutus/policies_statements/?s_tid=gf_priv" title="privacy policy" rel="nofollow">Privacy Policy</a></li>
        <li><a href="/company/aboutus/policies_statements/piracy.html?s_tid=gf_pir" title="preventing piracy" rel="nofollow">Preventing Piracy</a></li>
        <li class="last"><a href="/matlabcentral/termsofuse.html?s_tid=gf_com_trm" title="Terms of Use" rel="nofollow">Terms of Use</a></li>
        <li class="icon"><a href="/company/rss/" title="RSS" class="rssfeed" rel="nofollow"><span class="text">RSS</span></a></li>
        <li class="icon"><a href="/programs/bounce_hub_generic.html?s_tid=mlc_lkd&url=http://www.linkedin.com/company/the-mathworks_2" title="LinkedIn" class="linkedin" rel="nofollow" target="_blank"></a></li>
        <li class="icon"><a href="/programs/bounce_hub_generic.html?s_tid=mlc_fbk&url=https://plus.google.com/117177960465154322866?prsrc=3" title="Google+" class="google" rel="nofollow" target="_blank"><span class="text">Google+</span></a></li>
        <li class="icon"><a href="/programs/bounce_hub_generic.html?s_tid=mlc_fbk&url=http://www.facebook.com/MATLAB" title="Facebook" class="facebook" rel="nofollow" target="_blank"><span class="text">Facebook</span></a></li>
        		<li class="last icon"><a href="/programs/bounce_hub_generic.html?s_tid=mlc_twt&url=http://www.twitter.com/MATLAB" title="Twitter" class="twitter" rel="nofollow" target="_blank"><span class="text">Twitter</span></a></li>        
        
      </ul>
      <ul id="mathworks">
        <li class="first sectionhead">Featured MathWorks.com Topics:</li>
        <li class="first"><a href="/products/new_products/latest_features.html" onclick="clickDynamic(this, this.href, '?s_cid=MLC_new')">New Products</a></li>
        <li><a href="/support/" title="support" onclick="clickDynamic(this, this.href, '?s_cid=MLC_support')">Support</a></li>
        <li><a href="/help" title="documentation" onclick="clickDynamic(this, this.href, '?s_cid=MLC_doc')">Documentation</a></li>
        <li><a href="/services/training/" title="training" onclick="clickDynamic(this, this.href, '?s_cid=MLC_training')">Training</a></li>
        <li><a href="/company/events/webinars/" title="Webinars" onclick="clickDynamic(this, this.href, '?s_cid=MLC_webinars')">Webinars</a></li>
        <li><a href="/company/newsletters/" title="newsletters" onclick="clickDynamic(this, this.href, '?s_cid=MLC_newsletters')">Newsletters</a></li>
        <li><a href="/programs/trials/trial_request.html?prodcode=ML&s_cid=MLC_trials" title="MATLAB Trials">MATLAB Trials</a></li>
        
        		<li class="last"><a href="/company/jobs/opportunities/index_en_US.html" title="Careers" onclick="clickDynamic(this, this.href, '?s_cid=MLC_careers')">Careers</a></li>
                 
      </ul>
    </div>
  </div>
</div>
<!-- END OF FOOTER -->


      
      
<!-- BEGIN Adobe DTM -->
<script type="text/javascript">
try {
_satellite.pageBottom();
} catch (e) {
//something went wrong
}
</script>
<!-- END Adobe DTM -->
  

     

    </body>
</html>
