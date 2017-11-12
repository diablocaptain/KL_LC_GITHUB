public class CPQ_QuoteControllerExtension {
	private final SBQQ__Quote__c quote;
    
    // The extension constructor initializes the private member
    // variable quote by using the getRecord method from the standard
    // controller.
    public CPQ_QuoteControllerExtension(ApexPages.StandardController stdController) {
        this.quote = (SBQQ__Quote__c)stdController.getRecord();
    }
	
    public List<SBQQ__QuoteLine__c> listMachines {
        get {
            return getMachineQuoteLines(quote.Id);
        }  
        set;
    }
	
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getMachineQuoteLines(String quoteId){
        String fields = getFields(SBQQ__QuoteLine__c.getSObjectType());
        String query = 'SELECT ' + fields + ', CPQ_Quote_Product__r.Name, SBQQ__Group__r.Name FROM SBQQ__QuoteLine__c';
        query += ' WHERE SBQQ__Quote__c = : quoteId And CPQ_Is_Machine__c = true';
        return Database.query(query);
    }
    
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getMachineWithSpecialOptions(String groupId){
        String fields = getFields(SBQQ__QuoteLine__c.getSObjectType());
        String query = 'SELECT ' + fields + ', CPQ_Quote_Product__r.Name, SBQQ__Group__r.Name FROM SBQQ__QuoteLine__c';
        query += ' WHERE SBQQ__Group__c = :groupId AND (CPQ_Is_Machine__c = true OR CPQ_Is_Special_Options__c = true) ORDER BY SBQQ__Number__c ASC NULLS LAST';
        return Database.query(query);
    }
	
	@AuraEnabled
	public static List<CPQ_Payment_Conditions_Detail_Line__c> getPaymentConditions(String machineId){
		String fields = getFields(CPQ_Payment_Conditions_Detail_Line__c.getSObjectType());
		String query = 'SELECT ' + fields + ' FROM CPQ_Payment_Conditions_Detail_Line__c';
		query += ' WHERE CPQ_Terms_and_Conditions__r.CPQ_Quote_Line__c = :machineId ORDER BY CPQ_Sort__c ASC NULLS LAST';
		return Database.query(query);
	}
	
	@AuraEnabled
	public static List<CPQ_Terms_and_Conditions__c> getTermsAndConditions(String machineId){
		String fields = getFields(CPQ_Terms_and_Conditions__c.getSObjectType());
		String query = 'SELECT ' + fields + ' FROM CPQ_Terms_and_Conditions__c';
		query += ' WHERE CPQ_Quote_Line__c = :machineId ORDER BY CPQ_Order_DEV__c ASC NULLS LAST';
		return Database.query(query);
	}
	
	@AuraEnabled
	public static String insertNewTaC(String machineId){
		
		CPQ_Terms_and_Conditions__c tac = new CPQ_Terms_and_Conditions__c();
		tac.CPQ_TaC_Number_Text__c = 'YOHOHO';
		tac.CPQ_Do_not_Print__c = true;
		tac.CPQ_Quote_Line__c = machineId;
		
		
		insert tac;
		return 'SUCCESS';
	}
	
	@AuraEnabled
	public static String insertNewPayCon(String machineId){
		
		//query TAC ID
		String tacId = [SELECT Id FROM CPQ_Terms_and_Conditions__c WHERE CPQ_Quote_Line__c =:machineId AND CPQ_Is_Payment_Condition__c = true LIMIT 1].Id;
		
		CPQ_Payment_Conditions_Detail_Line__c payCon = new CPQ_Payment_Conditions_Detail_Line__c();
		payCon.Z_Text__c = 'Please enter text.';
		payCon.CPQ_Terms_and_Conditions__c = tacId;
		payCon.CPQ_automatically_created__c = true;
		payCon.CPQ_Timestamp__c = datetime.now();
		payCon.CPQ_Sort__c = setSortNumber(new List<CPQ_Payment_Conditions_Detail_Line__c>{payCon}, tacId);
		
		CPQ_Utility.insertRecords(new List<CPQ_Payment_Conditions_Detail_Line__c>{payCon}, 'PAYCON AURA');
		return 'SUCCESS';
	}
	
	private static Decimal setSortNumber(List<CPQ_Payment_Conditions_Detail_Line__c> listPayCon, String tacId){
		
		Set<String> setQuoteIds = CPQ_Utility.returnSet(listPayCon, 'CPQ_Quote_Id__c');
		
		List<AggregateResult> result =[SELECT  MAX(CPQ_Sort__c) max FROM CPQ_Payment_Conditions_Detail_Line__c WHERE CPQ_Terms_and_Conditions__c = :tacId AND CPQ_Sort__c != null];
		
		return (Decimal) result[0].get('max') + 1;
	}
	
	@AuraEnabled
	public static String updateTermsAndConditions(List<CPQ_Terms_and_Conditions__c> tac){
		System.debug(tac[0].CPQ_Do_not_Print__c);
		CPQ_Utility.updateRecords(tac, 'AURA TAC');
		return 'SUCCESS';
	}
    
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getSpecialOptionQuoteLines(String quoteId){
        
        return loadSpecialOptions(quoteId);
    }
    
    private static String getFields(Schema.SObjectType sType) {
        Map<String, Schema.SObjectField> schemaFieldMap = sType.getDescribe().fields.getMap();
        return String.join(new List<String>(schemaFieldMap.keySet()), ',');
    }
    
    private static List<SBQQ__QuoteLine__c> loadSpecialOptions(String quoteId) {
        String fields = getFields(SBQQ__QuoteLine__c.getSObjectType());
        String query = 'SELECT ' + fields + ' FROM SBQQ__QuoteLine__c';
        query += ' WHERE SBQQ__Quote__c = : quoteId And CPQ_Is_Special_Options__c = true';
        return Database.query(query);
    }

    //QuoteLineWrapper
    public class QuoteLineWrapper{

        @AuraEnabled
        public SBQQ__QuoteLine__c quoteLine {get; set;}

        @AuraEnabled
        public Boolean selected {get; set;}

        public QuoteLineWrapper(SBQQ__QuoteLine__c ql){
            quoteLine = ql;
            selected = true;
        }
    }

    @AuraEnabled
    public static List<QuoteLineWrapper> getQuoteLineWrappers(String quoteId){
        
        List<QuoteLineWrapper> listQuoteLineWrappers = new List<QuoteLineWrapper>();

        for(SBQQ__QuoteLine__c ql: loadMachineQuoteLines(quoteId)) {
            
            listQuoteLineWrappers.add(new QuoteLineWrapper(ql));
        }

        return listQuoteLineWrappers;
    }
    
    private static List<SBQQ__QuoteLine__c> loadMachineQuoteLines(String quoteId) {
        String fields = getFields(SBQQ__QuoteLine__c.getSObjectType());
        String query = 'SELECT ' + fields + ',CPQ_Quote_Product__r.Name' + ' FROM SBQQ__QuoteLine__c';
        query += ' WHERE SBQQ__Quote__c = : quoteId And CPQ_Is_Machine__c = true';
        return Database.query(query);
    }
    
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> setQuoteLineWrappers(String quoteLineWrappers, String quoteId){
        SBQQ.TriggerControl.disable();
        TriggerHandler.bypass('CPQ_QuoteLineTriggerHandler');
        
        List<QuoteLineWrapper> listQuoteLineWrappers = (List<QuoteLineWrapper>)JSON.deserialize(quoteLineWrappers, List<QuoteLineWrapper>.class);
        List<SBQQ__QuoteLine__c> listQuoteLines = new List<SBQQ__QuoteLine__c>();

        for(QuoteLineWrapper qlw: listQuoteLineWrappers) {
            SBQQ__QuoteLine__c ql = qlw.quoteLine;
            ql.CPQ_Print__c = qlw.selected;
            listQuoteLines.add(qlw.quoteLine);
        }
        
        Database.SaveResult[] srList = Database.update(listQuoteLines, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successful update for AURA machine Id: ' + sr.getId());
            }
            else {
                // Operation failed, display all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug(loggingLevel.Error, 'AURA error has occurred.');
                    System.debug(loggingLevel.Error, err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(loggingLevel.Error, 'AURA machine fields that affected this error: ' + err.getFields());
                }
            }
        }

        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id=quoteId);
        quote.CPQ_Machine_Grouping_Number__c = generateMachineGroupNumber(listQuoteLines);
        List<SBQQ__Quote__c> listQuotesUpdate = new List<SBQQ__Quote__c>{quote};

        Database.SaveResult[] srList2 = Database.update(listQuotesUpdate, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList2) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successful update for object Id: ' + sr.getId());
            }
            else {
                // Operation failed, display all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug(loggingLevel.Error, 'The following error has occurred.');
                    System.debug(loggingLevel.Error, err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(loggingLevel.Error, 'object fields that affected this error: ' + err.getFields());
                }
            }
        }
        
        
        
        TriggerHandler.clearBypass('CPQ_QuoteLineTriggerHandler');
        SBQQ.TriggerControl.enable();
        return listQuoteLines;
    }
    
    @AuraEnabled
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody, String mCC, String quoteId){
    
        SBQQ__Quote__c quote = [SELECT Id, Name, SBQQ__BillingName__c FROM SBQQ__Quote__c WHERE Id =:quoteId];
        
        //generate quote attachment
	    Blob b = generateQuoteAttachment(quote);
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        List<String> sendToCC = new List<String>();
        sendTo.add(mMail);
        sendToCC = mCC.split(',');
        mail.setToAddresses(sendTo);
        mail.setCcAddresses(sendToCC);
        
        // Step 3: Set who the email is sent from
        mail.setReplyTo(sendToCC[0]); // change it with your mail address.
        mail.setSenderDisplayName(sendToCC[0]);
        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
    
        //set attachment on email
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        String attachmentName = generateAttachmentName(quote) + '.pdf';
        efa1.setFileName(attachmentName);
        efa1.setBody(b);
    
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
        
        // Step 5. Add your email to the master list
        mails.add(mail);

        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);
	
	    saveQuoteAttachment(b, attachmentName, quote);
    }
	
	@AuraEnabled
	public static void savePdf(String quoteId){
		SBQQ__Quote__c quote = [SELECT Id, Name, SBQQ__BillingName__c FROM SBQQ__Quote__c WHERE Id =:quoteId];
		Blob b = generateQuoteAttachment(quote);
		String attachmentName = generateAttachmentName(quote) + '.pdf';
		saveQuoteAttachment(b, attachmentName, quote);
	}
	
	@AuraEnabled
	public static Blob generateQuoteAttachment(SBQQ__Quote__c quote){
		
		//generate quote attachment
		PageReference ref = Page.QuotePdf;
		ref.getParameters().put('id',quote.Id);
		Blob b = Blob.valueof('');
		if (!Test.isRunningTest()){
			b = ref.getContentAsPDF();
		}
		else{
			b = Blob.valueof('Some random String');
		}
		
		return b;
	}
	
	@AuraEnabled
	public static void saveQuoteAttachment(Blob b, String attachmentName, SBQQ__Quote__c quote){
		
		ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
		conVer.PathOnClient = attachmentName; // The files name, extension is very important here which will help the file in preview.
		conVer.Title = attachmentName; // Display name of the files
		conVer.VersionData = b;
		insert conVer;
		
		// First get the content document Id from ContentVersion
		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
		
		//Create ContentDocumentLink
		ContentDocumentLink cDe = new ContentDocumentLink();
		cDe.ContentDocumentId = conDoc;
		cDe.LinkedEntityId = quote.Id; // you can use objectId,GroupId etc
		cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
		//cDe.Visibility = 'InternalUsers';
		insert cDe;
	}
    
    private static String generateAttachmentName (SBQQ__Quote__c quote){
    
    
        //date(today) american format
        String dateToday = String.valueOf(date.today().day())
                + '-' + String.valueOf(date.today().month()) + '-' + String.valueOf(date.today().year());
    
        //quote name
        return dateToday + '_' + quote.Name + '_' + quote.SBQQ__BillingName__c;
    }
    
    @AuraEnabled
    public static SBQQ__Quote__c getQuote(String quoteId){
    
        String fields = getFields(SBQQ__Quote__c.getSObjectType());
        String query = 'SELECT ' + fields + ', SBQQ__SalesRep__r.Email, SBQQ__PrimaryContact__r.Email ' + ' FROM SBQQ__Quote__c';
        query += ' WHERE Id = : quoteId ';
        return Database.query(query);
    }

    private static String generateMachineGroupNumber(List<SBQQ__QuoteLine__c> listQuoteLines){
        String machineGroupNumber = '';
        Boolean allChecked = true;
        List<Integer> order = new List<Integer>();



        for(SBQQ__QuoteLine__c ql: listQuoteLines) {
            if(listQuoteLines.size() == 1 && ql.CPQ_Print__c) {
                machineGroupNumber = '1';
                return machineGroupNumber;
            }
            if(!ql.CPQ_Print__c) {
                allChecked = false;
            }
            if(ql.CPQ_Print__c) {
                order.add(Integer.valueOf(ql.CPQ_Quote_Line_Group_Number__c));
            }
        }
        if(allChecked) {
            machineGroupNumber = '88';
            return machineGroupNumber;
        }
        order.sort();
        for(Integer i: order) {
            machineGroupNumber += Integer.valueOf(i);
        }
        return machineGroupNumber;
    }
	
	@AuraEnabled
	public static SBQQ__Quote__c revisionQuote(String quoteId){
		
		SBQQ__Quote__c quote = getQuote(quoteId);
		
		SBQQ__Quote__c revisedQuote = CPQ_Quote_Syncprocess.revisionQuote( new List<SBQQ__Quote__c>{quote});
		quote.CPQ_Revised_Quote__c = revisedQuote.Id;
		quote.CPQ_Quote_revised__c = true;
		update quote;

		return revisedQuote;
		
	}
}