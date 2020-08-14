          DCL-f DayDsp Workstn;
          Dcl-PI  Main  extPgm('DAYSRPG');
             Solution   char(15);
         End-PI;
      // COPY THE PROTOTYPE HERE
      /COPY LAB10INTRO,DAYPROTO
        //Source file name, member name
           EXFMT INPUT;
           DOW NOT(*IN03);
              DayName = DayNumName(DayIn);
              *in99 = *on;
               WRITE INPUT;
               EXFMT OUTPUT;
              *in99 = *off;
               IF *IN03 = '0';
                 DayIn = 0;
                 EXFMT INPUT ;
               ENDIF;
            ENDDO;
            *INLR = *ON;
            RETURN;



                                  
