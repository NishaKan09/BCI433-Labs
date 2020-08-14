 Ctl-Opt NoMain DatFmt(*USA);

      /COPY LAB11,DATEPROTOS

       DCL-Proc DayOfWeek EXPORT;
         DCL-Pi *N Zoned(1);
           WorkDate Date;
         END-PI;

         // Any Sunday can be set to the date of ANY valid Sunday

         DCL-S AnySunday Date INZ(D'04/02/1995');
         DCL-S WorkNum Packed(7);
         DCL-S WorkDay Zoned(1);

         WorkNum = %ABS(%Diff(WorkDate:AnySunday:*D));
         WorkDay = %Rem(WorkNum:7); //remainder

         If WorkDay = 0;
           WorkDay = 7;
         ENDIF;

         Return WorkDay;

       END-PROC DayOfWeek;

       DCL-Proc DayName EXPORT;
          Dcl-Pi *N CHAR(9) ;
           DateIn Date;
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

          Return DayArray(DayOfWeek(DateIn));

       END-PROC DayName;

       DCL-Proc DateWords EXPORT;
         Dcl-Pi *N CHAR(28) ;
           WorkDate Date;
         End-PI;

         DCL-DS MonthData;
              *n Char(9) Inz('January');
              *n Char(9) Inz('February');
              *n Char(9) Inz('March');
              *n Char(9) Inz('April');
              *n Char(9) Inz('May');
              *n Char(9) Inz('June');
              *n Char(9) Inz('July');
              *n Char(9) Inz('August');
              *n Char(9) Inz('September');
              *n Char(9) Inz('October');
              *n Char(9) Inz('November');
              *n Char(9) Inz('December');

              MonthArray Char(9) Dim(12) Pos(1);

          End-DS;
            DCL-S DateChar Char(30);
            DateChar = %Char(WorkDate: *USA);

          Return %Trim(DayName(WorkDate)) + ' ' +
                 %Trim(MonthArray(%Dec(%Subst(DateChar:1:2):2:0))) + ' ' +
                 %Subst(DateChar:4:2) + ', ' +
                 %Subst(DateChar:7:4);
       END-PROC DateWords;

                                            
