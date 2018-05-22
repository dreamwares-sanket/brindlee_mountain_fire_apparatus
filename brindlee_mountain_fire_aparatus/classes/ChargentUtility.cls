/*
    Used to perform operatins relaetd to Chargent API
    @author Dreamwares (Aditya S.)
 */
public class ChargentUtility { 
    
    public static TransactionChargeResponse charge(Id chargentOrderId){
        if(String.isNotBlank(chargentOrderId)){
            ChargentOrders.TChargentOperations.TChargentResult result  = ChargentOrders.TChargentOperations.ChargeOrder_Click( chargentOrderId );
            List<String> tmp = result.Message.split('\r\n');
            
            String  transactionStatus, transactionMsg, transactionID, error_message;
            if (tmp.size() == 3) {
                    transactionStatus = tmp[1].substring(tmp[1].indexOf('"') + 1, tmp[1].length() - 1);
                    transactionMsg = tmp[2].substring(tmp[2].indexOf('"') + 1, tmp[2].length() - 1);
                    transactionID = tmp[0].mid(tmp[0].indexOf('(') + 1, tmp[0].indexOf(')') - tmp[0].indexOf('(') - 1);
            } else {
                    transactionStatus = 'UNKNOWN';
                    transactionMsg = 'UNKNOWN Response';
            }
            Boolean isSuccess = transactionStatus != 'Error';
            error_message = isSuccess == false ? transactionMsg : null;
            return new TransactionChargeResponse( transactionID, isSuccess, transactionStatus, error_message );
        }
        return null;
    }
    
    public class TransactionChargeResponse{
        public String transactionId{get; set;}
        public Boolean isSuccess{get; set;}
        public String status{get; set;}
        public String errorMsg{get; set;}
        
        public TransactionChargeResponse(String transactionId, Boolean isSuccess, String status, String errorMsg){
            this.transactionId = transactionId;
            this.isSuccess = isSuccess;
            this.status = status;
            this.errorMsg = errorMsg;
        }        
    }
    
}