@isTest
private class CPQ_Test_QuoteControllerExtension {


	 @isTest
    static void testExtensionConstructor() {
		
        CPQ_DataFactory.insertCustomSettings();

        //Account
        Account acc = new Account(
        	Name = 'Test'
        );
        insert acc;
        
        //Opportunity
        Opportunity opp = returnOpportunity(acc.Id);
        insert opp;
        
        //Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
        	CPQ_Quote_Language__c = 'DE',
            SBQQ__Opportunity2__c = opp.id
        );
        insert quote;

        Product2 prod1 = new Product2(
        	Name = 'Parent',
            CPQ_Is_Machine__c = true
        );
        insert prod1;

        SBQQ__QuoteLine__c parent = new SBQQ__QuoteLine__c(
        	SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = prod1.Id,
            SBQQ__NetPrice__c = 100000,
            SBQQ__Quantity__c = 1
        );
        insert parent;
        
        PageReference pageRef = Page.CPQ_Quote_ShowMachineLineItems;

        Test.setCurrentPage(pageRef);

        
        Test.startTest();

        ApexPages.StandardController sController = new ApexPages.StandardController(quote);

        CPQ_QuoteControllerExtension controllerExt = new CPQ_QuoteControllerExtension(sController);
        
		List<SBQQ__QuoteLine__c> listMachines = controllerExt.listMachines;
        
        List<SBQQ__QuoteLine__c> listMachineQuoteLines = CPQ_QuoteControllerExtension.getMachineQuoteLines(quote.Id);
		 
        
        List<SBQQ__QuoteLine__c> listSpecialOptionQuoteLines = CPQ_QuoteControllerExtension.getSpecialOptionQuoteLines(quote.Id);
        
        CPQ_QuoteControllerExtension.QuoteLineWrapper wrapper = new CPQ_QuoteControllerExtension.QuoteLineWrapper(parent);
        
        List<CPQ_QuoteControllerExtension.QuoteLineWrapper> listQuoteLineWrapper = CPQ_QuoteControllerExtension.getQuoteLineWrappers(quote.Id);
        
        JSON.serialize(listQuoteLineWrapper);
        List<SBQQ__QuoteLine__c> listWrappers = CPQ_QuoteControllerExtension.setQuoteLineWrappers(JSON.serialize(listQuoteLineWrapper), quote.Id);
		
		 List<SBQQ__QuoteLine__c> listMachineWithSpecialOptions = CPQ_QuoteControllerExtension.getMachineWithSpecialOptions(quote.Id);
		
		 String mMail = 'support@comselect.net';
		 String mSubject = 'Test';
		 String mbody = 'Test';
		 String mCC = 'support@comselect.net';
		 CPQ_QuoteControllerExtension.sendMailMethod(mMail ,mSubject ,mbody,mCC, quote.Id);
		 List<CPQ_Payment_Conditions_Detail_Line__c> listPayCon = CPQ_QuoteControllerExtension.getPaymentConditions(parent.Id);
		 List<CPQ_Terms_and_Conditions__c> listTac = CPQ_QuoteControllerExtension.getTermsAndConditions(parent.Id);
        
        Test.stopTest();
        

        System.assertNotEquals(null, controllerExt);

	}
    
    public static Opportunity returnOpportunity(String accId){
        Opportunity opp = new Opportunity(
        	Name = 'Opp',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Klingelnberg Master Sales').getRecordTypeId(),
            CPQ_Is_Calculation_Opp__c = false,
            AccountId = accId,
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            CPQ_Bevel_Gear_Technology__c = 'yes',
            CPQ_Cylindrical_Gear_Technology__c = 'yes',
            CPQ_Measurement_Centers__c = 'yes',
            Type_of_Business__c = 'KL GmbH'
        );
        return opp;
    }

}