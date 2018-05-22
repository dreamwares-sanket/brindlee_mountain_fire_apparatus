/**
 * @Purpose      : Wrapper class for CashDisbursementDTO
 * @Author       : Dreamwares 
 * @Created Date : 02/05/2018
 */ 
public class CashDisbursementDTO {
    public List<RemittanceDTO> remittances {get; set;}
    public AcctSeed__Cash_Disbursement__c cashDisbursement {get; set;}
    
    //Constructor
    public CashDisbursementDTO(){
        this.remittances = new List<RemittanceDTO>();
        this.cashDisbursement = new AcctSeed__Cash_Disbursement__c();
    }

}