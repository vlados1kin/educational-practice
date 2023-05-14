program Main;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, DateUtils, Windows,
  Data in '..\units\Data.pas';

var
  vHead: PVacancy;
  cHead: PCandidate;
  dHead, dTemp: PDeficit;
  pvHead, pvTemp: PPossibleVacancy;
  vIndex, cIndex, chMode: Integer;

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

function CorrectChoice(const First, Last: Integer): Integer;
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

function CorrectInteger: Integer;
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

function CorrectBirthDate: TDateTime;
var
  Year, Month, Day: Integer;
  LeapYear: Boolean;
  MaxDaysInMonth: Integer;
begin
  repeat
    WriteLn('Введите год рождения (1900-', YearOf(Now), ')');
    Year := CorrectInteger;
    if (Year < 1900) or (Year > YearOf(Now)) then
      WriteLn(ErrorMessage);
  until (Year >= 1900) and (Year <= YearOf(Now));

  repeat
    WriteLn('Введите месяц рождения (1-12)');
    Month := CorrectInteger;
    if (Month < 1) or (Month > 12) then
      WriteLn(ErrorMessage);
  until (Month >= 1) and (Month <= 12);

  LeapYear := IsLeapYear(Year);
  MaxDaysInMonth := MonthDays[LeapYear, Month];

  repeat
    WriteLn('Введите день рождения (1-', MaxDaysInMonth, ')');
    Day := CorrectInteger;
    if (Day < 1) or (Day > MaxDaysInMonth) then
      WriteLn(ErrorMessage);
  until (Day >= 1) and (Day <= MaxDaysInMonth);

  Result := EncodeDate(Year, Month, Day);
end;

function YesNo: Boolean;
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

function YesNoToStr(var Input: Boolean): String;
begin
  if Input then
    Result := 'Да'
  else
    Result := 'Нет';
end;

procedure ReadFromFile(vHead: PVacancy; cHead: PCandidate;
  var vIndex, cIndex: Integer);
var
  FVacancy: FileVacancy;
  FCandidate: FileCandidate;
  vTemp: PVacancy;
  vInfo: TVacancyInfo;
  cTemp: PCandidate;
  cInfo: TCandidateInfo;
begin
  try
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
  except
    WriteLn('Файлы не найдены');
    Sleep(1500);
  end;
end;

procedure WriteInFile(vHead: PVacancy; cHead: PCandidate;
  var vIndex, cIndex: Integer);
var
  FVacancy: FileVacancy;
  FCandidate: FileCandidate;
  vTemp: PVacancy;
  vInfo: TVacancyInfo;
  cTemp: PCandidate;
  cInfo: TCandidateInfo;
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

end;

procedure WriteInFileSpFunc(cTemp: PCandidate; vHead: PVacancy;
  pvHead: PPossibleVacancy; dHead: PDeficit);
var
  FPossibleVacancy: TextFile;
  vTemp: PVacancy;
  pvTemp: PPossibleVacancy;
  Temp: Boolean;
begin
  Assign(FPossibleVacancy, 'ListOfPossibleCandidates.txt');
  ReWrite(FPossibleVacancy);

  WriteLn(FPossibleVacancy,
    ' ______________________________________________________Кандидат_____________________________________________________ ');

  WriteLn(FPossibleVacancy, HeadCandidateList);
  Write(FPossibleVacancy, HorizLineC);
  with cTemp^.Info do
    WriteLn(FPossibleVacancy, '|', Index:5, '|', FIO:32, '|',
      DateToStr(BirthDay):13, '|', Specialization:19, '|', Post:13, '|',
      Salary:9, '|', YesNoToStr(HighEdu):18, '|');
  Write(FPossibleVacancy, HorizLineC);

  WriteLn(FPossibleVacancy,
    ' _________________________________________________Возможные вакансии________________________________________________ ');

  Temp := False;
  pvTemp := pvHead;
  while pvTemp^.Adr <> nil do
  begin
    pvTemp := pvTemp^.Adr;
    if not Temp then
      WriteLn(FPossibleVacancy, HeadVacancyList);
    Write(FPossibleVacancy, HorizLineV);
    with pvTemp^.Info do
      WriteLn(FPossibleVacancy, '|', Index:5, '|', Firm:15, '|',
        Specialization:19, '|', Post:15, '|', Salary:11, '|', Vacation:12, '|',
        YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-', RangeAge[max], '|');
    Temp := True;
  end;
  Write(FPossibleVacancy, HorizLineV);

  WriteLn(FPossibleVacancy,
    ' _________________________________________________Дефицитные вакансии_______________________________________________ ');
  WriteLn(FPossibleVacancy, HeadVacancyList);
  vTemp := vHead;
  while vTemp^.Adr <> nil do
  begin
    vTemp := vTemp^.Adr;
    dTemp := dHead;
    while dTemp^.Adr <> nil do
    begin
      dTemp := dTemp^.Adr;
      if (vTemp^.Info.Post = dTemp^.Info.Post) and (dTemp^.Info.Part < 0.1) then
      begin
        Write(FPossibleVacancy, HorizLineV);
        with vTemp^.Info do
          WriteLn(FPossibleVacancy, '|', Index:5, '|', Firm:15, '|',
            Specialization:19, '|', Post:15, '|', Salary:11, '|', Vacation:12,
            '|', YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
            RangeAge[max], '|');
      end;
    end;
  end;
  WriteLn(FPossibleVacancy, HorizLineV);

  CloseFile(FPossibleVacancy);
end;

procedure AddData(vHead: PVacancy; cHead: PCandidate;
  var vIndex, cIndex: Integer);
var
  Choice, Count, I: Integer;
  vTemp: PVacancy;
  cTemp: PCandidate;
begin
  WriteLn(AddText);
  Choice := CorrectChoice(1, 4);
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
          Salary := CorrectInteger;
          WriteLn('Введите количество дней отпуска');
          Vacation := CorrectInteger;
          WriteLn('Введите наличие высшего образования (да/нет)');
          HighEdu := YesNo;
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
          BirthDay := CorrectBirthDate;
          WriteLn('Введите специальность');
          ReadLn(Specialization);
          Trim(String(Specialization));
          WriteLn('Введите должность');
          ReadLn(Post);
          Trim(String(Post));
          WriteLn('Введите оклад');
          Salary := CorrectInteger;
          WriteLn('Введите наличие высшего образования (да/нет)');
          HighEdu := YesNo;
          Index := cIndex;
          Inc(cIndex);
        end;
        WriteLn(SuccessMessage);
        cTemp^.Adr := nil;
      end;
    3:
      begin
        WriteLn('Введите количество записей');
        Count := CorrectInteger;
        for I := 1 to Count do
        begin
          while vTemp.Adr <> nil do
            vTemp := vTemp^.Adr;
          New(vTemp^.Adr);
          vTemp := vTemp^.Adr;
          with vTemp^.Info do
          begin
            Firm := ShortString(TFirm[Random(7)]);
            Specialization := ShortString(TSpecVacancy[Random(10)]);
            Post := ShortString(TSpecVacancy[Random(10)]);
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
        Count := CorrectInteger;
        for I := 1 to Count do
        begin
          while cTemp.Adr <> nil do
            cTemp := cTemp^.Adr;
          New(cTemp^.Adr);
          cTemp := cTemp^.Adr;
          with cTemp^.Info do
          begin
            FIO := ShortString(TSurName[Random(5)] + ' ' + TName[Random(6)] +
              ' ' + TOtch[Random(6)]);
            BirthDay := Random(22000) + 15000;
            Specialization := ShortString(TSpecCandidate[Random(10)]);
            Post := ShortString(TSpecCandidate[Random(10)]);
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
end;

function SearchData(vHead: PVacancy; cHead: PCandidate;
  var chTemp: Integer): Boolean;
var
  Choice, KeyInt: Integer;
  KeyStr: String;
  KeyDate: TDateTime;
  KeyEdu, IsFound: Boolean;
  KeyRange: TRangeAge;
  vTemp: PVacancy;
  cTemp: PCandidate;
begin
  if chTemp = 0 then
  begin
    WriteLn(SearchText);
    Choice := CorrectChoice(1, 2);
    chTemp := Choice;

    WriteLn(ContinueMessage);
    ReadLn;
    ClearConsole(0);
  end
  else
    Choice := chTemp;

  Result := True;
  case Choice of
    1:
      begin
        WriteLn(SearchMessageV);
        Choice := CorrectChoice(1, 8);

        WriteLn(ContinueMessage);
        ReadLn;
        ClearConsole(0);

        IsFound := False;

        WriteLn('Введите содержание поля');

        vTemp := vHead;
        case Choice of
          1:
            begin
              KeyInt := CorrectInteger;
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
                      YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
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
                      YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
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
                      YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
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
                      YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
              else
                Write(HorizLineV);
            end;
          5:
            begin
              KeyInt := CorrectInteger;
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
                      YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
              else
                Write(HorizLineV);
            end;
          6:
            begin
              KeyInt := CorrectInteger;
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
                      YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
              else
                Write(HorizLineV);
            end;
          7:
            begin
              KeyEdu := YesNo;
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
                      YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
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
                      YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
                      RangeAge[max], '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
              else
                Write(HorizLineV);
            end;
        end;
      end;
    2:
      begin
        WriteLn(SearchMessageС);
        Choice := CorrectChoice(1, 7);

        WriteLn(ContinueMessage);
        ReadLn;
        ClearConsole(0);

        IsFound := False;

        WriteLn('Введите содержание поля');

        cTemp := cHead;
        case Choice of
          1:
            begin
              KeyInt := CorrectInteger;
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
                      '|', YesNoToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
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
                      '|', YesNoToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
              else
                Write(HorizLineC);
            end;
          3:
            begin
              KeyDate := CorrectBirthDate;
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
                      '|', YesNoToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
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
                      '|', YesNoToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
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
                      '|', YesNoToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
              else
                Write(HorizLineC);
            end;
          6:
            begin
              KeyInt := CorrectInteger;
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
                      '|', YesNoToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
              else
                Write(HorizLineC);
            end;
          7:
            begin
              KeyEdu := YesNo;
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
                      '|', YesNoToStr(HighEdu):18, '|');
                    IsFound := True;
                  end;
              end;
              if not IsFound then
              begin
                WriteLn(NotFoundMessage);
                Result := False;
              end
              else
                Write(HorizLineC);
            end;
        end;
      end;
  end;
end;

procedure DeleteData(vHead: PVacancy; cHead: PCandidate);
var
  Index, Choice, chTemp: Integer;
  IsDeleted: Boolean;
  vTempCurr, vTempPrev: PVacancy;
  cTempCurr, cTempPrev: PCandidate;
begin
  chTemp := 0;
  if SearchData(vHead, cHead, chTemp) then
  begin
    Choice := chTemp;
    WriteLn('Введите индекс записи для удаления');
    Index := CorrectInteger;
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
end;

procedure EditData(vHead: PVacancy; cHead: PCandidate);
var
  Choice, Index, KeyInt, chTemp: Integer;
  IsFound, KeyEdu: Boolean;
  KeyDate: TDateTime;
  KeyRange: TRangeAge;
  vTemp: PVacancy;
  cTemp: PCandidate;
begin
  chTemp := 0;
  if SearchData(vHead, cHead, chTemp) then
  begin
    WriteLn('Введите индекс записи для редактирования');
    Index := CorrectInteger;

    IsFound := False;

    vTemp := vHead;
    cTemp := cHead;

    Choice := chTemp;

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
            Choice := CorrectChoice(1, 7);

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
                    KeyInt := CorrectInteger;
                    Salary := KeyInt;
                  end;
                5:
                  begin
                    KeyInt := CorrectInteger;
                    Vacation := KeyInt;
                  end;
                6:
                  begin
                    KeyEdu := YesNo;
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
            Choice := CorrectChoice(1, 6);

            WriteLn('Введите новое содержание поля');
            with cTemp^.Info do
              case Choice of
                1:
                  ReadLn(FIO);
                2:
                  begin
                    KeyDate := CorrectBirthDate;
                    BirthDay := KeyDate;
                  end;
                3:
                  ReadLn(Specialization);
                4:
                  ReadLn(Post);
                5:
                  begin
                    KeyInt := CorrectInteger;
                    Salary := KeyInt;
                  end;
                6:
                  begin
                    KeyEdu := YesNo;
                    HighEdu := KeyEdu;
                  end;
              end;
            WriteLn(SuccessMessage);
          end;
      end;
    end
    else
      WriteLn(NotFoundMessage);
  end;
end;

procedure ShowData(vHead: PVacancy; cHead: PCandidate);
var
  Choice: Integer;
  vTemp: PVacancy;
  cTemp: PCandidate;
begin
  WriteLn(ShowText);
  Choice := CorrectChoice(1, 2);

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
              Post:15, '|', Salary:11, '|', Vacation:12, '|',
              YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
              RangeAge[max], '|');
        end;
        WriteLn(HorizLineV);
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
              YesNoToStr(HighEdu):18, '|');
        end;
        WriteLn(HorizLineC);
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
  Choice := CorrectChoice(1, 2);

  WriteLn(ContinueMessage);
  ReadLn;
  ClearConsole(0);

  case Choice of
    1:
      begin
        WriteLn(SortMessageV);
        Choice := CorrectChoice(1, 8);

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
      end;
    2:
      begin
        WriteLn(SortMessageС);
        Choice := CorrectChoice(1, 7);

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
      end;
  end;
end;

procedure SpecialFuntion(vHead: PVacancy; cHead: PCandidate;
  pvHead: PPossibleVacancy);
var
  vTemp: PVacancy;
  cTemp, cTempFound: PCandidate;
  pvTemp: PPossibleVacancy;
  dTemp: PDeficit;
  KeyInt, chMode: Integer;
  IsFoundI, IsFoundV, IsFoundD, Temp: Boolean;
begin
  chMode := 2;
  if SearchData(vHead, cHead, chMode) then
  begin
    WriteLn('Введите индекс записи для подбора списка возможных вакансий');
    KeyInt := CorrectInteger;
    cTemp := cHead;
    IsFoundI := False;
    IsFoundV := False;
    while (cTemp^.Adr <> nil) and not IsFoundI do
    begin
      cTemp := cTemp^.Adr;
      if cTemp^.Info.Index = KeyInt then
      begin
        vTemp := vHead;
        pvTemp := pvHead;
        while vTemp^.Adr <> nil do
        begin
          vTemp := vTemp^.Adr;
          if (vTemp^.Info.Specialization = cTemp^.Info.Specialization) and
            (vTemp^.Info.Post = cTemp^.Info.Post) and
            (vTemp^.Info.Salary >= cTemp^.Info.Salary) and
            (vTemp^.Info.HighEdu = cTemp^.Info.HighEdu) and
            ((vTemp^.Info.RangeAge[min] <= YearsBetween(cTemp^.Info.BirthDay,
            Now)) and (vTemp^.Info.RangeAge[max] >=
            YearsBetween(cTemp^.Info.BirthDay, Now))) then
          begin
            New(pvTemp^.Adr);
            pvTemp := pvTemp^.Adr;
            pvTemp.Info := vTemp.Info;
            pvTemp^.Adr := nil;
            IsFoundV := True;
          end;
        end;
        IsFoundI := True;
      end;
    end;

    cTempFound := cTemp;

    if IsFoundV and IsFoundI then
    begin
      WriteLn('Возможные вакансии для данного кандидата: ');
      pvTemp := pvHead;
      Temp := False;
      while pvTemp^.Adr <> nil do
      begin
        pvTemp := pvTemp^.Adr;
        if not Temp then
          WriteLn(HeadVacancyList);
        Write(HorizLineV);
        with pvTemp^.Info do
          WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19, '|',
            Post:15, '|', Salary:11, '|', Vacation:12, '|', YesNoToStr(HighEdu)
            :18, '|', RangeAge[min]:10, '-', RangeAge[max], '|');
        Temp := True;
      end;
      Write(HorizLineV);
    end
    else
    begin
      WriteLn(NotFoundMessage);
    end;
  end;

  vTemp := vHead;
  while vTemp^.Adr <> nil do
  begin
    vTemp := vTemp^.Adr;
    dTemp := dHead;
    IsFoundI := False;
    while (dTemp^.Adr <> nil) and not IsFoundI do
    begin
      dTemp := dTemp^.Adr;
      if vTemp^.Info.Post = dTemp^.Info.Post then
      begin
        Inc(dTemp^.Info.vCount);
        IsFoundI := True;
      end;
    end;
    if not IsFoundI then
    begin
      New(dTemp^.Adr);
      dTemp := dTemp^.Adr;
      dTemp^.Info.Post := vTemp^.Info.Post;
      dTemp^.Info.vCount := 1;
      dTemp^.Info.cCount := 0;
      dTemp^.Adr := nil;
    end;
  end;

  cTemp := cHead;
  while cTemp^.Adr <> nil do
  begin
    cTemp := cTemp^.Adr;
    dTemp := dHead;
    IsFoundI := False;
    while (dTemp^.Adr <> nil) and not IsFoundI do
    begin
      dTemp := dTemp^.Adr;
      if cTemp^.Info.Post = dTemp^.Info.Post then
      begin
        Inc(dTemp^.Info.cCount);
        IsFoundI := True;
      end;
    end;
    if not IsFoundI then
    begin
      New(dTemp^.Adr);
      dTemp := dTemp^.Adr;
      dTemp^.Info.Post := cTemp^.Info.Post;
      dTemp^.Info.vCount := 0;
      dTemp^.Info.cCount := 1;
      dTemp^.Adr := nil;
    end;
  end;

  IsFoundD := False;
  dTemp := dHead;
  while dTemp.Adr <> nil do
  begin
    dTemp := dTemp^.Adr;
    with dTemp^.Info do
      try
        Part := vCount / cCount;
        // WriteLn('[ ', vCount, ' , ', cCount, ' ]');
        if Part < 0.1 then
          IsFoundD := True;
      except
        Part := MaxInt;
      end;
  end;

  if IsFoundD then
  begin
    WriteLn('Список дефицитных вакансий:');
    WriteLn(HeadVacancyList);
    vTemp := vHead;
    while vTemp^.Adr <> nil do
    begin
      vTemp := vTemp^.Adr;
      dTemp := dHead;
      while dTemp^.Adr <> nil do
      begin
        dTemp := dTemp^.Adr;
        if (vTemp^.Info.Post = dTemp^.Info.Post) and (dTemp^.Info.Part < 0.1)
        then
        begin
          Write(HorizLineV);
          with vTemp^.Info do
            WriteLn('|', Index:5, '|', Firm:15, '|', Specialization:19, '|',
              Post:15, '|', Salary:11, '|', Vacation:12, '|',
              YesNoToStr(HighEdu):18, '|', RangeAge[min]:10, '-',
              RangeAge[max], '|');
        end;
      end;
    end;
    WriteLn(HorizLineV);
  end
  else
    WriteLn('Дефицитные вакансии не найдены');

  if IsFoundV or IsFoundD then
  begin
    WriteLn('Внести результат в текстовый файл (да/нет)');
    if YesNo then
    begin
      WriteLn(SuccessMessage);
      WriteInFileSpFunc(cTempFound, vHead, pvHead, dHead);
    end;
  end;
end;

procedure Initialize(var vHead: PVacancy; var cHead: PCandidate;
  var pvHead: PPossibleVacancy; var dHead: PDeficit);
begin
  New(vHead);
  vHead^.Adr := nil;
  New(cHead);
  cHead^.Adr := nil;
  New(pvHead);
  pvHead^.Adr := nil;
  New(dHead);
  dHead^.Adr := nil;
end;

procedure Destroy(vHead: PVacancy; cHead: PCandidate; pvHead: PPossibleVacancy;
  dHead: PDeficit);
var
  vTemp: PVacancy;
  cTemp: PCandidate;
  pvTemp: PPossibleVacancy;
  dTemp: PDeficit;
begin
  vTemp := vHead^.Adr;
  while vTemp <> nil do
  begin
    vHead^.Adr := vTemp^.Adr;
    Dispose(vTemp);
    vTemp := vHead^.Adr;
  end;
  vHead^.Adr := nil;
  Dispose(vHead);

  cTemp := cHead^.Adr;
  while cTemp <> nil do
  begin
    cHead^.Adr := cTemp^.Adr;
    Dispose(cTemp);
    cTemp := cHead^.Adr;
  end;
  cHead^.Adr := nil;
  Dispose(cHead);

  pvTemp := pvHead^.Adr;
  while pvTemp <> nil do
  begin
    pvHead^.Adr := pvTemp^.Adr;
    Dispose(pvTemp);
    pvTemp := pvHead^.Adr;
  end;
  pvHead^.Adr := nil;
  Dispose(pvHead);

  dTemp := dHead^.Adr;
  while dTemp <> nil do
  begin
    dHead^.Adr := dTemp^.Adr;
    Dispose(dTemp);
    dTemp := dHead^.Adr;
  end;
  dHead^.Adr := nil;
  Dispose(dHead);
end;

procedure Menu;
var
  Choice: Integer;
begin
  repeat
    WriteLn(HelloMessage);
    Choice := CorrectChoice(1, 10);
    WriteLn(ContinueMessage);
    ReadLn;
    ClearConsole(0);
    case Choice of
      1:
        ReadFromFile(vHead, cHead, vIndex, cIndex);
      2:
        begin
          ShowData(vHead, cHead);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      3:
        begin
          SortData(vHead, cHead);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      4:
        begin
          chMode := 0;
          SearchData(vHead, cHead, chMode);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      5:
        begin
          AddData(vHead, cHead, vIndex, cIndex);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      6:
        begin
          DeleteData(vHead, cHead);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      7:
        begin
          EditData(vHead, cHead);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      8:
        begin
          pvTemp := pvHead^.Adr;
          while pvTemp <> nil do
          begin
            pvHead^.Adr := pvTemp^.Adr;
            Dispose(pvTemp);
            pvTemp := pvHead^.Adr;
          end;
          dTemp := dHead^.Adr;
          while dTemp <> nil do
          begin
            dHead^.Adr := dTemp^.Adr;
            Dispose(dTemp);
            dTemp := dHead^.Adr;
          end;
          pvHead^.Adr := nil;
          SpecialFuntion(vHead, cHead, pvHead);
          WriteLn(ContinueMessage);
          ReadLn;
        end;
      9:
        ;
      10:
        WriteInFile(vHead, cHead, vIndex, cIndex);
    end;
    ClearConsole(0);
  until (Choice = 9) or (Choice = 10);
end;

begin
  Randomize;
  vIndex := 1;
  cIndex := 1;
  Initialize(vHead, cHead, pvHead, dHead);
  Menu;
  Destroy(vHead, cHead, pvHead, dHead);

end.
