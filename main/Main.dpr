program Main;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

const
  min = 1;
  max = 2;

type
  TAge = array [min .. max] of Integer;

  TVacancyInfo = record
    Index: Integer;
    Firm: String[20];
    Specialization: String[20];
    Post: String[20];
    Salary: Integer;
    Vacation: Integer;
    HighEdu: boolean;
    Age: TAge;
  end;

  TCandidateInfo = record
    Index: Integer;
    FIO: String[50];
    BirthDay: String[10];
    Specialization: String[20];
    Post: String[20];
    Salary: Integer;
    HighEdu: boolean;
  end;

  TPossibleVacancyInfo = record
    Info: TVacancyInfo;
  end;

  PVacancy = ^TVacancy;

  TVacancy = record
    Info: TVacancyInfo;
    Adr: PVacancy;
  end;

  PCandidate = ^TCandidate;

  TCandidate = record
    Info: TCandidateInfo;
    Adr: PCandidate;
  end;

  PPossibleVacancy = ^TPossibleVacancy;

  TPossibleVacancy = record
    Info: TPossibleVacancyInfo;
    Adr: PPossibleVacancy;
  end;

var
  vHead: PVacancy;
  cHead: PCandidate;
  pvHead: PPossibleVacancy;

procedure CorrectRead(var Choice: Integer);
var
  Input: String;
  Error: Integer;
begin
  repeat
    ReadLn(Input);
    Val(Input, Choice, Error);
    if (Error <> 0) or (Choice > 10) or (Choice < 1) then
      WriteLn('�������� ����');
  until (Error = 0) and ((Choice < 11) and (Choice > 0));
end;

procedure WriteText;
begin
  WriteLn('�������� ����� ����:' + #10#13 +
    '1. ������ ������ �� �����' + #10#13 +
    '2. �������� ����� ������' + #10#13 +
    '3. ���������� ������' + #10#13 +
    '4. ����� ������ � �������������� ��������' + #10#13 +
    '5. ���������� ������ � ������' + #10#13 +
    '6. �������� ������ �� ������' + #10#13 +
    '7. �������������� ������' + #10#13 +
    '8. ������ ������ ��������� �������� ��� ������� ���������' + #10#13 +
    '9. ����� �� ��������� ��� ���������� ���������' + #10#13 +
    '10. ����� � ����������� ���������');
end;

procedure NewHead(var vHead: PVacancy; var cHead: PCandidate; var pvHead: PPossibleVacancy);
begin
  New(vHead);
  New(cHead);
  New(pvHead);
end;

procedure DisposeHead(var vHead: PVacancy; var cHead: PCandidate; var pvHead: PPossibleVacancy);
begin
  while vHead <> nil do
  begin
    Dispose(vHead);
    vHead := vHead^.Adr;
  end;
  while cHead <> nil do
  begin
    Dispose(cHead);
    cHead := cHead^.Adr;
  end;
  while pvHead <> nil do
  begin
    Dispose(pvHead);
    pvHead := pvHead^.Adr;
  end;
end;

procedure Menu;
var
  Choice: Integer;
begin
  WriteText;
  CorrectRead(Choice);
  case Choice of
    1:
      WriteLn('one');
    2:
      WriteLn('two');
    3:
      WriteLn('three');
    4:
      WriteLn('four');
    5:
      WriteLn('five');
    6:
      WriteLn('six');
    7:
      WriteLn('seven');
    8:
      WriteLn('eight');
    9:
      WriteLn('nine');
    10:
      WriteLn('ten');
  end;
end;

begin
  NewHead(vHead, cHead, pvHead);
  Menu;
  DisposeHead(vHead, cHead, pvHead);
  ReadLn;
end.