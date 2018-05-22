/**
 * @Purpose            : Controller class for VF Component : PrintCheckPDF
 * @Author             : Dreamwares 
 * @Created Date 	   : 02/05/2018
 * @Last Modified Date : 16/05/2018
 */ 
public class ControllerPrintCheck {
    public String cashDisbursementId  {get;  set;}
    public Id cashDisbursementBatchId { get;  set;}
    
    public List<AcctSeed__Cash_Disbursement__c> cashDisbursementList  {get;  set;}
    public List<CashDisbursementDTO> cashDisbursementWrapperList  {get;  set;}
    
    public Integer DateTopOffset  {get;  set;}
    public Integer DateRightOffset  {get;  set;}
    public Integer AmountTopOffset  {get;  set;}
    public Integer AmountRightOffset  {get;  set;}
    public Integer AmountWordsTopOffset  {get;  set;}
    public Integer AmountWordsLeftOffset  {get;  set;}
    public Integer PayeeTopOffset  {get;  set;}
    public Integer PayeeLeftOffset  {get;  set;}
    public Integer PayeeAddressTopOffset  {get;  set;}
    public Integer PayeeAddressLeftOffset  {get;  set;}
    public Integer MemoTopOffset  {get;  set;}
    public Integer MemoLeftOffset  {get;  set;}
    
    //Constructor
    public ControllerPrintCheck(){
        this.cashDisbursementList = new List<AcctSeed__Cash_Disbursement__c>();
        this.cashDisbursementId = ApexPages.currentPage().getParameters().get('id');
		this.cashDisbursementWrapperList = new List<CashDisbursementDTO>();
        this.DateTopOffset = 50;
        this.DateRightOffset = 80;
        this.AmountTopOffset = 50;
        this.AmountRightOffset = 80;
        this.AmountWordsTopOffset = 80;
        this.AmountWordsLeftOffset = 90;
        this.PayeeTopOffset = 100;
        this.PayeeLeftOffset = 60;
        this.PayeeAddressTopOffset = 110;
        this.PayeeAddressLeftOffset = 30;
        this.MemoTopOffset = 100;
        this.MemoLeftOffset = 20;
            
        getCashDisbursements();
        getCashDisbursementDTOList();
    }
    
    /**
     * @Purpose : Method to get Cash Disbursement records
     */
    public void getCashDisbursements(){
                
        if (String.isNotBlank(cashDisbursementBatchId)){
            System.debug('In getCashDisbursements, cashDisbursementBatchId');
            
            try{
                //Fetch Cash Disbursement
                cashDisbursementList = [SELECT Id, Name, AcctSeed__Payee__c, AcctSeed__Amount__c, AcctSeed__Amount_in_Words__c 
                                        FROM AcctSeed__Cash_Disbursement__c
                                        WHERE AcctSeed__Cash_Disbursement_Batch__c =: cashDisbursementBatchId];
                System.debug('cashDisbursementWrapperList::'+cashDisbursementWrapperList);
            }catch(Exception e){
                System.debug('Exception occured at line number :'+e.getLineNumber()+ ' and error is :'+e.getMessage());
            }
        }else{
            System.debug('cashDisbursementId::'+cashDisbursementId);
            
            //add current Cash Disbursement to list
            if (String.isNotBlank(cashDisbursementId)){
                AcctSeed__Cash_Disbursement__c cashDisbursement = new AcctSeed__Cash_Disbursement__c();
                
                try{
                    cashDisbursement = [SELECT Id, Name, AcctSeed__Check_Number__c, AcctSeed__Disbursement_Date__c,
                                        AcctSeed__Ledger_Amount__c, AcctSeed__Payee__c, AcctSeed__Amount__c, AcctSeed__Amount_in_Words__c,
                                        AcctSeed__Payee_Street__c , AcctSeed__Payee_State__c, AcctSeed__Payee_Country__c, AcctSeed__Payee_City__c,
                                        AcctSeed__Payee_City_State_Zip__c, AcctSeed__Memo__c 
                                        FROM AcctSeed__Cash_Disbursement__c
                                        WHERE Id =: cashDisbursementId];
                    System.debug('cashDisbursement::'+cashDisbursement);
                }catch(Exception e){
                    System.debug('Exception occured at line number :'+e.getLineNumber()+ ' and error is :'+e.getMessage());
                }
                
                if (cashDisbursement != null){
                    cashDisbursementList.add(cashDisbursement);
                }
            }
        }
    }
    
    /**
     * @Purpose : Method to get DTO list
     */
    public void getCashDisbursementDTOList(){
        
        Set<Id> cashDisbursementIdSet = new Set<Id>();
        List<AcctSeed__AP_Disbursement__c> apDisbursementList = new List<AcctSeed__AP_Disbursement__c>();
        
        if (!cashDisbursementList.isEmpty()){
            for (AcctSeed__Cash_Disbursement__c cashDisbursement : cashDisbursementList){
            	cashDisbursementIdSet.add(cashDisbursement.Id);
            }
            
            if (!cashDisbursementIdSet.isEmpty()){
                //Fetch AP Disbursements
                try{
                    apDisbursementList = [SELECT Id, AcctSeed__Account_Payable__c, AcctSeed__Cash_Disbursement__c, 
                                         AcctSeed__Account_Payable__r.AcctSeed__Net_Amount__c,
                                         AcctSeed__Account_Payable__r.AcctSeed__Date__c, 
                                         AcctSeed__Account_Payable__r.Name,
                                         AcctSeed__Account_Payable__r.AcctSeed__Payee_Reference__c, 
                                         AcctSeed__Account_Payable__r.AcctSeed__Total__c, 
                                         AcctSeed__Account_Payable__r.AcctSeed__Proprietary_Payable_Number__c,
                                         AcctSeed__Account_Payable__r.AcctSeed__Type__c,
                                         AcctSeed__Account_Payable__r.AcctSeed__Discount_Amount__c,
                                         AcctSeed__Account_Payable__r.AcctSeed__Credit_Memo_Applied_Amount__c,
                                         AcctSeed__Paid_Amount__c
                                         FROM AcctSeed__AP_Disbursement__c
                                         WHERE AcctSeed__Cash_Disbursement__c IN : cashDisbursementIdSet
                                         ORDER BY AcctSeed__Account_Payable__r.AcctSeed__Date__c, AcctSeed__Account_Payable__r.Name];
                    System.debug('apDisbursementList::'+apDisbursementList);
                }catch(Exception e){
                	System.debug('Exception occured at line number :'+e.getLineNumber()+ ' and error is :'+e.getMessage());
            	}
            }
            
            for (AcctSeed__Cash_Disbursement__c cashDisbursement : cashDisbursementList){
                CashDisbursementDTO wrapper = new CashDisbursementDTO();
                wrapper.cashDisbursement = cashDisbursement;
                List<RemittanceDTO> remittances = new List<RemittanceDTO>();
                
                for (AcctSeed__AP_Disbursement__c apDisburse : apDisbursementList){
                    if (apDisburse.AcctSeed__Cash_Disbursement__c == cashDisbursement.Id){
                        AcctSeed__Account_Payable__c accountPayable = apDisburse.AcctSeed__Account_Payable__r;
                        RemittanceDTO remittanceWrapper = new RemittanceDTO();
                        
                        if (accountPayable != null){
                        	remittanceWrapper.accountPayable = accountPayable;
                            remittanceWrapper.amount = Integer.valueOf(apDisburse.AcctSeed__Paid_Amount__c);
                            remittances.add(remittanceWrapper);
                        }
                    }
                }
                
                if (!remittances.isEmpty()){
                    wrapper.remittances = remittances;
                }
                
                cashDisbursementWrapperList.add(wrapper);
            }
            
            System.debug('cashDisbursementWrapperList::'+cashDisbursementWrapperList);
        }else{
            System.debug('Cash disbursement list is empty!!');
        }
    }
}