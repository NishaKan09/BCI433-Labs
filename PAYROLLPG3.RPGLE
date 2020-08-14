           DCL-F SHIFTWEEK USAGE(*INPUT) KEYED RENAME(SHIFTWEEK:SHIFTWEEKR);

           DCL-F CONFIRMPY2 WORKSTN;
           DCL-F SHIFTRATES DISK USAGE(*INPUT);
           DCL-F PAYRPT2 PRINTER OFLIND(*IN01);
           DCL-S HOURSOVER PACKED(3);

           Dcl-PI  Main  ExtPgm('PAYROLLPG2');
                ShiftType  char(30);
           End-PI;


                           READ ShiftRates;
                           Write Title;
                           Write Colhdg;
                           READ SHIFTWEEK;
                           DOW NOT %EOF;
                             EXSR PAYSR;
                             IF *IN01;
                               Write Title;
                               Write Colhdg;
                               *IN01 = *Off;
                             ENDIF;
                             Write EmpDetail;
                             READ SHIFTWEEK;
                           ENDDO;
                           TOTWKPAY = TOTREGPAY + TOTOVTPAY;
                           WRITE TOTALS;
                           EXFMT RECORD1;
                           *INLR = *ON;
                           RETURN;

                           BEGSR PaySr;
                             //subroutine PAYSR: payment calculation for each row of SHIFTWEEK table
                             //1. set HOURLYRATE value based on WORKSHIFT value of each row
                             SELECT;
                               WHEN WORKSHIFT = '1';
                                 HOURLYRATE = DAYRATE;
                               WHEN WORKSHIFT = '2';
                                 HOURLYRATE = AFTNRATE;
                               WHEN WORKSHIFT = '3';
                                 HOURLYRATE = NIGHTRATE;
                             ENDSL;
                             //2. set HOURLYRATE value passed on PAYGRADE value of each row
                             SELECT;
                               WHEN PAYGRADE = 'A';
                                   EVAL(H) HOURLYRATE = HOURLYRATE * 1.096;
                               WHEN PAYGRADE = 'B';
                                   EVAL(H) HOURLYRATE = HOURLYRATE * 1.072;
                               WHEN PAYGRADE = 'C';
                                   EVAL(H) HOURLYRATE = HOURLYRATE * .956;
                             ENDSL;

                             HOURSOVER = HRSWORKED - 40;
                             //3. based HRSWORKED, calculate HOURSOVER, OVERPAY, REGULARPAY, and
                             //   and WEEKLYPAY(weekly total pay) e.g.
                             SELECT;
                               WHEN (HOURSOVER > 0);
                                  EVAL REGULARPAY = 40 * HOURLYRATE;
                               EVAL(H) OVERPAY = HOURSOVER * HOURLYRATE * 1.5;
                                  WEEKLYPAY = REGULARPAY + OVERPAY;
                                  TOTOVTPAY = TOTOVTPAY + OVERPAY;
                               OTHER;
                                 REGULARPAY = HRSWORKED * HOURLYRATE;
                                 WEEKLYPAY = REGULARPAY;
                             ENDSL;
                             //4. Accumulate totals; totregpay, totovtpay
                             TOTREGPAY = TOTREGPAY + REGULARPAY;
                             //TOTOVTPAY = TOTOVTPAY + OVERPAY;
                             TOTWKPAY = REGULARPAY + OVERPAY;
                           ENDSR;

                             
