 // DatFmt used to ensure that *USA is the default for all date fields

       Ctl-Opt  DatFmt(*USA) ;

       Dcl-F  WhatDayDsp Workstn;

      /COPY LAB11,DATEPROTOS

          Dcl-S  WorkDay    Packed(1);
          Dcl-S  WorkDate   Date;



          EXFMT INPUT;

          Dow not (*IN03);
         // DayOfWeek is not an RPGLE function, it is a user defined function
            WorkDate = DateIn;
            WorkDay = DayOfWeek(WorkDate);

            Result1 = 'That is a ' + DayName(DateIn);
            Result2 = DateWords(WorkDate);


            *IN90 = *ON;
            WRITE INPUT;
            EXFMT OUTPUT;
            *IN90 = *Off;

            IF NOT (*IN03);
                EXFMT INPUT;
            ENDIF;
          EndDo;

       // User pressed F3 so set LR and exit

       *InLR = *On;
       Return;
                                                  
