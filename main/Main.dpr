program Main;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, DateUtils, Windows,
  Data in '..\units\Data.pas';

var
  vHead: PVacancy;
  cHead: PCandidate;
  pvHead: PPossibleVacancy;
  vIndex, cIndex: Integer;

procedure ClearConsole(const Position: Integer);
var
  cursor: COORD;
  r: cardinal;
begin
  r := 10000;
  cursor.X := 0;
  cursor.Y := Position;
  FillConsoleOutputCharacter(GetStdHandle(STD_OUTPUT_HANDLE), ' ', 80 * r,
    cursor, r);
  cursor.X := 0;
  cursor.Y := Position;
  SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursor);
end;

function CorrectRead(const First, Last: Integer): Integer;
var
  Input: String;
  Error: Integer;
  Correct: Boolean;
begin
  repeat
    ReadLn(Input);
    Val(Input, Result, Error);
    Correct := Result in [First .. Last];
    if (Error <> 0) or not Correct then
      WriteLn(ErrorMessage);
  until (Error = 0) and Correct;
end;

function CorrectInt: Integer;
var
  Input: String;
  Error: Integer;
begin
  repeat
    ReadLn(Input);
    Val(Input, Result, Error);
    if Error <> 0 then
      WriteLn(ErrorMessage);
  until Error = 0;
end;

procedure ReadFromFile(vHead: PVacancy; cHead: PCandidate);
var
  FVacancy: FileVacancy;
  FCandidate: FileCandidate;
  vTemp: PVacancy;
  vInfo: TVacancyInfo;
  cTemp: PCandidate;
  cInfo: TCandidateInfo;
begin
  Assign(FVacancy, 'ListOfVacancies');
  Reset(FVacancy);
  Read(FVacancy, vInfo);
  vIndex := vInfo.Index;
  vTemp := vHead;

  while not EOF(FVacancy) do
  begin
    New(vTemp^.Adr);
    Read(FVacancy, vInfo);
    vTemp := vTemp^.Adr;
    vTemp^.Info := vInfo;
    vTemp^.Adr := Nil;
  end;

  Assign(FCandidate, 'ListOfCandidates');
  Reset(FCandidate);
  Read(FCandidate, cInfo);
  cIndex := cInfo.Index;
  cTemp := cHead;

  while not EOF(FCandidate) do
  begin
    New(cTemp^.Adr);
    Read(FCandidate, cInfo);
    cTemp := cTemp^.Adr;
    cTemp^.Info := cInfo;
    cTemp^.Adr := Nil;
  end;
end;

procedure WriteInFile(vHead: PVacancy; cHead: PCandidate;
  pvHead: PPossibleVacancy);
var
  FVacancy: FileVacancy;
  FCandidate: FileCandidate;
  FPossibleVacancy: TextFile;
  vTemp: PVacancy;
  vInfo: TVacancyInfo;
  cTemp: PCandidate;
  cInfo: TCandidateInfo;
  pvTemp: PPossibleVacancy;
begin
  Assign(FVacancy, 'ListOfVacancies');
  ReWrite(FVacancy);
  vInfo.Index := vIndex;
  Write(FVacancy, vInfo);
  vTemp := vHead;
  while vTemp^.Adr <> nil do
  begin
    vTemp := vTemp^.Adr;
    Write(FVacancy, vTemp^.Info);
  end;

  CloseFile(FVacancy);

  Assign(FCandidate, 'ListOfCandidates');
  ReWrite(FCandidate);
  cInfo.Index := cIndex;
  Write(FCandidate, cInfo);
  cTemp := cHead;
  while cTemp^.Adr <> nil do
  begin
    cTemp := cTemp^.Adr;
    Write(FCandidate, cTemp^.Info);
  end;

  CloseFile(FCandidate);

  Assign(FPossibleVacancy, 'ListOfPossibleCandidates.txt');
  ReWrite(FPossibleVacancy);
  pvTemp := pvHead;
  while pvTemp^.Adr <> nil do
  begin
    pvTemp := pvTemp^.Adr;
    with pvTemp.Info do
      WriteLn(FPossibleVacancy, '|', Index:12, '|', Firm:12, '|',
        Specialization:12, '|', Post:12, '|', Salary:12, '|', Vacation:12, '|',
        HighEdu:12, '|', RangeAge[min], '-', RangeAge[max]);
  end;

  CloseFile(FPossibleVacancy);

end;

function HaveHighEdu: Boolean;
var
  Input: String;
begin
  Result := False;
  repeat
    ReadLn(Input);
    Input := LowerCase(Trim(Input));
    if Input = 'да' then
      Result := True
    else if Input = 'нет' then
      Result := False
    else
      WriteLn(ErrorMessage);
  until (Input = 'да') or (Input = 'нет');
end;

function HaveToStr(var Input: Boolean): String;
begin
  if Input then
    Result := 'Да'
  else
    Result := 'Нет';
end;

function ReadBirthDate: TDateTime;
var
  Year, Month, Day: Integer;
  VisYear: Boolean;
  MaxDaysInMonth: Integer;
begin
  repeat
    WriteLn('Введите год рождения (от 1900 до ', YearOf(Now), ')');
    Year := CorrectInt;
    if (Year < 1900) or (Year > YearOf(Now)) then
      WriteLn(ErrorMessage);
  until (Year >= 1900) and (Year <= YearOf(Now));

  repeat
    WriteLn('Введите месяц рождения (1-12)');
    Month := CorrectInt;
    if (Month < 1) or (Month > 12) then
      WriteLn(ErrorMessage);
  until (Month >= 1) and (Month <= 12);

  VisYear := IsLeapYear(Year);
  MaxDaysInMonth := MonthDays[VisYear, Month];

  repeat
    WriteLn('Введите день рождения (1-', MaxDaysInMonth, ')');
    Day := CorrectInt;
    if (Day < 1) or (Day > MaxDaysInMonth) then
      WriteLn(ErrorMessage);
  until (Day >= 1) and (Day <= MaxDaysInMonth);

  Result := EncodeDate(Year, Month, Day);
end;

procedure AddData(vHead: PVacancy; cHead: PCandidate);
var
  Choice, Count, I: Integer;
  vTemp: PVacancy;
  cTemp: PCandidate;
begin
  WriteLn(AddText);
  Choice := CorrectRead(1, 4);
  vTemp := vHead;
  cTemp := cHead;
  case Choice of
    1:
      begin
        while vTemp.Adr <> nil do
          vTemp := vTemp^.Adr;
        New(vTemp^.Adr);
        vTemp := vTemp^.Adr;
        with vTemp^.Info do
        begin
          WriteLn('Введите название фирмы');
          ReadLn(Firm);
          Trim(String(Firm));
          WriteLn('Введите специализацию');
          ReadLn(Specialization);
          Trim(String(Specialization));
          WriteLn('Введите должность');
          ReadLn(Post);
          Trim(String(Post));
          WriteLn('Введите оклад');
          Salary := CorrectInt;
          WriteLn('Введите количество дней отпуска');
          Vacation := CorrectInt;
          WriteLn('Введите наличие высшего образования (да/нет)');
          HighEdu := HaveHighEdu;
          WriteLn('Введите нижнюю границу возрастного диапазона');
          ReadLn(RangeAge[min]);
          WriteLn('Введите верхнюю границу возрастного диапазона');
          ReadLn(RangeAge[max]);
          Index := vIndex;
          Inc(vIndex);
        end;
        WriteLn(SuccessMessage);
        vTemp^.Adr := nil;
      end;
    2:
      begin
        while cTemp.Adr <> nil do
          cTemp := cTemp^.Adr;
        New(cTemp^.Adr);
        cTemp := cTemp^.Adr;
        with cTemp^.Info do
        begin
          WriteLn('Введите ФИО');
          ReadLn(FIO);
          Trim(String(FIO));
          BirthDay := ReadBirthDate;
          WriteLn('Введите специальность');
          ReadLn(Specialization);
          Trim(String(Specialization));
          WriteLn('Введите должность');
          ReadLn(Post);
          Trim(String(Post));
          WriteLn('Введите оклад');
          Salary := CorrectInt;
          WriteLn('Введите наличие высшего образования (да/нет)');
          HighEdu := HaveHighEdu;
          Index := cIndex;
          Inc(cIndex);
        end;
        WriteLn(SuccessMessage);
        cTemp^.Adr := nil;
      end;
    3:
      begin
        WriteLn('Введите количество записей');
        Count := CorrectInt;
        for I := 1 to Count do
        begin
          while vTemp.Adr <> nil do
            vTemp := vTemp^.Adr;
          New(vTemp^.Adr);
          vTemp := vTemp^.Adr;
          with vTemp^.Info do
          begin
            Firm := ShortString(TFirm[Random(7)]);
            Specialization := ShortString(TSpecialization[Random(10)]);
            Post := ShortString(TSpecialization[Random(10)]);
            Salary := TSalary[Random(6)];
            Vacation := TVacation[Random(5)];
            HighEdu := Bool(Random(2));
            RangeAge[min] := TAge[Random(3)];
            RangeAge[max] := TAge[Random(3) + 3];
            Index := vIndex;
            Inc(vIndex);
          end;
          vTemp^.Adr := nil;
        end;
        WriteLn(SuccessMessage);
      end;
    4:
      begin
        WriteLn('Введите количество записей');
        Count := CorrectInt;
        for I := 1 to Count do
        begin
          while cTemp.Adr <> nil do
            cTemp := cTemp^.Adr;
          New(cTemp^.Adr);
          cTemp := cTemp^.Adr;
          with cTemp^.Info do
          begin
            FIO := ShortString(TSurName[Random(5)] + ' ' + TName[Random(6)] + ' ' +
              TOtch[Random(6)]);
            BirthDay := Random(22000) + 15000;
            Specialization := ShortString(TSpecialization[Random(10)]);
            Post := ShortString(TSpecialization[Random(10)]);
            Salary := TSalary[Random(6)];
            HighEdu := Bool(Random(2));
            Index := cIndex;
            Inc(cIndex);
          end;
          cTemp^.Adr := nil;
        end;
        WriteLn(SuccessMessage);
      end;
  end;
  WriteLn(ContinueMessage);
  ReadLn;
end;

function SearchData(vHead: PVacancy; cHead: PCandidate): Integer;
var
  Choice, KeyInt: Integer;
  KeyStr: String;
  KeyDate: TDateTime;
  KeyEdu, IsFound: Boolean;
  KeyRange: TRangeAge;
  vTemp: PVacancy;
  cTemp: PCandidate;
begin
  WriteLn(SearchText);
  Choice := CorrectRead(1, 2);
  Result := Choice;

  WriteLn(ContinueMessage);
  ReadLn;
  ClearConsole(0);

  case Choice of
    1:
      begin
        WriteLn(SearchMessageV);
        Choice := CorrectRead(1, 8);

        WriteLn(ContinueMessage);
        ReadLn;
        ClearConsole(0);

        IsFound := False;

        WriteLn('Введите содержание поля');

        vTemp := vHead;
        case Choice of
          1:
            begin
              KeyInt := CorrectInt;
              while vTemp^.Adr <> nil do
              begin
                vTemp := vTemp^.Adr;
                with vTemp^.Info do
                  if Index = KeyInt then
                  begin
                    if not IsFound then
                      WriteLn(HeadVacancyList);
                    Write(HorizLineV);
                    WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19,
                      '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
                      HaveToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineV);
            end;
          2:
            begin
              ReadLn(KeyStr);
              while vTemp^.Adr <> nil do
              begin
                vTemp := vTemp^.Adr;
                with vTemp^.Info do
                  if String(Firm) = KeyStr then
                  begin
                    if not IsFound then
                      WriteLn(HeadVacancyList);
                    Write(HorizLineV);
                    WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19,
                      '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
                      HaveToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineV);
            end;
          3:
            begin
              ReadLn(KeyStr);
              while vTemp^.Adr <> nil do
              begin
                vTemp := vTemp^.Adr;
                with vTemp^.Info do
                  if String(Specialization) = KeyStr then
                  begin
                    if not IsFound then
                      WriteLn(HeadVacancyList);
                    Write(HorizLineV);
                    WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19,
                      '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
                      HaveToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineV);
            end;
          4:
            begin
              ReadLn(KeyStr);
              while vTemp^.Adr <> nil do
              begin
                vTemp := vTemp^.Adr;
                with vTemp^.Info do
                  if String(Post) = KeyStr then
                  begin
                    if not IsFound then
                      WriteLn(HeadVacancyList);
                    Write(HorizLineV);
                    WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19,
                      '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
                      HaveToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineV);
            end;
          5:
            begin
              KeyInt := CorrectInt;
              while vTemp^.Adr <> nil do
              begin
                vTemp := vTemp^.Adr;
                with vTemp^.Info do
                  if Salary = KeyInt then
                  begin
                    if not IsFound then
                      WriteLn(HeadVacancyList);
                    Write(HorizLineV);
                    WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19,
                      '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
                      HaveToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineV);
            end;
          6:
            begin
              KeyInt := CorrectInt;
              while vTemp^.Adr <> nil do
              begin
                vTemp := vTemp^.Adr;
                with vTemp^.Info do
                  if Vacation = KeyInt then
                  begin
                    if not IsFound then
                      WriteLn(HeadVacancyList);
                    Write(HorizLineV);
                    WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19,
                      '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
                      HaveToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineV);
            end;
          7:
            begin
              KeyEdu := HaveHighEdu;
              while vTemp^.Adr <> nil do
              begin
                vTemp := vTemp^.Adr;
                with vTemp^.Info do
                  if HighEdu = KeyEdu then
                  begin
                    if not IsFound then
                      WriteLn(HeadVacancyList);
                    Write(HorizLineV);
                    WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19,
                      '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
                      HaveToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineV);
            end;
          8:
            begin
              WriteLn('Введите нижнюю границу возрастного диапазона');
              ReadLn(KeyRange[min]);
              WriteLn('Введите верхнюю границу возрастного диапазона');
              ReadLn(KeyRange[max]);
              while vTemp^.Adr <> nil do
              begin
                vTemp := vTemp^.Adr;
                with vTemp^.Info do
                  if (KeyRange[min] = RangeAge[min]) and
                    (KeyRange[max] = RangeAge[max]) then
                  begin
                    if not IsFound then
                      WriteLn(HeadVacancyList);
                    Write(HorizLineV);
                    WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19,
                      '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
                      HaveToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineV);
            end;
        end;
      end;
    2:
      begin
        WriteLn(SearchMessageС);
        Choice := CorrectRead(1, 7);

        WriteLn(ContinueMessage);
        ReadLn;
        ClearConsole(0);

        IsFound := False;

        WriteLn('Введите содержание поля');

        cTemp := cHead;
        case Choice of
          1:
            begin
              KeyInt := CorrectInt;
              while cTemp^.Adr <> nil do
              begin
                cTemp := cTemp^.Adr;
                with cTemp^.Info do
                  if Index = KeyInt then
                  begin
                    if not IsFound then
                      WriteLn(HeadCandidateList);
                    Write(HorizLineC);
                    WriteLn('|', Index:5, '|', FIO:32, '|', DateToStr(BirthDay)
                      :13, '|', Specialization:19, '|', Post:13, '|', Salary:9,
                      '|', HaveToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineC);
            end;
          2:
            begin
              ReadLn(KeyStr);
              while cTemp^.Adr <> nil do
              begin
                cTemp := cTemp^.Adr;
                with cTemp^.Info do
                  if String(FIO) = KeyStr then
                  begin
                    if not IsFound then
                      WriteLn(HeadCandidateList);
                    Write(HorizLineC);
                    WriteLn('|', Index:5, '|', FIO:32, '|', DateToStr(BirthDay)
                      :13, '|', Specialization:19, '|', Post:13, '|', Salary:9,
                      '|', HaveToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineC);
            end;
          3:
            begin
              KeyDate := ReadBirthDate;
              while cTemp^.Adr <> nil do
              begin
                cTemp := cTemp^.Adr;
                with cTemp^.Info do
                  if BirthDay = KeyDate then
                  begin
                    if not IsFound then
                      WriteLn(HeadCandidateList);
                    Write(HorizLineC);
                    WriteLn('|', Index:5, '|', FIO:32, '|', DateToStr(BirthDay)
                      :13, '|', Specialization:19, '|', Post:13, '|', Salary:9,
                      '|', HaveToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineC);
            end;
          4:
            begin
              ReadLn(KeyStr);
              while cTemp^.Adr <> nil do
              begin
                cTemp := cTemp^.Adr;
                with cTemp^.Info do
                  if String(Specialization) = KeyStr then
                  begin
                    if not IsFound then
                      WriteLn(HeadCandidateList);
                    Write(HorizLineC);
                    WriteLn('|', Index:5, '|', FIO:32, '|', DateToStr(BirthDay)
                      :13, '|', Specialization:19, '|', Post:13, '|', Salary:9,
                      '|', HaveToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineC);
            end;
          5:
            begin
              ReadLn(KeyStr);
              while cTemp^.Adr <> nil do
              begin
                cTemp := cTemp^.Adr;
                with cTemp^.Info do
                  if String(Post) = KeyStr then
                  begin
                    if not IsFound then
                      WriteLn(HeadCandidateList);
                    Write(HorizLineC);
                    WriteLn('|', Index:5, '|', FIO:32, '|', DateToStr(BirthDay)
                      :13, '|', Specialization:19, '|', Post:13, '|', Salary:9,
                      '|', HaveToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineC);
            end;
          6:
            begin
              KeyInt := CorrectInt;
              while cTemp^.Adr <> nil do
              begin
                cTemp := cTemp^.Adr;
                with cTemp^.Info do
                  if Salary = KeyInt then
                  begin
                    if not IsFound then
                      WriteLn(HeadCandidateList);
                    Write(HorizLineC);
                    WriteLn('|', Index:5, '|', FIO:32, '|', DateToStr(BirthDay)
                      :13, '|', Specialization:19, '|', Post:13, '|', Salary:9,
                      '|', HaveToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineC);
            end;
          7:
            begin
              KeyEdu := HaveHighEdu;
              while cTemp^.Adr <> nil do
              begin
                cTemp := cTemp^.Adr;
                with cTemp^.Info do
                  if HighEdu = KeyEdu then
                  begin
                    if not IsFound then
                      WriteLn(HeadCandidateList);
                    Write(HorizLineC);
                    WriteLn('|', Index:5, '|', FIO:32, '|', DateToStr(BirthDay)
                      :13, '|', Specialization:19, '|', Post:13, '|', Salary:9,
                      '|', HaveToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
                WriteLn(NotFoundMessage)
              else
                Write(HorizLineC);
            end;
        end;
      end;
  end;
end;

procedure DeleteData(vHead: PVacancy; cHead: PCandidate);
var
  Index, Choice: Integer;
  IsDeleted: Boolean;
  vTempCurr, vTempPrev: PVacancy;
  cTempCurr, cTempPrev: PCandidate;
begin
  Choice := SearchData(vHead, cHead);
  WriteLn('Введите индекс записи для удаления');
  Index := CorrectInt;
  IsDeleted := False;
  case Choice of
    1:
      begin
        vTempCurr := vHead;
        vTempPrev := nil;
        while (vTempCurr <> nil) and not IsDeleted do
        begin
          if (vTempCurr^.Info.Index = Index) and (vTempCurr <> vHead) then
          begin
            if vTempPrev = nil then
              vHead := vTempCurr^.Adr
            else
              vTempPrev^.Adr := vTempCurr^.Adr;
            Dispose(vTempCurr);
            IsDeleted := True;
          end;
          if not IsDeleted then
          begin
            vTempPrev := vTempCurr;
            vTempCurr := vTempCurr^.Adr;
          end;
        end;
        if IsDeleted then
          WriteLn(SuccessMessage)
        else
          WriteLn('Запись не найдена');
      end;
    2:
      begin
        cTempCurr := cHead;
        cTempPrev := nil;
        while (cTempCurr <> nil) and not IsDeleted do
        begin
          if (cTempCurr^.Info.Index = Index) and (cTempCurr <> cHead) then
          begin
            if cTempPrev = nil then
              cHead := cTempCurr^.Adr
            else
              cTempPrev^.Adr := cTempCurr^.Adr;
            Dispose(cTempCurr);
            IsDeleted := True;
          end;
          if not IsDeleted then
          begin
            cTempPrev := cTempCurr;
            cTempCurr := cTempCurr^.Adr;
          end;
        end;
        if IsDeleted then
          WriteLn(SuccessMessage)
        else
          WriteLn('Запись не найдена');
      end;
  end;
end;

procedure EditData(vHead: PVacancy; cHead: PCandidate);
var
  Choice, Index, KeyInt: Integer;
  IsFound, KeyEdu: Boolean;
  KeyDate: TDateTime;
  KeyRange: TRangeAge;
  vTemp: PVacancy;
  cTemp: PCandidate;
begin
  Choice := SearchData(vHead, cHead);
  WriteLn('Введите индекс записи для редактирования');
  Index := CorrectInt;

  IsFound := False;

  vTemp := vHead;
  cTemp := cHead;

  case Choice of
    1:
      while (vTemp.Adr <> nil) and not IsFound do
      begin
        vTemp := vTemp^.Adr;
        if vTemp^.Info.Index = Index then
          IsFound := True;
      end;
    2:
      while (cTemp.Adr <> nil) and not IsFound do
      begin
        cTemp := cTemp^.Adr;
        if cTemp^.Info.Index = Index then
          IsFound := True;
      end;
  end;

  if IsFound then
  begin
    case Choice of
      1:
        begin
          WriteLn(EditMessageV);
          Choice := CorrectRead(1, 7);

          WriteLn('Введите новое содержание поля');
          with vTemp^.Info do
            case Choice of
              1:
                ReadLn(Firm);
              2:
                ReadLn(Specialization);
              3:
                ReadLn(Post);
              4:
                begin
                  KeyInt := CorrectInt;
                  Salary := KeyInt;
                end;
              5:
                begin
                  KeyInt := CorrectInt;
                  Vacation := KeyInt;
                end;
              6:
                begin
                  KeyEdu := HaveHighEdu;
                  HighEdu := KeyEdu;
                end;
              7:
                begin
                  WriteLn('Введите нижнюю границу возрастного диапазона');
                  ReadLn(KeyRange[min]);
                  WriteLn('Введите верхнюю границу возрастного диапазона');
                  ReadLn(KeyRange[max]);
                  RangeAge[min] := KeyRange[min];
                  RangeAge[max] := KeyRange[max];
                end;
            end;

          WriteLn(SuccessMessage);
        end;
      2:
        begin
          WriteLn(EditMessageС);
          Choice := CorrectRead(1, 6);

          WriteLn('Введите новое содержание поля');
          with cTemp^.Info do
            case Choice of
              1:
                ReadLn(FIO);
              2:
                begin
                  KeyDate := ReadBirthDate;
                  BirthDay := KeyDate;
                end;
              3:
                ReadLn(Specialization);
              4:
                ReadLn(Post);
              5:
                begin
                  KeyInt := CorrectInt;
                  Salary := KeyInt;
                end;
              6:
                begin
                  KeyEdu := HaveHighEdu;
                  HighEdu := KeyEdu;
                end;
            end;

          WriteLn(SuccessMessage);
        end;
    end;
  end
  else
    WriteLn(NotFoundMessage);
  WriteLn(ContinueMessage);
  ReadLn;
end;

procedure ShowList(vHead: PVacancy; cHead: PCandidate);
var
  Choice: Integer;
  vTemp: PVacancy;
  cTemp: PCandidate;
begin
  WriteLn(ShowText);
  Choice := CorrectRead(1, 2);
  WriteLn(ContinueMessage);
  ReadLn;
  ClearConsole(0);
  case Choice of
    1:
      begin
        WriteLn(HeadVacancyList);
        vTemp := vHead;
        while vTemp^.Adr <> nil do
        begin
          vTemp := vTemp^.Adr;
          Write(HorizLineV);
          with vTemp^.Info do
            WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19, '|',
              Post:15, '|', Salary:11, '|', Vacation:12, '|', HaveToStr(HighEdu)
              :18, '|', RangeAge[min]:10, '-', RangeAge[max], '|');
        end;
        WriteLn(HorizLineV);
        WriteLn(ContinueMessage);
        ReadLn;
      end;
    2:
      begin
        WriteLn(HeadCandidateList);
        cTemp := cHead;
        while cTemp^.Adr <> nil do
        begin
          cTemp := cTemp^.Adr;
          Write(HorizLineC);
          with cTemp^.Info do
            WriteLn('|', Index:5, '|', FIO:32, '|', DateToStr(BirthDay):13, '|',
              Specialization:19, '|', Post:13, '|', Salary:9, '|',
              HaveToStr(HighEdu):18, '|');
        end;
        WriteLn(HorizLineC);
        WriteLn(ContinueMessage);
        ReadLn;
      end;
  end;
end;

procedure SortData(vHead: PVacancy; cHead: PCandidate);
var
  Choice: Integer;
  vCurr, vNext, vTemp: PVacancy;
  cCurr, cNext, cTemp: PCandidate;
begin
  WriteLn(SortText);
  Choice := CorrectRead(1, 2);

  WriteLn(ContinueMessage);
  ReadLn;
  ClearConsole(0);

  case Choice of
    1:
      begin
        WriteLn(SortMessageV);
        Choice := CorrectRead(1, 8);

        case Choice of
          1:
            begin
              vCurr := vHead^.Adr;
              vHead^.Adr := nil;
              while vCurr <> nil do
              begin
                vNext := vCurr^.Adr;
                vTemp := vHead;
                while (vTemp^.Adr <> nil) and
                  (vTemp^.Adr^.Info.Index < vCurr^.Info.Index) do
                  vTemp := vTemp^.Adr;
                vCurr^.Adr := vTemp^.Adr;
                vTemp^.Adr := vCurr;
                vCurr := vNext;
              end;
            end;
          2:
            begin
              vCurr := vHead^.Adr;
              vHead^.Adr := nil;
              while vCurr <> nil do
              begin
                vNext := vCurr^.Adr;
                vTemp := vHead;
                while (vTemp^.Adr <> nil) and
                  (vTemp^.Adr^.Info.Firm < vCurr^.Info.Firm) do
                  vTemp := vTemp^.Adr;
                vCurr^.Adr := vTemp^.Adr;
                vTemp^.Adr := vCurr;
                vCurr := vNext;
              end;
            end;
          3:
            begin
              vCurr := vHead^.Adr;
              vHead^.Adr := nil;
              while vCurr <> nil do
              begin
                vNext := vCurr^.Adr;
                vTemp := vHead;
                while (vTemp^.Adr <> nil) and
                  (vTemp^.Adr^.Info.Specialization <
                  vCurr^.Info.Specialization) do
                  vTemp := vTemp^.Adr;
                vCurr^.Adr := vTemp^.Adr;
                vTemp^.Adr := vCurr;
                vCurr := vNext;
              end;
            end;
          4:
            begin
              vCurr := vHead^.Adr;
              vHead^.Adr := nil;
              while vCurr <> nil do
              begin
                vNext := vCurr^.Adr;
                vTemp := vHead;
                while (vTemp^.Adr <> nil) and
                  (vTemp^.Adr^.Info.Post < vCurr^.Info.Post) do
                  vTemp := vTemp^.Adr;
                vCurr^.Adr := vTemp^.Adr;
                vTemp^.Adr := vCurr;
                vCurr := vNext;
              end;
            end;
          5:
            begin
              vCurr := vHead^.Adr;
              vHead^.Adr := nil;
              while vCurr <> nil do
              begin
                vNext := vCurr^.Adr;
                vTemp := vHead;
                while (vTemp^.Adr <> nil) and
                  (vTemp^.Adr^.Info.Salary < vCurr^.Info.Salary) do
                  vTemp := vTemp^.Adr;
                vCurr^.Adr := vTemp^.Adr;
                vTemp^.Adr := vCurr;
                vCurr := vNext;
              end;
            end;
          6:
            begin
              vCurr := vHead^.Adr;
              vHead^.Adr := nil;
              while vCurr <> nil do
              begin
                vNext := vCurr^.Adr;
                vTemp := vHead;
                while (vTemp^.Adr <> nil) and
                  (vTemp^.Adr^.Info.Vacation < vCurr^.Info.Vacation) do
                  vTemp := vTemp^.Adr;
                vCurr^.Adr := vTemp^.Adr;
                vTemp^.Adr := vCurr;
                vCurr := vNext;
              end;
            end;
          7:
            begin
              vCurr := vHead^.Adr;
              vHead^.Adr := nil;
              while vCurr <> nil do
              begin
                vNext := vCurr^.Adr;
                vTemp := vHead;
                while (vTemp^.Adr <> nil) and
                  (vTemp^.Adr^.Info.HighEdu < vCurr^.Info.HighEdu) do
                  vTemp := vTemp^.Adr;
                vCurr^.Adr := vTemp^.Adr;
                vTemp^.Adr := vCurr;
                vCurr := vNext;
              end;
            end;
          8:
            begin
              vCurr := vHead^.Adr;
              vHead^.Adr := nil;
              while vCurr <> nil do
              begin
                vNext := vCurr^.Adr;
                vTemp := vHead;
                while (vTemp^.Adr <> nil) and
                  (vTemp^.Adr^.Info.RangeAge[min] <
                  vCurr^.Info.RangeAge[min]) do
                  vTemp := vTemp^.Adr;
                vCurr^.Adr := vTemp^.Adr;
                vTemp^.Adr := vCurr;
                vCurr := vNext;
              end;
            end;
        end;

        WriteLn(SuccessMessage);
        WriteLn(ContinueMessage);
        ReadLn;
      end;
    2:
      begin
        WriteLn(SortMessageС);
        Choice := CorrectRead(1, 7);

        case Choice of
          1:
            begin
              cCurr := cHead^.Adr;
              cHead^.Adr := nil;
              while cCurr <> nil do
              begin
                cNext := cCurr^.Adr;
                cTemp := cHead;
                while (cTemp^.Adr <> nil) and
                  (cTemp^.Adr^.Info.Index < cCurr^.Info.Index) do
                  cTemp := cTemp^.Adr;
                cCurr^.Adr := cTemp^.Adr;
                cTemp^.Adr := cCurr;
                cCurr := cNext;
              end;
            end;
          2:
            begin
              cCurr := cHead^.Adr;
              cHead^.Adr := nil;
              while cCurr <> nil do
              begin
                cNext := cCurr^.Adr;
                cTemp := cHead;
                while (cTemp^.Adr <> nil) and
                  (cTemp^.Adr^.Info.FIO < cCurr^.Info.FIO) do
                  cTemp := cTemp^.Adr;
                cCurr^.Adr := cTemp^.Adr;
                cTemp^.Adr := cCurr;
                cCurr := cNext;
              end;
            end;
          3:
            begin
              cCurr := cHead^.Adr;
              cHead^.Adr := nil;
              while cCurr <> nil do
              begin
                cNext := cCurr^.Adr;
                cTemp := cHead;
                while (cTemp^.Adr <> nil) and
                  (cTemp^.Adr^.Info.BirthDay < cCurr^.Info.BirthDay) do
                  cTemp := cTemp^.Adr;
                cCurr^.Adr := cTemp^.Adr;
                cTemp^.Adr := cCurr;
                cCurr := cNext;
              end;
            end;
          4:
            begin
              cCurr := cHead^.Adr;
              cHead^.Adr := nil;
              while cCurr <> nil do
              begin
                cNext := cCurr^.Adr;
                cTemp := cHead;
                while (cTemp^.Adr <> nil) and
                  (cTemp^.Adr^.Info.Specialization <
                  cCurr^.Info.Specialization) do
                  cTemp := cTemp^.Adr;
                cCurr^.Adr := cTemp^.Adr;
                cTemp^.Adr := cCurr;
                cCurr := cNext;
              end;
            end;
          5:
            begin
              cCurr := cHead^.Adr;
              cHead^.Adr := nil;
              while cCurr <> nil do
              begin
                cNext := cCurr^.Adr;
                cTemp := cHead;
                while (cTemp^.Adr <> nil) and
                  (cTemp^.Adr^.Info.Post < cCurr^.Info.Post) do
                  cTemp := cTemp^.Adr;
                cCurr^.Adr := cTemp^.Adr;
                cTemp^.Adr := cCurr;
                cCurr := cNext;
              end;
            end;
          6:
            begin
              cCurr := cHead^.Adr;
              cHead^.Adr := nil;
              while cCurr <> nil do
              begin
                cNext := cCurr^.Adr;
                cTemp := cHead;
                while (cTemp^.Adr <> nil) and
                  (cTemp^.Adr^.Info.Salary < cCurr^.Info.Salary) do
                  cTemp := cTemp^.Adr;
                cCurr^.Adr := cTemp^.Adr;
                cTemp^.Adr := cCurr;
                cCurr := cNext;
              end;
            end;
          7:
            begin
              cCurr := cHead^.Adr;
              cHead^.Adr := nil;
              while cCurr <> nil do
              begin
                cNext := cCurr^.Adr;
                cTemp := cHead;
                while (cTemp^.Adr <> nil) and
                  (cTemp^.Adr^.Info.HighEdu < cCurr^.Info.HighEdu) do
                  cTemp := cTemp^.Adr;
                cCurr^.Adr := cTemp^.Adr;
                cTemp^.Adr := cCurr;
                cCurr := cNext;
              end;
            end;
        end;

        WriteLn(SuccessMessage);
        WriteLn(ContinueMessage);
        ReadLn;
      end;
  end;
end;

procedure NewHead(var vHead: PVacancy; var cHead: PCandidate;
  var pvHead: PPossibleVacancy);
begin
  New(vHead);
  vHead^.Adr := nil;
  New(cHead);
  cHead^.Adr := nil;
  New(pvHead);
  pvHead^.Adr := nil;
end;

procedure DisposeHead(vHead: PVacancy; cHead: PCandidate;
  pvHead: PPossibleVacancy);
var
  vTemp: PVacancy;
  cTemp: PCandidate;
  pvTemp: PPossibleVacancy;
begin
  vTemp := vHead^.Adr;
  while vTemp <> nil do
  begin
    vHead^.Adr := vTemp^.Adr;
    Dispose(vTemp);
    vTemp := vHead^.Adr;
  end;
  Dispose(vHead);

  cTemp := cHead^.Adr;
  while cTemp <> nil do
  begin
    cHead^.Adr := cTemp^.Adr;
    Dispose(cTemp);
    cTemp := cHead^.Adr;
  end;
  Dispose(cHead);

  pvTemp := pvHead^.Adr;
  while pvTemp <> nil do
  begin
    pvHead^.Adr := pvTemp^.Adr;
    Dispose(pvTemp);
    pvTemp := pvHead^.Adr;
  end;
  Dispose(pvHead);
end;

procedure Menu;
var
  Choice: Integer;
begin
  repeat
    WriteLn(HelloMessage);
    Choice := CorrectRead(1, 10);
    WriteLn(ContinueMessage);
    ReadLn;
    ClearConsole(0);
    case Choice of
      1:
        ReadFromFile(vHead, cHead);
      2:
        ShowList(vHead, cHead);
      3:
        SortData(vHead, cHead);
      4:
        begin
          SearchData(vHead, cHead);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      5:
        AddData(vHead, cHead);
      6:
        begin
          DeleteData(vHead, cHead);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      7:
        EditData(vHead, cHead);
      8:
        ;
      9:
        ;
      10:
        WriteInFile(vHead, cHead, pvHead);
    end;
    ClearConsole(0);
  until (Choice = 9) or (Choice = 10);
end;

begin
  Randomize;
  vIndex := 1;
  cIndex := 1;
  NewHead(vHead, cHead, pvHead);
  Menu;
  DisposeHead(vHead, cHead, pvHead);

end.
