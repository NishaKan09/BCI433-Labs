         // **************************************************************************
        //  CUSTOMER20 READ BY NATIVE LANGUAGE (ILE RPG)
        //  CONTACTS20 ROW RETRIEVED WITH EMBEDDED SQL
        //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER20 AND CONTACTS20
        //  SUMMARRY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS

           DCL-F PHNREPORT PRINTER OFLIND(*IN01) ;
           DCL-F CUSTOMER20 DISK(*EXT) KEYED USAGE(*INPUT)
                 RENAME(CUSTOMER20:CUSTR);
                      // data structure for host variables from CONTACTS20
                      DCL-DS CONTACTS20 EXT END-DS;

                     // Standalone fields for indicator variables
                     DCL-S INDLastCDate BINDEC(4:0);
                     DCL-S INDNextCDate BINDEC(4:0);


           DCL-S Dummy  Zoned(1);

        //**************************************************************************
        //*                        ***   M A I N   R O U T I N E   ***
        //**************************************************************************

                EXSR SummaryInfo;
                WRITE NEWPAGE;
                READ CUSTOMER20;
                DOW NOT %EOF;
                    EXSR SQLSelect;
                    IF *IN01 = *ON;
                       Write NEWPAGE;
                       *IN01 = *OFF;
                    ENDIF;
                    Write RPTLINE;
                   READ CUSTOMER20;
                ENDDO;
                Write SUMMARY;
                *INLR = *ON;
                RETURN;
        //**********************************************************************
        //   S Q L S E L E C T   S U B R O U T I N E
   //   //********************************************************************
   //                  BEGSR    SQLSelect ;
   //    // A row from the contacts table that has the same customer number as t
   //    // read from the CUSTOMER20 file is retrieved to find out the last date
   //    // phone number, comments and the salesperson number.
   //
   //    //  The call back interval is added to the last date called to determin
   //    //  next date to call.  Since null values may be stored in the last dat
   //    // indicator variables are used.

            EXEC SQL
              SELECT PHNLDC + PHNCIT DAYS, PHNLDC,
                     CSTPHN, PHNCOM, CSTSLN
              INTO   :NEXTCDATE :INDNEXTCDATE, :PHNLDC :INDLASTCDATE,
                     :CSTPHN, :PHNCOM, :CSTSLN
              FROM   BCI433LIB/CONTACTS20
              WHERE CSTNUM = :CSTNUM;

              SELECT;
                WHEN SQLSTATE = '00000';
                  DUMMY = 0;
                WHEN SQLSTATE = '02000';
                  CSTPHN      = 'NOT FOUND';
                  NEXTCDATE   = D'9999-09-09';
                  PHNLDC      = D'9999-09-09';
                  PHNCOM      = *ALL'*';
                  CSTSLN      = *ALL'*';
                WHEN %SUBST(SQLSTATE:1:2) = '01';
                  CSTPHN      = 'WARNING';
                  NEXTCDATE   = D'9999-09-09';
                  PHNLDC      = D'9999-09-09';
                  PHNCOM      = *ALL'*';
                  CSTSLN      = *ALL'*';
                OTHER;
                  CSTPHN      = 'ERROR';
                  NEXTCDATE   = D'9999-09-09';
                  PHNLDC      = D'9999-09-09';
                  PHNCOM      = *ALL'*';
                  CSTSLN      = *ALL'*';
              ENDSL;

              IF INDLASTCDATE = -1;
                CSTPHN = 'UNKNOWN DATE';
                NEXTCDATE = D'9999-09-09';
                PHNLDC = D'9999-09-09';
              ENDIF;

              IF PHNLDC = OLDESTDATE;
                HIGHLIGHT = '<-------';
              ELSE;
                HIGHLIGHT = '';
              ENDIF;

                         ENDSR ;
        //**********************************************************************
        // S U M M A R Y I N F O   S U B R O U T I N E
        //**********************************************************************
                         BEGSR  SummaryInfo;
        //  D E T E R M I N E   T O T A L S   F O R   CONTACTS20 & CUSTOMER20
        EXEC SQL
          SELECT   COUNT(*) INTO :CONTACTT
          FROM   BCI433LIB/CONTACTS20;

          IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
            CONTACTT = -99999;
          ENDIF;

        EXEC SQL
          SELECT   COUNT(*) INTO :CUSTOMERT
          FROM   BCI433LIB/CUSTOMER20;

          IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
            CUSTOMERT = -99999;
          ENDIF;

        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST   DATE CALLED
         EXEC SQL
           SELECT COUNT(*) INTO: UNKNOWNT
           FROM  BCI433LIB/CONTACTS20
           WHERE PHNLDC IS NULL;

           IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
             UNKNOWNT = -99999;
           ENDIF;

        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
          EXEC SQL
            SELECT MIN(PHNLDC) INTO :OLDESTDATE
            FROM   BCI433LIB/CONTACTS20;

          IF (SQLCODE <> 0) OR (SQLWN0 = 'W') AND (SQLWN2 <> 'W');
            OLDESTDATE = D'9999-09-09';
          ENDIF;

          EXEC SQL
            SELECT MAX(PHNLDC) INTO :MOSTRECENT
            FROM   BCI433LIB/CONTACTS20;

          IF (SQLCODE <> 0) OR (SQLWN0 = 'W') AND (SQLWN2 <> 'W');
            MOSTRECENT = D'9999-09-09';
          ENDIF;

       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A

          EXEC SQL
           SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER
           INTO  :USER, :TIMESTAMP,        :SERVER
           FROM  SYSIBM/SYSDUMMY1;
           // INFO FROM REGISTERS, NO NEED TO CHECK COMMUNICATIONS AREA
                         ENDSR;               
