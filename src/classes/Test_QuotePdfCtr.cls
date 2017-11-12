@isTest
public class Test_QuotePdfCtr {
    
    private final static String LANGUAGE = 'DE';
    private final static String COMPANY = 'KL GmbH';
	
    @testSetup static void setup() {
       CPQ_DataFactory.insertCustomSettings();
    }
    
    @isTest
    public static void canCreateCtr() {
        createFooterSettings();
        
        Id quoteId = createTestData();
        System.currentPageReference().getParameters().put('id', quoteId);
        QuotePdfCtr ctr = new QuotePdfCtr();
    }
    
    public static void createFooterSettings() {
        insert new Quote_Template_Footer__c(
        	Language__c = LANGUAGE,
            KL_Company__c = COMPANY,
            Name = 'Test'
        );
    }
    
    public static Id createTestData() {
        TriggerHandler.bypass('CPQ_QuoteLineTriggerHandler');
        
        Account acc = new Account(
        	Name = 'TestAcc'
        );
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'Tester',
            AccountId = acc.Id,
            CloseDate = Date.today(),
            StageName = 'New',
            Type_of_Business__c = COMPANY
        );
        insert opp;
                
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
        	SBQQ__QuoteLanguage__c = LANGUAGE,
            SBQQ__Opportunity2__c = opp.id
        );
        insert quote;

        Product2 parentProd = new Product2(
        	Name = 'Parent',
            CPQ_Is_Machine__c = true
        );
        insert parentProd;
    
        Product2 childProd = new Product2(
                Name = 'Parent',
                CPQ_Is_Machine__c = false
        );
        insert childProd;
    
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c> ();

        SBQQ__QuoteLine__c parent = new SBQQ__QuoteLine__c(
        	SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = parentProd.Id,
            SBQQ__NetPrice__c = 1,
            SBQQ__Quantity__c = 1,
            CPQ_Time_of_Delivery_in_Month_for_TaC__c = '1',
            CPQ_Delivery_Time__c = 1,
                CPQ_Print__c = true
        );
        quoteLines.add(parent);
    
        SBQQ__QuoteLine__c child = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c = quote.Id,
                SBQQ__Product__c = childProd.Id,
                SBQQ__NetPrice__c = 1,
                SBQQ__Quantity__c = 1,
                CPQ_Time_of_Delivery_in_Month_for_TaC__c = '1',
                CPQ_Delivery_Time__c = 1,
                CPQ_Print__c = true
        );
        quoteLines.add(child);
    
        SBQQ__QuoteLine__c child2 = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c = quote.Id,
                SBQQ__Product__c = childProd.Id,
                SBQQ__NetPrice__c = 1,
                SBQQ__Quantity__c = 1,
                CPQ_Time_of_Delivery_in_Month_for_TaC__c = '1',
                CPQ_Delivery_Time__c = 1,
                CPQ_Print__c = true
        );
        quoteLines.add(child2);
        insert quoteLines;
        
        CPQ_Terms_and_Conditions__c tac = new CPQ_Terms_and_Conditions__c(
        	Name = 'Tac',
            CPQ_TaC_Number__c = '1',
            CPQ_TaC_Number_Text__c = 'Test',
            CPQ_TaC_Special_Terms_and_Conditions__c = 'Conditions',
            CPQ_Quote_Line__c = parent.Id
        );
        insert tac;
        
        return quote.Id;
    }
}