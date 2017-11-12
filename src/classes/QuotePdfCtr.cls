public class QuotePdfCtr {
    
    private static List<String> additionalQuoteFields = new List<String>{
        'SBQQ__SalesRep__r.Phone',
        'SBQQ__SalesRep__r.Name', 'SBQQ__SalesRep__r.Initials__c', 'SBQQ__SalesRep__r.Alias', 'SBQQ__SalesRep__r.Email',
        'CPQ_Singner_2_Approver__r.Name', 'CPQ_Singner_2_Approver__r.Email', 'CPQ_Singner_2_Approver__r.Initials__c',
        'SBQQ__Quote__c.SBQQ__PrimaryContact__r.Name',
        'SBQQ__Opportunity2__r.Type_of_Business__c'
    };
        
    private static List<String> additionalQuoteLineFields = new List<String>{
        'SBQQ__Product__r.ProductCode'
    };
        
    public String company {get;set;}
    public String companyAddress {get;set;}
    public String footerText {get;set;}
        public String signatureSalesRep {get;set;}
        public String signatureApprover {get;set;}
    
    public SBQQ__Quote__c quote {get;set;}
    public List<SBQQ__QuoteLine__c> quoteLines {get;set;}
    public List<MachineGroup> baseMachines {get;set;}
    public List<CPQ_General_Terms_and_Conditions__c> generalTermsConditions {get;set;}
    
    public List<Quote_Template_Footer__c> footerColumns {get;set;}
    
    public Boolean showRequirementsText {get{
        return quote.CPQ_Quote_show_req_and_additional_text__c == 'Show All'
                || quote.CPQ_Quote_show_req_and_additional_text__c == 'Show only requirements';
    }private set;}
    
    public Boolean showAdditionalText {get{
        return quote.CPQ_Quote_show_req_and_additional_text__c == 'Show All'
                || quote.CPQ_Quote_show_req_and_additional_text__c == 'Show additional text';
    }private set;}
    
    public QuotePdfCtr() {
        
        String quoteId = ApexPages.currentPage().getParameters().get('id');
        quote = loadQuote(quoteId);
        company = quote.SBQQ__Opportunity2__r.Type_of_Business__c;
            System.debug(quote.SBQQ__SalesRep__r.Email);
            signatureSalesRep = 'CPQ_' + quote.SBQQ__SalesRep__r.Initials__c;
            signatureApprover = 'CPQ_' + quote.CPQ_Singner_2_Approver__r.Initials__c;
            if ( signatureApprover == 'CPQ_null' ) {
                        signatureApprover = 'Gobal_Offer_Picture';
            }
            if ( signatureSalesRep == 'CPQ_null' ) {
                    signatureSalesRep = 'Gobal_Offer_Picture';
            }
        
        quoteLines = findAllLines(quoteId);
        baseMachines = orderByMachines(quoteLines);
        generalTermsConditions = addGeneralTermsConditions(quote);
        addImages(baseMachines);
        addProductDescriptions(baseMachines);
        addMachineOptions(baseMachines, quote.SBQQ__QuoteLanguage__c);
        addTerms(baseMachines, quoteId);
            
        
        //added by comselect
        //date: 03.08.2017
        addTechnicalDatasheets(baseMachines, quote);
        
        initFooter();
    }
    
    private void initFooter() {
        Map<Decimal, Quote_Template_Footer__c> orderMap = new Map<Decimal, Quote_Template_Footer__c>();
        for(Quote_Template_Footer__c footerColumn : Quote_Template_Footer__c.getall().values()) {
            if(footerColumn.Language__c == quote.SBQQ__QuoteLanguage__c
               && footerColumn.KL_Company__c == company) {
                orderMap.put(footerColumn.Order__c, footerColumn);
            }
        }
        
        List<Decimal> orderList = new List<Decimal>(orderMap.keySet());
        orderList.sort();
        
        footerColumns = new List<Quote_Template_Footer__c>();
        for(Decimal order : orderList) {
            Quote_Template_Footer__c  column = orderMap.get(order);
            if(order == 1) {
                companyAddress = column.Company_Address__c;
                footerText = column.Additional_Text__c ;
            }
            footerColumns.add(column);
        }
    }
    
    private static void addImages(List<MachineGroup> baseMachines) {
        Map<String, List<MachineGroup>> groupPictureKeys = new Map<String, List<MachineGroup>>();
        for(MachineGroup grp : baseMachines) {
            String prodCode = grp.machine.SBQQ__Product__r.ProductCode;
            if(String.isNotEmpty(prodCode)) {
                if(groupPictureKeys.get(prodCode) == null) {
                    groupPictureKeys.put(prodCode, new List<MachineGroup>());
                }
                groupPictureKeys.get(prodCode).add(grp);
            }
        }
        
        Map<Id, CPQ_Product_Group_Picture__c> prodFamilies = new Map<Id, CPQ_Product_Group_Picture__c>(
            [SELECT CPQ_Product_Forecast_Family_Name__c 
               FROM CPQ_Product_Group_Picture__c 
              WHERE CPQ_Product_Forecast_Family_Name__c in :groupPictureKeys.keySet()]
        );
        
        for(Attachment att : [SELECT ParentId FROM Attachment WHERE ParentId in :prodFamilies.keySet()]) {
            String prodCode = prodFamilies.get(att.ParentId).CPQ_Product_Forecast_Family_Name__c;
            for(MachineGroup grp : groupPictureKeys.get(prodCode)) {
                grp.groupPictureId = att.Id;
            }
        }
        
        Map<Id, CPQ_Product_Detail_Picture__c> detailPictures = new Map<Id, CPQ_Product_Detail_Picture__c>(
            [SELECT CPQ_Product_Detail_Picture_Key__c 
               FROM CPQ_Product_Detail_Picture__c 
              WHERE CPQ_Product_Detail_Picture_Key__c in :groupPictureKeys.keySet()]
        );
        
        for(Attachment att : [SELECT ParentId FROM Attachment WHERE ParentId in :detailPictures.keySet()]) {
            String prodCode = detailPictures.get(att.ParentId).CPQ_Product_Detail_Picture_Key__c;
            for(MachineGroup grp : groupPictureKeys.get(prodCode)) {
                grp.detailPictureId = att.Id;
            }
        }
    }
    
    private static SBQQ__Quote__c loadQuote(Id quoteId) {
        String fields = getFields(SBQQ__Quote__c.getSObjectType());
        if(!additionalQuoteFields.isEmpty()) {
            fields += ',' + String.join(additionalQuoteFields, ',');
        }
        String query = 'SELECT ' + fields + ' FROM SBQQ__Quote__c WHERE Id = :quoteId';
        return Database.query(query);
    }
    
    private static List<SBQQ__QuoteLine__c> findAllLines(Id quoteId) {
        String fields = getFields(SBQQ__QuoteLine__c.getSObjectType());
        if(!additionalQuoteFields.isEmpty()) {
            fields += ',' + String.join(additionalQuoteLineFields, ',');
        }
        String query = 'SELECT ' + fields + ' FROM SBQQ__QuoteLine__c';
        query += ' WHERE SBQQ__Quote__c = :quoteId';
        //query += ' AND SBQQ__Optional__c = false';
        query += ' AND CPQ_Line_Item_Do_not_Print__c = false AND CPQ_Print__c = true';
        query += ' ORDER BY CPQ_Product_Group_Sort__c, CPQ_Product_Option_Sort__c ASC NULLS Last';
        return Database.query(query);
    }
    
    private static List<CPQ_product_description__c> findProductDescriptions(Set<String> cpqKeys) {
        String fields = getFields(CPQ_product_description__c.getSObjectType());
        String query = 'SELECT ' + fields + ' FROM CPQ_product_description__c WHERE CPQ_Key__c in :cpqKeys';
        return Database.query(query);
    }
    
    private static List<CPQ_Terms_and_Conditions__c> loadTerms(Set<Id> baseMachinesIds) {
        String fields = getFields(CPQ_Terms_and_Conditions__c.getSObjectType());
        String fieldsPayCon = getFields(CPQ_Payment_Conditions_Detail_Line__c.getSObjectType());
        String query = 'SELECT ' + fields 
        + ', (SELECT ' + fieldsPayCon + ' FROM CPQ_Payment_Conditions_Detail_Line__r ORDER BY CPQ_Sort__c ASC NULLS LAST' + ') ';
        query += ' FROM CPQ_Terms_and_Conditions__c';
        query += ' WHERE CPQ_Quote_Line__c = :baseMachinesIds AND CPQ_Do_not_Print__c = false';
        query += ' ORDER BY CPQ_Order_DEV__c ASC';
        return Database.query(query);
    }
    
    //added by comselect
    //date: 03.08.2017
    private static List<CPQ_Technical_data_sheet__c> loadTechnicalDatasheets(Set<String> setMachineKeys, Set<String> setOptionKeys, SBQQ__Quote__c quote) {

        String language = quote.SBQQ__QuoteLanguage__c;

        String fields = getFields(CPQ_Technical_data_sheet__c.getSObjectType());
        String query = 'SELECT ' + fields + ' FROM CPQ_Technical_data_sheet__c';
        query += ' WHERE CPQ_Machine_Key__c IN :setMachineKeys';
        query += ' AND CPQ_Technical_data_language__c = :language';
        query += ' AND ( CPQ_Key_Selection_Field__c = null OR CPQ_Key_Selection_Field__c IN :setOptionKeys)';
        query += ' ORDER BY CPQ_Grouping_Order__c, CPQ_Order__c ASC NULLS Last';
        return Database.query(query);
    }
    
    //added by comselect
    //date: 03.08.2017
    private static Map<String, Map<String, List<CPQ_Technical_data_sheet__c>>> orderTechnicalDatasheets(Set<String> setMachineKeys, Set<String> setOptionKeys, SBQQ__Quote__c quote) {

        Map<String, Map<String, List<CPQ_Technical_data_sheet__c>>> mapDatasheetsByGroupByMachine = new Map<String, Map<String, List<CPQ_Technical_data_sheet__c>>>();
        List<CPQ_Technical_data_sheet__c> listTechnicalDatasheets = loadTechnicalDatasheets(setMachineKeys,setOptionKeys,quote);

        for(CPQ_Technical_data_sheet__c tds: listTechnicalDatasheets) {

            if(mapDatasheetsByGroupByMachine.containsKey(tds.CPQ_Machine_Key__c)) {

                if(mapDatasheetsByGroupByMachine.get(tds.CPQ_Machine_Key__c).containsKey(tds.CPQ_Grouping__c + '|' + String.valueOf(tds.CPQ_Is_Note__c))) {
                    mapDatasheetsByGroupByMachine.get(tds.CPQ_Machine_Key__c).get(tds.CPQ_Grouping__c + '|' + String.valueOf(tds.CPQ_Is_Note__c)).add(tds);
                } else {
                    mapDatasheetsByGroupByMachine.get(tds.CPQ_Machine_Key__c).put(tds.CPQ_Grouping__c + '|' + String.valueOf(tds.CPQ_Is_Note__c), new List<CPQ_Technical_data_sheet__c>{tds});
                }

            } else {
                mapDatasheetsByGroupByMachine.put(tds.CPQ_Machine_Key__c, new Map<String, List<CPQ_Technical_data_sheet__c>>{});
                mapDatasheetsByGroupByMachine.get(tds.CPQ_Machine_Key__c).put(tds.CPQ_Grouping__c + '|' + String.valueOf(tds.CPQ_Is_Note__c), new List<CPQ_Technical_data_sheet__c>{tds});
            }
        }
        return mapDatasheetsByGroupByMachine;
    }
    
    private static void addProductDescriptions(List<MachineGroup> machines) {
        Set<String> cpqKeys = new Set<String>();
        for(MachineGroup machine : machines) {
            if(machine.machine.CPQ_Key__c != null) {
                cpqKeys.add(machine.machine.CPQ_Key__c);
            }
            for(ProductGroup prodGroup : machine.productGroups) {
                for(MachineItem item : prodGroup.machineItems) {
                    if(item.machine.CPQ_Key__c != null) {
                        cpqKeys.add(item.machine.CPQ_Key__c);
                    }
                }
                if ( prodGroup.machineItemTop.machine.CPQ_Key__c != null ) {
                    cpqKeys.add(prodGroup.machineItemTop.machine.CPQ_Key__c);
                }
            }
        }
        
        Map<String, CPQ_product_description__c> descriptionByKey = new Map<String, CPQ_product_description__c>();
        for(CPQ_product_description__c descr : findProductDescriptions(cpqKeys)) {
            descriptionByKey.put(descr.CPQ_Key__c, descr);
        }
        
        for(MachineGroup machine : machines) {
            machine.description = descriptionByKey.get(machine.machine.CPQ_Key__c);
            //added by cs 15.08
            if(descriptionByKey.containsKey(machine.machine.CPQ_Key__c))
            machine.machine.CPQ_Quote_Product_Name__c = descriptionByKey.get(machine.machine.CPQ_Key__c).CPQ_prod_desc_product_name__c;
            for(ProductGroup prodGroup : machine.productGroups) {
                for(MachineItem item : prodGroup.machineItems) {
                    item.description = descriptionByKey.get(item.machine.CPQ_Key__c);
                }
                prodGroup.machineItemTop.description = descriptionByKey.get(prodGroup.machineItemTop.machine.CPQ_Key__c);
            }
        }
    }
    
    private static List<CPQ_General_Terms_and_Conditions__c> addGeneralTermsConditions(SBQQ__Quote__c quote) {
        
        List<CPQ_General_Terms_and_Conditions__c> listGeneralTermsConditions = [
                SELECT
                        CPQ_GTac_Legal_Form__c,
                        CPQ_GTaC_Text_Company__c,
                        CPQ_GTaC_Text_inactive__c,
                        CPQ_GTaC_Text_Language__c,
                        CPQ_GTaC_Text_Long__c,
                        CPQ_GTaC_Text_Name__c,
                        CPQ_GTaC_Text_Number__c,
                        CPQ_GTaC_Type_of_Template__c,
                        CPQ_Valid_from__c,
                        CreatedById,
                        CreatedDate,
                        CurrencyIsoCode,
                        Id,
                        IsDeleted,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        Name,
                        OwnerId,
                        SystemModstamp
                FROM CPQ_General_Terms_and_Conditions__c
                WHERE CPQ_GTaC_Text_Language__c =:quote.SBQQ__QuoteLanguage__c
                AND CPQ_GTac_Legal_Form__c =:quote.CPQ_Legal_Form__c
                AND CPQ_GTaC_Text_Company__c =:quote.CPQ_Type_of_Business__c
                AND CPQ_GTaC_Text_inactive__c = false
                AND CPQ_GTaC_Type_of_Template__c =:quote.SBQQ__Type__c
                AND CPQ_Valid_from__c <= TODAY
                ORDER BY CPQ_GTaC_Text_Number__c ASC NULLS LAST ];
        
        return listGeneralTermsConditions;
    }
    
    private static void addMachineOptions(List<MachineGroup> machines, String language) {
        Set<Id> productIds = new Set<Id>();
        Set<String> productCodes = new Set<String>();
        for(MachineGroup machine : machines) {
            for(ProductGroup prodGroup : machine.productGroups) {
                for(MachineItem item : prodGroup.machineItems) {
                    if(item.machine.CPQ_Is_Machine__c && item.machine.CPQ_Quote_Product_Code__c != null) {
                        productCodes.add(item.machine.CPQ_Quote_Product_Code__c);
                    } else {
                        productIds.add(item.machine.SBQQ__Product__c);
                    }
                }
            }
        }
        
        Map<String, List<CPQ_machine_options__c>> optionsByProductCode = new Map<String, List<CPQ_machine_options__c>>();
        for(CPQ_machine_options__c option : findMachineOptionsbyProductCode(productCodes, language)) {
            if(optionsByProductCode.get(option.CPQ_machine_options_Product__r.ProductCode) == null) {
                optionsByProductCode.put(option.CPQ_machine_options_Product__r.ProductCode, new List<CPQ_machine_options__c>());
            }
            optionsByProductCode.get(option.CPQ_machine_options_Product__r.ProductCode).add(option);
        }
        
        Map<Id, List<CPQ_machine_options__c>> optionsByProduct = new Map<Id, List<CPQ_machine_options__c>>();
        for(CPQ_machine_options__c option : findMachineOptionsbyProduct(productIds, language)) {
            if(optionsByProduct.get(option.CPQ_machine_options_Product__c) == null) {
                optionsByProduct.put(option.CPQ_machine_options_Product__c, new List<CPQ_machine_options__c>());
            }
            optionsByProduct.get(option.CPQ_machine_options_Product__c).add(option);
        }
        
        for(MachineGroup machine : machines) {
            List<CPQ_machine_options__c> baseOptions = optionsByProductCode.get(machine.machine.CPQ_Quote_Product_Code__c);
            if(baseOptions != null) {
                machine.machineOptions.addAll(baseOptions);
            }
            for(ProductGroup prodGroup : machine.productGroups) {
                for(MachineItem item : prodGroup.machineItems) {
                    List<CPQ_machine_options__c> options = optionsByProduct.get(item.machine.SBQQ__Product__c);
                    if(options != null) {
                        machine.machineOptions.addAll(options);
                    }
                }
            }
        }
    }

    private static List<CPQ_machine_options__c> findMachineOptionsByProductCode(Set<String> productCodes, String language) {
        String fields = getFields(CPQ_machine_options__c.getSObjectType());
        String query = 'SELECT CPQ_machine_options_Product__r.ProductCode, ' + fields + ' FROM CPQ_machine_options__c';
        query += ' WHERE CPQ_machine_options_language__c = :language';
        query += ' AND CPQ_machine_options_Product__c in (SELECT Id FROM Product2 WHERE ProductCode in :productCodes)';
        return Database.query(query);
    }
    
    private static List<CPQ_machine_options__c> findMachineOptionsbyProduct(Set<Id> productIds, String language) {
        String fields = getFields(CPQ_machine_options__c.getSObjectType());
        String query = 'SELECT ' + fields + ' FROM CPQ_machine_options__c';
        query += ' WHERE CPQ_machine_options_Product__c in :productIds';
        query += ' AND CPQ_machine_options_language__c = :language';
        return Database.query(query);
    }
    
    private static void addTerms(List<MachineGroup> baseMachines, String quoteId) {
        Set<Id> baseMachinesIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> listQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(MachineGroup grp : baseMachines) {
            baseMachinesIds.add(grp.machine.Id);
            listQuoteLines.add(grp.machine);
        }
        
        //added by comselect
        //date: 28.07.2017
        List<CPQ_Terms_and_Conditions__c> listTerms = 
        CPQ_Quote_DefaultTermsConditions.replaceMergeFields(loadTerms(baseMachinesIds), quoteId, listQuoteLines);
        
        for(CPQ_Terms_and_Conditions__c term : listTerms) {
            for(MachineGroup machine : baseMachines) {
                if(machine.machine.Id == term.CPQ_Quote_Line__c) {
                    machine.addTaCToGroup(term);

                    for(TermsAndConditionsGroup tacGroup: machine.termsAndConditions) {
                        for(CPQ_Payment_Conditions_Detail_Line__c payCon: term.CPQ_Payment_Conditions_Detail_Line__r) {
                            payCon.CPQ_Currency_Value__c = machine.machine.CPQ_Printout_Package_Total_for_TuC__c / 100 * Integer.valueOf(payCon.Z_Value__c);
                            tacGroup.paymentConditions.add(payCon);
                        }
                    }
                }
            }
        }
    }
    
    //added by comselect
    //date: 03.08.2017
    private static void addTechnicalDatasheets(List<MachineGroup> baseMachines, SBQQ__Quote__c quote){
        Set<String> setMachineKeys = new Set<String>();
        Set<String> setOptionKeys = new Set<String>();
        List<SBQQ__QuoteLine__c> listBaseMachines = new List<SBQQ__QuoteLine__c>();


        for(MachineGroup grp : baseMachines) {
            listBaseMachines.add(grp.machine);
        }

        for(SBQQ__QuoteLine__c ql: listBaseMachines) {
            
            if(ql.CPQ_Technical_Data_Sheet_Key__c != null){
                List<String> listDatasheetKeys = ql.CPQ_Technical_Data_Sheet_Key__c.split('\\|');
                setMachineKeys.add(listDatasheetKeys[0]);
                listDatasheetKeys.remove(0);
    
                for(String s: listDatasheetKeys) {
                    setOptionKeys.add(s);
                }
            }
        }

        Map<String, Map<String, List<CPQ_Technical_data_sheet__c>>> mapDatasheetsByGroupByMachine = orderTechnicalDatasheets(setMachineKeys, setOptionKeys, quote);

        for(MachineGroup grp : baseMachines) {

            if(mapDatasheetsByGroupByMachine.containsKey(grp.machine.CPQ_Technical_Product_Code__c)) {

                for(String groupName: mapDatasheetsByGroupByMachine.get(grp.machine.CPQ_Technical_Product_Code__c).keySet()) {
                    
                    DatasheetGroup datagroup = new DatasheetGroup(grp);
                    List<String> listGrpProps = groupName.split('\\|');
                    datagroup.name = listGrpProps[0];
                    datagroup.hide = listGrpProps[1] == 'true' ? true : false;

                    for(CPQ_Technical_data_sheet__c tds: mapDatasheetsByGroupByMachine.get(grp.machine.CPQ_Technical_Product_Code__c).get(groupName)) {
                        
                        datagroup.technicalDatasheets.add(tds);
                    }
                    grp.technicalDatasheetGroups.add(datagroup);
                }
            }
        }
    }
    
    private static String getFields(Schema.SObjectType sType) {
        Map<String, Schema.SObjectField> schemaFieldMap = sType.getDescribe().fields.getMap();
        return String.join(new List<String>(schemaFieldMap.keySet()), ',');
    }
    
    private static List<MachineGroup> orderByMachines(List<SBQQ__QuoteLine__c> lines) {
        Map<Id, MachineGroup> baseMachines = new Map<Id, MachineGroup>();
        
        for(SBQQ__QuoteLine__c line : lines) {
            if(line.CPQ_Is_Machine__c && line.CPQ_Print__c) {
                baseMachines.put(line.SBQQ__Group__c, new MachineGroup(line));
            }
        }
        
        for(SBQQ__QuoteLine__c line : lines) {
    
            if (!line.CPQ_Is_Machine__c) {
                MachineGroup grp = baseMachines.get(line.SBQQ__Group__c);
                if(grp != null) {
                    grp.addItemToGroup(line);
                }
            }

        }
        
        return baseMachines.values();
    }
    
    public class MachineGroup {
        
        public SBQQ__QuoteLine__c machine {get;set;}
        
        public List<ProductGroup> productGroups {get;set;}
        
        public CPQ_product_description__c description {get;set;}
        
        public List<CPQ_machine_options__c> machineOptions {get;set;}
        
        //added by comselect
        //date: 03.08.2017
        public List<DatasheetGroup> technicalDatasheetGroups {get;set;}

        public List<TermsAndConditionsGroup> termsAndConditions {get;set;}
        
        public String groupPictureId {get;set;}
        public String detailPictureId {get;set;}
        
        public MachineGroup(SBQQ__QuoteLine__c machine) {
            this.machine = machine;
            this.productGroups = new List<ProductGroup>();
            this.termsAndConditions = new List<TermsAndConditionsGroup>();
            this.machineOptions = new List<CPQ_machine_options__c>();
            this.technicalDatasheetGroups = new List<DatasheetGroup>();
        }
        
        public void addItemToGroup(SBQQ__QuoteLine__c item) {
            String groupName = item.CPQ_Product_Group_Name__c;
            for(ProductGroup grp : productGroups) {
                if(grp.Name == groupName) {
                    grp.addMachineItem(item);
                    return;
                }
            }
            
            ProductGroup newGrp = new ProductGroup(item);
            //newGrp.addMachineItem(item);
            newGrp.productDescription = item.CPQ_Product_Group_Description__c;
            newGrp.specialItems = item.CPQ_Is_Special_Options__c;
            newGrp.optionalItems = item.SBQQ__Optional__c;
            productGroups.add(newGrp);
        }

        public void addTaCToGroup(CPQ_Terms_and_Conditions__c tac) {
            /*
            //String groupName = item.CPQ_Product_Group_Name__c;
            for(ProductGroup grp : productGroups) {
                if(grp.Name == groupName) {
                    grp.addMachineItem(item);
                    return;
                }
            }
            */
            
            TermsAndConditionsGroup newGrp = new TermsAndConditionsGroup(tac);
            newGrp.tac = tac;
            termsAndConditions.add(newGrp);
        }
    }
    
    //added by comselect
    //date: 03.08.2017
    public class DatasheetGroup {

        public String name {get;set;}
        
        public List<CPQ_Technical_data_sheet__c> technicalDatasheets {get;set;}
        
        public Boolean hide{get;set;}
        
        public DatasheetGroup(MachineGroup grp) {
            this.technicalDatasheets = new List<CPQ_Technical_data_sheet__c>();
            this.name = '';
            this.hide = false;
        }
    }

    public class TermsAndConditionsGroup {

        public CPQ_Terms_and_Conditions__c tac {get;set;}
        
        public List<CPQ_Payment_Conditions_Detail_Line__c> paymentConditions {get;set;}
        
        public TermsAndConditionsGroup(CPQ_Terms_and_Conditions__c tac) {
            this.tac = tac;
            this.paymentConditions = new List<CPQ_Payment_Conditions_Detail_Line__c>();
        }
    }
    
    public class ProductGroup {
        
        public String name {get;set;}
        public String productDescription {get;set;}
        
        public Boolean specialItems {get;set;}

        public Boolean optionalItems {get;set;}
        
        public MachineItem machineItemTop {get;set;}
        
        public List<MachineItem> machineItems {get;set;}
        
        public ProductGroup(SBQQ__QuoteLine__c item) {
            this.name = item.CPQ_Product_Group_Name__c;
            this.machineItems = new List<MachineItem>();
            this.machineItemTop = new MachineItem(item);
        }
        
        public void addMachineItem(SBQQ__QuoteLine__c item) {
            MachineItem machineItem = new MachineItem(item);
            machineItems.add(machineItem);
            if(machineItemTop.machine.Id == null){
                machineItemTop = machineItem;
            }
            if(String.isBlank(productDescription)) {
                productDescription = item.CPQ_Product_Group_Description__c;
            }
        }
    }
    
    public class MachineItem {
        
        public SBQQ__QuoteLine__c machine {get;set;}        
        public CPQ_product_description__c description {get;set;}
        
        public MachineItem(SBQQ__QuoteLine__c machine) {
            this.machine = machine;
        }
    }

}