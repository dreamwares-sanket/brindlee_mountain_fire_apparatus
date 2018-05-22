/**
 *  @className  PlatformCacheController 
 *  @createdBy  Dreamwares[Amol k]
 *  @createdOn  28 May 2016
 *  @purpose  control the flow of data from cache 
 */

public class PlatformCacheController {
    
    // @purpose : craeate Platform cache of list records    
    public  void creaetPlatformCahche(List<SObject>listRecordsToPutOnCache, String strCacheName){       
        if (listRecordsToPutOnCache!= null && strCacheName!= null)
        {
            try{ 
                Schema.SObjectType sObjectType = listRecordsToPutOnCache.getSObjectType();
                if (sObjectType != null){
                    String listType = 'List<' + sObjectType + '>';
                    List<SObject> listRecordsToCache= (List<SObject>)Type.forName(listType).newInstance();
                    Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.part1'); // get org partition from platform cache 
                    if( orgPartition != null
                       && listRecordsToPutOnCache!= null && !listRecordsToPutOnCache.isEmpty() ) {
                           listRecordsToCache.addAll(listRecordsToPutOnCache);
                           orgPartition.put(strCacheName, listRecordsToCache, 28800);  	// set expiry to 8 Hrs
                       }
                }
            }catch(exception ex){
                System.debug('Error Line:' + ex.getLineNumber() + ' Message: ' + ex.getMessage());
            } 
        }    
    }
    
    // @purpose : get Platform cache of list records    
    public List<SObject> getPlatformCahche(String strSourceCacheName){       
        if (strSourceCacheName != null)
        {
            try { 
                Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.part1');
                if ( orgPartition != null && orgPartition.contains(strSourceCacheName)) {
                    return (List<SObject>)orgPartition.get(strSourceCacheName);
                }                             
            }catch(exception ex){
                System.debug('Error Line:' + ex.getLineNumber() + ' Message: ' + ex.getMessage());
            } 
        }  
        return null;  
    }
    
}