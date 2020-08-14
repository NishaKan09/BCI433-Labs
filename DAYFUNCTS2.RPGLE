     //datfmt used to ensure USA is the default date
        Ctl-Opt NoMain DatFmt(*USA) ;

      // source for this dsp file in library
      /COPY LAB10INTRO,DAYPROTO

       Dcl-Proc DayNumName  EXPORT;
         //procedure interface
         Dcl-Pi *N CHAR(9) ;
           Number  Packed(1:0);
         End-PI;

          DCL-DS DayData;
              *n Char(9) Inz('Monday');
              *n Char(9) Inz('Tuesday');
              *n Char(9) Inz('Wednesday');
              *n Char(9) Inz('Thursday');
              *n Char(9) Inz('Friday');
              *n Char(9) Inz('Saturday');
              *n Char(9) Inz('Sunday');

              DayArray Char(9) Dim(7) Pos(1);

          End-DS;

          Return DayArray(Number);

        End-Proc;                                          
