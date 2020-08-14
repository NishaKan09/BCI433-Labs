         DCL-F INCOMETDSP WORKSTN;
         //THIS IS A COMMENT

         EXFMT GETINCOME;

         DOW NOT(*IN03); //DOW *IN03 = *OFF

         IF IncomeAmt = 0;
           *IN98= *ON; //Zero Income Amount
           EXFMT GetIncome;
           *IN98 = *OFF;
           ITER; // GO TO THE ENDDO FOR NEXT LOOP ITERATION

         ELSEIF Married = ' ';
           *IN97=*ON; //Zero Income Amount
           EXFMT GetIncome;
           *IN97 = *OFF;
           ITER; // GO TO THE ENDDO FOR NEXT LOOP ITERATION
         ELSE;
            IF STDEXPENSE > 4000;
              STDEXPENSE = 4000;
            ENDIF;
              IF DONATIONS > 10000;
                DONATIONS = 10000;
              ENDIF;
            DEDUCTIONS = STDEXPENSE + DONATIONS;
            AINCOMEAMT = (INCOMEAMT - DEDUCTIONS);
            EXSR GetTaxRate;
         ENDIF;

         DAYSTOPAY = %Diff(d'2021-04-30': %Date() : *DAYS);
         TAXAMT = AINCOMEAMT * TaxRate;

         //PROTECT FIRST SCREEN RECORD FIELDS
         //REDISPLAY FIRST SCREEN RECORD AND THEN OVERLAY SECOND RECORD
                *IN60=*ON;
                WRITE GETINCOME;
                EXFMT YOURTAX;
                *IN60 = '0';

               IF *IN03=*OFF;
                  EXSR CLEAR;
                  EXFMT GetIncome;
               ENDIF;
             ENDDO;
             *INLR = *ON;
             RETURN;


             BEGSR GetTaxRate;
               IF Married = 'N';
                   SELECT;
                     WHEN IncomeAmt >= 500001;
                       TaxRate = .37;
                     WHEN IncomeAmt >= 200001;
                       TaxRate = .35;
                     WHEN IncomeAmt >= 157501;
                       TaxRate = .32;
                     WHEN IncomeAmt >= 82501;
                       TaxRate = .24;
                     WHEN IncomeAmt >= 38701;
                       TaxRate = .22;
                     WHEN IncomeAmt >= 9526;
                       TaxRate = .12;
                     OTHER;
                       TaxRate = .10;
                   ENDSL;
               ENDIF;
               IF Married = 'Y';
                   SELECT;
                     WHEN IncomeAmt >= 600001;
                       TaxRate = .37;
                     WHEN IncomeAmt >= 400001;
                       TaxRate = .35;
                     WHEN IncomeAmt >= 315001;
                       TaxRate = .32;
                     WHEN IncomeAmt >= 165001;
                       TaxRate = .24;
                     WHEN IncomeAmt >= 77401;
                       TaxRate = .22;
                     WHEN IncomeAmt >= 19051;
                       TaxRate = .12;
                     OTHER;
                       TaxRate = .10;
                   ENDSL;
                   //TaxRate = .10;
               ENDIF;
             ENDSR;

             BEGSR CLEAR;
                 TaxRate = .10;
                 INCOMEAMT = 0;
                 MARRIED = ' ';
                 STDEXPENSE = 0;
                 DONATIONS = 0;

             ENDSR;
                  
