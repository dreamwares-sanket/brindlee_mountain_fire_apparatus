/**
*@Purpose : Helper class having generic methods which are used while parsing data from different sites
*@Date : 22/05/2018
*/
public class SiteCalloutHelper{
     
     public static HTTPResponse getHtmlBody(String endPoint){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306){
            
            String loc = res.getHeader('Location');
            req = new HttpRequest();
            req.setEndpoint(loc);
            req.setMethod('GET');
            res = http .send(req);
        }
        return res;
    }
    
    public static String getReplaceString(String tempStr, Boolean hasUnNecessaryChar){
    
        if(String.isNotBlank(tempStr)){
            
            tempStr = tempStr.replaceAll('&#039;', '\'').replaceAll('&quot;','"').replaceAll('&#215;','X').trim();
            tempStr = tempStr.replaceAll( '&#8242;', '' ).replaceAll( '&#8211;', '' );
            tempStr = hasUnNecessaryChar == true ? removeUnnecessaryCharacters(tempStr) : tempStr;                
            
            return tempStr;
        }
        return '';    
    }
    
    public static String removeUnnecessaryCharacters(String tempStr){
    
        if(String.isNotBlank(tempStr)){
            
            tempStr = tempStr.remove(':').remove(',').remove('_').remove('-').remove('$')
                      .remove('</strong').remove('</li').remove('</div').remove('</span').remove('</h1').remove('</h2').remove('>').trim(); 
            tempStr = String.isNotBlank(tempStr) ? 
                      tempStr.remove('<strong').remove('<li').remove('<div').remove('<span').remove('<h1').remove('<h2') :
                      tempStr;
                       
            return tempStr;
        }
        return '';    
    }
    
    public static String getSplitValue(String tempString, String reg, String indexStr){
        
        if(String.isnotBlank(tempString) && String.isnotEmpty(reg)){            
            
            List<String> tempStrList = tempString.trim().split(reg);
            Integer listSize = tempStrList.size();
            
            Integer index = String.isNotBlank(indexStr) && indexStr.equalsIgnoreCase('last') ? 
                            listSize > 0 ? listSize - 1: 0 :
                            String.isNotBlank(indexStr) ? Integer.valueOf(indexStr) : 0;
            
            return tempStrList[index];            
        }
        return '';
    }
}