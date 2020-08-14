  //**************************************************************************
       //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE FROM 3
       //* SEPARATE TABLES, ONTARIO, QUEBEC AND MANITOBA. A NUMBER IS PASSED
       //* TO THE PROGRAM TO DETERMINE WHICH RECORDS ARE INCLUDED FROM THE 3 TABLES
       //**************************************************************************
           DCL-F PROVREPORT PRINTER OFLIND(*IN01) ;
           DCL-S ProvinceH    Char(10);
           DCL-S EndOfFile    IND;
           DCL-S TotalRecords PACKED(5:0);
          // LowLimit is passed to the program

             DCL-PI  Main extPgm('PROVSQL');
               LowLimitIn Packed(15:5);    //15 digits with 5 decimal points
             END-PI;

          // All Host Variables available under a single name
           DCL-DS CustomerRecord;
             CustId           Char(6);
             FullName         Char(31);
             City             Char(20);
             Purchase         Packed(7:2);
             PDate            Date;
             Province         Char(10);
           END-DS CustomerRecord;


     C/EJECT     //complier directive to force it to fill page
     C*                        ***   M A I N   R O U T I N E   ***                       *
      /FREE

          LowLimit = LowLimitIn;
          EXSR PrepareFiles;
          Write ReportHdg;
          Write RColumns;
          EXSR GetRow;
          Write NewProv;
          ProvinceH = Province;  //control break
          DOW NOT EndOfFile;
              IF *IN01 = *ON;
                  Write ReportHDG;
                  Write RColumns;
                  *IN01 = *OFF;
              ENDIF;

              // Province may change

                 IF ProvinceH = Province;
                   Write Detail;
                   *IN01 = *OFF;
                 ELSE;
                   ProvinceH = Province;
                   Write Totals;
                   TotalPurch = 0;
                   Write NewProv;
                   Write Detail;
                 ENDIF;

              TotalPurch     = TotalPurch     + Purchase;
              TotalRecords= TotalRecords + 1;
              EXSR GetRow;
          ENDDO;
          Write Totals;
          EXSR   WRAPUP;
          Write UnderLimit;
          *INLR = *ON;
          RETURN;
        // O P E N F I L E S   S U B R O U T I N E
         BEGSR  PrepareFiles;
        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  S T R U C T U R E
         EXEC SQL
           Declare ALLPROVCURSOR CURSOR
           FOR
           SELECT    CUSTID,TRIM(FNAME) || ' ' || LNAME AS FULLNAME,
                     CITY, PURCHASE, PDATE,
                     'Ontario' AS PROVINCE
           FROM      BCI433LIB/ONTARIO
           WHERE     PURCHASE > :LowLimit
           UNION ALL
           SELECT    CUSTID, TRIM(FNAME) || ' ' || LNAME AS FULLNAME,
                     CITY, PURCHASE, PDATE,
                     'Quebec' AS PROVINCE
           FROM      BCI433LIB/QUEBEC
           WHERE     PURCHASE > :LowLimit
           UNION ALL
           SELECT    CUSTID, TRIM(FNAME) || ' ' || LNAME AS FULLNAME,
                     CITY, PURCHASE, PDATE,
                     'Manitoba' AS PROVINCE
           FROM      BCI433LIB/MANITOBA
           WHERE     PURCHASE > :LowLimit;

        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D

         EXEC SQL
             OPEN ALLPROVCURSOR;

           IF SQLCODE <> 0 OR SQLWN0 = 'W';
             EndOfFile = *ON;
           ENDIF;


           ENDSR;

        //   G E T     R O W    S U B R O U T I N E
           BEGSR     GETROW;
             EXEC SQL
               FETCH NEXT
               FROM ALLPROVCURSOR
               INTO :CustomerRecord;

               IF SQLCODE <> 0 OR SQLWN0 = 'W';
                 EndOfFile = *ON;
               ENDIF;

           ENDSR;


       // W R A P U P     S U B R O U T I N E

          BEGSR WRAPUP;
        EXEC SQL
          CLOSE ALLPROVCURSOR;

          IF SQLCODE <> 0 OR SQLWN0 = 'W';
            EndOfFile = *ON;   //problem with the naming of the cursor
          ENDIF;               //could put feedback here

        EXEC SQL
          SELECT COUNT(*) INTO :OntTotal
          FROM   BCI433LIB/ONTARIO
          WHERE  PURCHASE <= :LowLimit;

          IF SQLCODE <> 0 OR SQLWN0 = 'W';
             OntTotal = -9999;
          ENDIF;

        EXEC SQL
          SELECT COUNT(*) INTO :QueTotal
          FROM   BCI433LIB/QUEBEC
          WHERE  PURCHASE <= :LowLimit;

          IF SQLCODE <> 0 OR SQLWN0 = 'W';
             QueTotal = -9999;
          ENDIF;

        EXEC SQL
          SELECT COUNT(*) INTO :ManTotal
          FROM   BCI433LIB/MANITOBA
          WHERE  PURCHASE <= :LowLimit;

          IF SQLCODE <> 0 OR SQLWN0 = 'W';
             ManTotal = -9999;
          ENDIF;

          ENDSR;

                                                                           
