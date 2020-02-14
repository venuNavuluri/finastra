@isTest
public class testOppCurrencyFieldUpdateTriggerHandler
{
    public testMethod static void shouldCalculateILF_RSFRollups()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Country__c = 'India';
        acc.Site = 'abc';
        acc.Region__c = 'Asia Pacific';
        acc.Type = 'Prospect';
        acc.CurrencyIsoCode = 'INR';
        insert acc;

        List<Opportunity> listOpportunity = new list<Opportunity >();
        List<Opportunity> updateopportunity = new list<Opportunity>();

        for(Integer i = 0 ; i<=10 ;i++)
        {
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'Test Opp'+i;
            
            opp.Is_PearlMastered__c=true;
            opp.In_QTR_ILF_TB_PERCENT__c=10;
            opp.RSF_ILF_TB__c=100;
            opp.In_QTR_ILF_CB_PERCENT__c=10;
            opp.RSF_ILF_CB__c=100;
            opp.In_QTR_ILF_CL_PERCENT__c=10;
            opp.RSF_ILF_CL__c=100;
            opp.In_QTR_ILF_CM_PERCENT__c=10;
            opp.RSF_ILF_CM__c=100;
            opp.In_QTR_ILF_ER_PERCENT__c=10;
            opp.RSF_ILF_ER__c=100;
            opp.In_QTR_ILF_IM_PERCENT__c=10;
            opp.RSF_ILF_IM__c=100;
            opp.In_QTR_ILF_XX_PERCENT__c=10;
            opp.RSF_ILF_XX__c=100;
            opp.Booking_Adjustment_percent__c = 1.0;
            //opp.ILF_Equiv_SUB__c = 100;
            //opp.ILF_Equiv_CLD__c = 20;
            //opp.ILF_Equiv_HOS__c = 30;
            //opp.ILF_Equiv_CSH__c = 150;
            opp.RSF_CLD_CB_TP__c = 100;
            opp.RSF_CLD_CL_TP__c = 200;
            opp.RSF_CLD_ER_TP__c=1000;
            opp.RSF_CLD_CM_TP__c= 300;
            opp.RSF_CLD_TB_TP__c=500;
            opp.RSF_CLD_IM_TP__c= 400;
            opp.RSF_SUB_CB_TP__c= 600;
            opp.RSF_SUB_CL_TP__c=300;
            opp.RSF_SUB_ER_TP__c=500;
            opp.RSF_SUB_CM_TP__c=700;
            opp.RSF_SUB_TB_TP__c=300;
            opp.RSF_SUB_IM_TP__c=200;
            opp.RSF_HOS_CB_TP__c=100;
            opp.RSF_HOS_CL_TP__c=200;
            opp.RSF_HOS_CM_TP__c=400;
            opp.RSF_HOS_TB_TP__c=200;
            opp.RSF_HOS_IM_TP__c=600;
            opp.RSF_HOS_ER_TP__c=200;
            opp.StageName = '1.Prospect';
            opp.CloseDate = system.today();
            listOpportunity.add(opp);
        }

        Test.startTest();
        insert listOpportunity;
        Test.stopTest();


        List<Opportunity> resultOpp1List = new List<Opportunity>([select ILF_Equiv_SUB__c,ILF_Equiv_CLD__c, ILF_Equiv_HOS__c, ILF_Equiv_CSH__c,RSF_CLD_CB_TP__c, RSF_CLD_CL_TP__c, RSF_CLD_ER_TP__c,
                RSF_CLD_TB_TP__c,RSF_CLD_IM_TP__c,RSF_SUB_CB_TP__c,RSF_SUB_CL_TP__c,RSF_SUB_ER_TP__c, RSF_SUB_CM_TP__c,RSF_SUB_TB_TP__c,RSF_SUB_IM_TP__c,
                RSF_HOS_CB_TP__c,RSF_HOS_CL_TP__c,RSF_HOS_CM_TP__c,RSF_HOS_TB_TP__c,RSF_HOS_IM_TP__c,RSF_HOS_ER_TP__c,CLD_CB_ILF_Equiv__c,
                RSF_CLD_CM_TP__c,CLD_ER_ILF_Equiv__c, CLD_CM_ILF_Equiv__c ,CLD_TB_ILF_Equiv__c, CLD_IM_ILF_Equiv__c,SUB_CB_ILF_Equiv__c,SUB_CL_ILF_Equiv__c ,SUB_ER_ILF_Equiv__c
                ,SUB_CM_ILF_Equiv__c ,SUB_TB_ILF_Equiv__c,SUB_IM_ILF_Equiv__c,HOS_CB_ILF_Equiv__c,HOS_CL_ILF_Equiv__c ,HOS_ER_ILF_Equiv__c , HOS_CM_ILF_Equiv__c ,
                HOS_TB_ILF_Equiv__c ,HOS_IM_ILF_Equiv__c,Is_PearlMastered__c, In_QTR_ILF_TB_PERCENT__c,RSF_ILF_TB__c,In_QTR_ILF_TB_Revenue__c,In_QTR_ILF_CB_PERCENT__c,RSF_ILF_CB__c,In_QTR_ILF_CB_Revenue__c,
                 In_QTR_ILF_CL_PERCENT__c,RSF_ILF_CL__c,In_QTR_ILF_CL_Revenue__c,In_QTR_ILF_CM_PERCENT__c,RSF_ILF_CM__c,In_QTR_ILF_CM_Revenue__c,In_QTR_ILF_ER_PERCENT__c,RSF_ILF_ER__c,In_QTR_ILF_ER_Revenue__c,
                 In_QTR_ILF_IM_PERCENT__c,RSF_ILF_IM__c,In_QTR_ILF_IM_Revenue__c,In_QTR_ILF_XX_PERCENT__c,RSF_ILF_XX__c,In_QTR_ILF_XX_Revenue__c,Total_ILF_In_Qtr__c,ILF_ILF_Equiv_CSH__c     from Opportunity where id IN:listOpportunity]);


        // For validate each opportunity records by checking assertion statement.

        for(Opportunity resultOpp1 : resultOpp1List)
        {
            System.assertEquals(250,resultOpp1.CLD_CB_ILF_Equiv__c  );

            System.assertEquals(2500,resultOpp1.CLD_ER_ILF_Equiv__c );
            System.assertEquals(750,resultOpp1.CLD_CM_ILF_Equiv__c );
            System.assertEquals(1250,resultOpp1.CLD_TB_ILF_Equiv__c );
            System.assertEquals(1000,resultOpp1.CLD_IM_ILF_Equiv__c );
            System.assertEquals(1500,resultOpp1.SUB_CB_ILF_Equiv__c );
            System.assertEquals(750,resultOpp1.SUB_CL_ILF_Equiv__c );
            System.assertEquals(1250,resultOpp1.SUB_ER_ILF_Equiv__c );
            System.assertEquals(1750,resultOpp1.SUB_CM_ILF_Equiv__c );
            System.assertEquals(750,resultOpp1.SUB_TB_ILF_Equiv__c );
            System.assertEquals(500,resultOpp1.SUB_IM_ILF_Equiv__c );
            System.assertEquals(250,resultOpp1.HOS_CB_ILF_Equiv__c );
            System.assertEquals(500,resultOpp1.HOS_CL_ILF_Equiv__c );
            System.assertEquals(500,resultOpp1.HOS_ER_ILF_Equiv__c );
            System.assertEquals(1000,resultOpp1.HOS_CM_ILF_Equiv__c );
            System.assertEquals(500,resultOpp1.HOS_TB_ILF_Equiv__c );
            System.assertEquals(1500,resultOpp1.HOS_IM_ILF_Equiv__c );
            System.assertEquals(1,resultOpp1.In_QTR_ILF_TB_Revenue__c  );
            System.assertEquals(170,resultOpp1.ILF_Equiv_CSH__c );
            System.assertEquals(186 ,resultOpp1.ILF_ILF_Equiv_CSH__c );
        }

        for(Integer i=0;i<=10;i++)
        {
            listOpportunity[i].In_QTR_ILF_TB_PERCENT__c=10;
            listOpportunity[i].RSF_ILF_TB__c=200;
            listOpportunity[i].In_QTR_ILF_CB_PERCENT__c=10;
            listOpportunity[i].RSF_ILF_CB__c=200;
            listOpportunity[i].In_QTR_ILF_CL_PERCENT__c=10;
            listOpportunity[i].RSF_ILF_CL__c=200;
            listOpportunity[i].In_QTR_ILF_CM_PERCENT__c=10;
            listOpportunity[i].RSF_ILF_CM__c=200;
            listOpportunity[i].In_QTR_ILF_ER_PERCENT__c=10;
            listOpportunity[i].RSF_ILF_ER__c=200;
            listOpportunity[i].In_QTR_ILF_IM_PERCENT__c=10;
            listOpportunity[i].RSF_ILF_IM__c=200;
            listOpportunity[i].In_QTR_ILF_XX_PERCENT__c=10;
            listOpportunity[i].RSF_ILF_XX__c=200;
        //    listOpportunity[i].ILF_Equiv_SUB__c = 200;
         //   listOpportunity[i].ILF_Equiv_CLD__c = 40;
         //   listOpportunity[i].ILF_Equiv_HOS__c = 60;
         //   listOpportunity[i].ILF_Equiv_CSH__c = 300;
            listOpportunity[i].RSF_CLD_CB_TP__c = 200;
            listOpportunity[i].RSF_CLD_CL_TP__c = 400;
            listOpportunity[i].RSF_CLD_ER_TP__c=2000;
            listOpportunity[i].RSF_CLD_CM_TP__c= 600;
            listOpportunity[i].RSF_CLD_TB_TP__c=1000;
            listOpportunity[i].RSF_CLD_IM_TP__c= 800;
            listOpportunity[i].RSF_SUB_CB_TP__c= 1200;
            listOpportunity[i].RSF_SUB_CL_TP__c=600;
            listOpportunity[i].RSF_SUB_ER_TP__c=1000;
            listOpportunity[i].RSF_SUB_CM_TP__c=1400;
            listOpportunity[i].RSF_SUB_TB_TP__c=600;
            listOpportunity[i].RSF_SUB_IM_TP__c=400;
            listOpportunity[i].RSF_HOS_CB_TP__c=200;
            listOpportunity[i].RSF_HOS_CL_TP__c=400;
            listOpportunity[i].RSF_HOS_CM_TP__c=800;
            listOpportunity[i].RSF_HOS_TB_TP__c=400;
            listOpportunity[i].RSF_HOS_IM_TP__c=1200;
            listOpportunity[i].RSF_HOS_ER_TP__c=400;
            updateopportunity.add(listOpportunity[i]);
        }
        update updateopportunity;


        List<Opportunity> resultOppList2 = new List<Opportunity>([select ILF_Equiv_SUB__c,ILF_Equiv_CLD__c, ILF_Equiv_HOS__c, ILF_Equiv_CSH__c,RSF_CLD_CB_TP__c, RSF_CLD_CL_TP__c, RSF_CLD_ER_TP__c,
                RSF_CLD_TB_TP__c,RSF_CLD_IM_TP__c,RSF_SUB_CB_TP__c,RSF_SUB_CL_TP__c,RSF_SUB_ER_TP__c, RSF_SUB_CM_TP__c,RSF_SUB_TB_TP__c,RSF_SUB_IM_TP__c,
                RSF_HOS_CB_TP__c,RSF_HOS_CL_TP__c,RSF_HOS_CM_TP__c,RSF_HOS_TB_TP__c,RSF_HOS_IM_TP__c,RSF_HOS_ER_TP__c,CLD_CB_ILF_Equiv__c,
                RSF_CLD_CM_TP__c,CLD_ER_ILF_Equiv__c, CLD_CM_ILF_Equiv__c ,CLD_TB_ILF_Equiv__c, CLD_IM_ILF_Equiv__c,SUB_CB_ILF_Equiv__c,SUB_CL_ILF_Equiv__c ,SUB_ER_ILF_Equiv__c
                ,SUB_CM_ILF_Equiv__c ,SUB_TB_ILF_Equiv__c,SUB_IM_ILF_Equiv__c,HOS_CB_ILF_Equiv__c,HOS_CL_ILF_Equiv__c ,HOS_ER_ILF_Equiv__c , HOS_CM_ILF_Equiv__c ,
                HOS_TB_ILF_Equiv__c ,HOS_IM_ILF_Equiv__c,Is_PearlMastered__c, In_QTR_ILF_TB_PERCENT__c,RSF_ILF_TB__c,In_QTR_ILF_TB_Revenue__c,In_QTR_ILF_CB_PERCENT__c,RSF_ILF_CB__c,In_QTR_ILF_CB_Revenue__c,
                In_QTR_ILF_CL_PERCENT__c,RSF_ILF_CL__c,In_QTR_ILF_CL_Revenue__c,In_QTR_ILF_CM_PERCENT__c,RSF_ILF_CM__c,In_QTR_ILF_CM_Revenue__c,In_QTR_ILF_ER_PERCENT__c,RSF_ILF_ER__c,In_QTR_ILF_ER_Revenue__c,
                In_QTR_ILF_IM_PERCENT__c,RSF_ILF_IM__c,In_QTR_ILF_IM_Revenue__c,In_QTR_ILF_XX_PERCENT__c,RSF_ILF_XX__c,In_QTR_ILF_XX_Revenue__c,Total_ILF_In_Qtr__c,ILF_ILF_Equiv_CSH__c from Opportunity where id IN:updateopportunity]);


        // For validate each opportunity records by checking assertion statement.

        for(Opportunity resultOpp2 : resultOppList2)
        {
            System.assertEquals(500,resultOpp2.CLD_CB_ILF_Equiv__c  );

            System.assertEquals(5000,resultOpp2.CLD_ER_ILF_Equiv__c );
            System.assertEquals(1500,resultOpp2.CLD_CM_ILF_Equiv__c );
            System.assertEquals(2500,resultOpp2.CLD_TB_ILF_Equiv__c );
            System.assertEquals(2000,resultOpp2.CLD_IM_ILF_Equiv__c );
            System.assertEquals(3000,resultOpp2.SUB_CB_ILF_Equiv__c );
            System.assertEquals(1500,resultOpp2.SUB_CL_ILF_Equiv__c );
            System.assertEquals(2500,resultOpp2.SUB_ER_ILF_Equiv__c );
            System.assertEquals(3500,resultOpp2.SUB_CM_ILF_Equiv__c );
            System.assertEquals(1500,resultOpp2.SUB_TB_ILF_Equiv__c );
            System.assertEquals(1000,resultOpp2.SUB_IM_ILF_Equiv__c );
            System.assertEquals(500,resultOpp2.HOS_CB_ILF_Equiv__c );
            System.assertEquals(1000,resultOpp2.HOS_CL_ILF_Equiv__c );
            System.assertEquals(1000,resultOpp2.HOS_ER_ILF_Equiv__c );
            System.assertEquals(2000,resultOpp2.HOS_CM_ILF_Equiv__c );
            System.assertEquals(1000,resultOpp2.HOS_TB_ILF_Equiv__c );
            System.assertEquals(3000,resultOpp2.HOS_IM_ILF_Equiv__c );
            System.assertEquals(2,resultOpp2.In_QTR_ILF_TB_Revenue__c);
            System.assertEquals(372,resultOpp2.ILF_ILF_Equiv_CSH__c );
        }
    }

    public testMethod static void shouldCalculateILF_RSFRollupsForEmptyValues()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Country__c = 'India';
        acc.Site = 'abc';
        acc.Region__c = 'Asia Pacific';
        acc.Type = 'Prospect';
        acc.CurrencyIsoCode = 'INR';
        insert acc;

        List<Opportunity> listOpportunity = new list<Opportunity >();
        List<Opportunity> updateopportunity = new list<Opportunity>();
        for(Integer i = 0 ; i<=5;i++)
        {
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'Test Opp'+i;
            
            opp.Is_PearlMastered__c=true;
            opp.In_QTR_ILF_TB_PERCENT__c=10;
            opp.RSF_ILF_TB__c=100;
            opp.In_QTR_ILF_CB_PERCENT__c=10;
            opp.RSF_ILF_CB__c=100;
            opp.In_QTR_ILF_CL_PERCENT__c=10;
            opp.RSF_ILF_CL__c=100;
            opp.In_QTR_ILF_CM_PERCENT__c=10;
            opp.RSF_ILF_CM__c=100;
            opp.In_QTR_ILF_ER_PERCENT__c=10;
            opp.RSF_ILF_ER__c=100;
            opp.In_QTR_ILF_IM_PERCENT__c=10;
            opp.RSF_ILF_IM__c=100;
            opp.In_QTR_ILF_XX_PERCENT__c=10;
            opp.RSF_ILF_XX__c=100;
            opp.RSF_CLD_CM_TP__c= 50;
            opp.RSF_CLD_TB_TP__c= 60;
            opp.RSF_CLD_IM_TP__c= 70;
            opp.RSF_SUB_CB_TP__c= 80;
            opp.RSF_SUB_CL_TP__c= 90;
            opp.RSF_SUB_ER_TP__c= 100;
            opp.RSF_HOS_CL_TP__c=400;
            opp.RSF_HOS_CM_TP__c=800;
            opp.RSF_HOS_TB_TP__c=400;
            opp.StageName = '1.Prospect';
            opp.CloseDate = system.today();

            listOpportunity.add(opp);
        }

        Test.startTest();
        insert listOpportunity;
        Test.stopTest();

// For validate each opportunity records which get update by using assertion statement
        for(Integer i=0;i<=5;i++)
        {
        
            listOpportunity[i].Is_PearlMastered__c=true;
            listOpportunity[i].In_QTR_ILF_TB_PERCENT__c=0;
            listOpportunity[i].RSF_ILF_TB__c=0;
            listOpportunity[i].In_QTR_ILF_CB_PERCENT__c=0;
            listOpportunity[i].RSF_ILF_CB__c=0;
            listOpportunity[i].In_QTR_ILF_CL_PERCENT__c=0;
            listOpportunity[i].RSF_ILF_CL__c=0;
            listOpportunity[i].In_QTR_ILF_CM_PERCENT__c=0;
            listOpportunity[i].RSF_ILF_CM__c=0;
            listOpportunity[i].In_QTR_ILF_ER_PERCENT__c=0;
            listOpportunity[i].RSF_ILF_ER__c=0;
            listOpportunity[i].In_QTR_ILF_IM_PERCENT__c=0;
            listOpportunity[i].RSF_ILF_IM__c=0;
            listOpportunity[i].In_QTR_ILF_XX_PERCENT__c=0;
            listOpportunity[i].RSF_ILF_XX__c=0;
          //  listOpportunity[i].ILF_Equiv_SUB__c = null;
           // listOpportunity[i].ILF_Equiv_CLD__c = null;
           // listOpportunity[i].ILF_Equiv_HOS__c = null;
           // listOpportunity[i].ILF_Equiv_CSH__c = null;
            listOpportunity[i].RSF_CLD_CB_TP__c = null;
            listOpportunity[i].RSF_CLD_CL_TP__c = null;
            listOpportunity[i].RSF_CLD_ER_TP__c= null;
            listOpportunity[i].RSF_CLD_CM_TP__c= null;
            listOpportunity[i].RSF_CLD_TB_TP__c= null;
            listOpportunity[i].RSF_CLD_IM_TP__c= null;
            listOpportunity[i].RSF_SUB_CB_TP__c= null;
            listOpportunity[i].RSF_SUB_CL_TP__c= null;
            listOpportunity[i].RSF_SUB_ER_TP__c= null;
            listOpportunity[i].RSF_SUB_CM_TP__c= null;
            listOpportunity[i].RSF_SUB_TB_TP__c= null;
            listOpportunity[i].RSF_SUB_IM_TP__c= null;
            listOpportunity[i].RSF_HOS_CB_TP__c= null;
            listOpportunity[i].RSF_HOS_CL_TP__c= null;
            listOpportunity[i].RSF_HOS_CM_TP__c= null;
            listOpportunity[i].RSF_HOS_TB_TP__c= null;
            listOpportunity[i].RSF_HOS_IM_TP__c= null;
            listOpportunity[i].RSF_HOS_ER_TP__c= null;

            updateopportunity.add(listOpportunity[i]);
        }
        update updateopportunity;


        List<Opportunity> resultOppList = new List<Opportunity>([select ILF_Equiv_SUB__c,ILF_Equiv_CLD__c, ILF_Equiv_HOS__c, ILF_Equiv_CSH__c,RSF_CLD_CB_TP__c, RSF_CLD_CL_TP__c, RSF_CLD_ER_TP__c,
                RSF_CLD_TB_TP__c,RSF_CLD_IM_TP__c,RSF_SUB_CB_TP__c,RSF_SUB_CL_TP__c,RSF_SUB_ER_TP__c, RSF_SUB_CM_TP__c,RSF_SUB_TB_TP__c,RSF_SUB_IM_TP__c,
                RSF_HOS_CB_TP__c,RSF_HOS_CL_TP__c,RSF_HOS_CM_TP__c,RSF_HOS_TB_TP__c,RSF_HOS_IM_TP__c,RSF_HOS_ER_TP__c,CLD_CB_ILF_Equiv__c,
                RSF_CLD_CM_TP__c,CLD_ER_ILF_Equiv__c, CLD_CM_ILF_Equiv__c ,CLD_TB_ILF_Equiv__c, CLD_IM_ILF_Equiv__c,SUB_CB_ILF_Equiv__c,SUB_CL_ILF_Equiv__c ,SUB_ER_ILF_Equiv__c
                ,SUB_CM_ILF_Equiv__c ,SUB_TB_ILF_Equiv__c,SUB_IM_ILF_Equiv__c,HOS_CB_ILF_Equiv__c,HOS_CL_ILF_Equiv__c ,HOS_ER_ILF_Equiv__c , HOS_CM_ILF_Equiv__c ,
                HOS_TB_ILF_Equiv__c ,HOS_IM_ILF_Equiv__c,Is_PearlMastered__c, In_QTR_ILF_TB_PERCENT__c,RSF_ILF_TB__c,In_QTR_ILF_TB_Revenue__c,In_QTR_ILF_CB_PERCENT__c,RSF_ILF_CB__c,In_QTR_ILF_CB_Revenue__c,
                In_QTR_ILF_CL_PERCENT__c,RSF_ILF_CL__c,In_QTR_ILF_CL_Revenue__c,In_QTR_ILF_CM_PERCENT__c,RSF_ILF_CM__c,In_QTR_ILF_CM_Revenue__c,In_QTR_ILF_ER_PERCENT__c,RSF_ILF_ER__c,In_QTR_ILF_ER_Revenue__c,
                In_QTR_ILF_IM_PERCENT__c,RSF_ILF_IM__c,In_QTR_ILF_IM_Revenue__c,In_QTR_ILF_XX_PERCENT__c,RSF_ILF_XX__c,In_QTR_ILF_XX_Revenue__c,Total_ILF_In_Qtr__c,ILF_ILF_Equiv_CSH__c from Opportunity where id IN:updateopportunity]);


        // For validate each opportunity records by checking assertion statement.

        for(Opportunity resultOpp : resultOppList)
        {
            System.assertEquals(0,resultOpp.In_QTR_ILF_TB_Revenue__c);
            System.assertEquals(0,resultOpp.CLD_CB_ILF_Equiv__c  );
            System.assertEquals(0,resultOpp.CLD_ER_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.CLD_CM_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.CLD_TB_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.CLD_IM_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.SUB_CB_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.SUB_CL_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.SUB_ER_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.SUB_CM_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.SUB_TB_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.SUB_IM_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.HOS_CB_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.HOS_CL_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.HOS_ER_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.HOS_CM_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.HOS_TB_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.HOS_IM_ILF_Equiv__c );
            System.assertEquals(0,resultOpp.ILF_ILF_Equiv_CSH__c );
        }


    }
}