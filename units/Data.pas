unit Data;

interface

const
  min = 1;
  max = 2;
  ErrorMessage = '������������ ����';
  SuccessMessage = '�������� ��������� �������';
  ContinueMessage = '������� Enter...';
  NotFoundMessage = '����� �� ��� �����������';
  HelloMessage = '�������� ����� ����:' + #10#13 + '1. ������ ������ �� �����' +
    #10#13 + '2. �������� ����� ������' + #10#13 +
    '3. ���������� ������ � ������������ � ��������' + #10#13 +
    '4. ����� ������ � �������������� ��������' + #10#13 +
    '5. ���������� ������ � ������' + #10#13 + '6. �������� ������ �� ������' +
    #10#13 + '7. �������������� ������' + #10#13 +
    '8. ������ ������ ��������� �������� ��� ������� ���������' + #10#13 +
    '9. ����� �� ��������� ��� ���������� ���������' + #10#13 +
    '10. ����� � ����������� ���������';
  SearchMessageV = '�������� ����, �� �������� ����� ���������� �����' + #10#13
    + '1. �����' + #10#13 + '2. �������� �����' + #10#13 + '3. �������������' +
    #10#13 + '4. ���������' + #10#13 + '5. �����' + #10#13 +
    '6. ���������� ���� �������' + #10#13 + '7. ������� ������� �����������' +
    #10#13 + '8. ���������� ��������';
  SearchMessage� = '�������� ����, �� �������� ����� ���������� �����' + #10#13
    + '1. �����' + #10#13 + '2. ���' + #10#13 + '3. ���� ��������' + #10#13 +
    '4. �������������' + #10#13 + '5. ���������' + #10#13 + '6. �����' + #10#13
    + '7. ������� ������� �����������';
  EditMessageV = '�������� ����, � ������� ����� ����������� ��������������' +
    #10#13 + '1. �������� �����' + #10#13 + '2. �������������' + #10#13 +
    '3. ���������' + #10#13 + '4. �����' + #10#13 + '5. ���������� ���� �������'
    + #10#13 + '6. ������� ������� �����������' + #10#13 +
    '7. ���������� ��������';
  EditMessage� = '�������� ����, � ������� ����� ����������� ��������������' +
    #10#13 + '1. ���' + #10#13 + '2. ���� ��������' + #10#13 +
    '3. �������������' + #10#13 + '4. ���������' + #10#13 + '5. �����' + #10#13
    + '6. ������� ������� �����������';
  SortMessageV = '�������� ����, � ������� ����� ����������� ����������' +
    #10#13 + '1. �����' + #10#13 + '2. �������� �����' + #10#13 +
    '3. �������������' + #10#13 + '4. ���������' + #10#13 + '5. �����' + #10#13
    + '6. ���������� ���� �������' + #10#13 + '7. ������� ������� �����������' +
    #10#13 + '8. ���������� ��������';
  SortMessage� = '�������� ����, � ������� ����� ����������� ����������' +
    #10#13 + '1. �����' + #10#13 + '2. ���' + #10#13 + '3. ���� ��������' +
    #10#13 + '4. �������������' + #10#13 + '5. ���������' + #10#13 + '6. �����'
    + #10#13 + '7. ������� ������� �����������';
  AddText = '�������� ������, � ������� ������� �������� ������' + #10#13 +
    '1. ������ ��������' + #10#13 + '2. ������ ����������' + #10#13 + '3. ������ �������� (�������������� ����)' + #10#13 + '4. ������ ���������� (�������������� ����)';
  ShowText = '�������� ������, ������� ������� �������' + #10#13 +
    '1. ������ ��������' + #10#13 + '2. ������ ����������';
  DeleteText = '�������� ������, � ������� ������� ���������� ��������' + #10#13
    + '1. ������ ��������' + #10#13 + '2. ������ ����������';
  SortText = '�������� ������, � ������� ������� ���������� ����������' + #10#13
    + '1. ������ ��������' + #10#13 + '2. ������ ����������';
  SearchText = '�������� ������, � ������� ������� ���������� �����' + #10#13 +
    '1. ������ ��������' + #10#13 + '2. ������ ����������';
  HeadHorizLine =
    ' ___________________________________________________________________________________________________________________ '
    + #10#13;
  HeadVacancyList = HeadHorizLine + '|' + '�����' + '|' + '     �����     ' +
    '|' + '   �������������   ' + '|' + '   ���������   ' + '|' + '   �����   '
    + '|' + '   ������   ' + '|' + '������ �����������' + '|' +
    '   �������   ' + '|';
  HeadCandidateList = HeadHorizLine + '|' + '�����' + '|' +
    '               ���              ' + '|' + '���� ��������' + '|' +
    '   �������������   ' + '|' + '  ���������  ' + '|' + '  �����  ' + '|' +
    '������ �����������' + '|';
  HorizLineV =
    '|_____|_______________|___________________|_______________|___________|____________|__________________|_____________|'
    + #10#13;
  HorizLineC =
    '|_____|________________________________|_____________|___________________|_____________|_________|__________________|'
    + #10#13;
  TSpecialization: array[0 .. 9] of String = ('�����������', '����������', '�������', '��������', '���������', '�������', '�����������', '��������', '���������', '��������');
  TName: array[0 .. 5] of String = ('����', '������', '�������', '�����', '�����', '��������');
  TOtch: array[0 .. 5] of String = ('�����', '���������', '��������������', '������������', '����������', '����������');
  TSurName: array[0 .. 4] of String = ('�����', '��������', '������', '������', '��������');
  TSalary: array[0 .. 5] of Integer = (3000, 4500, 6000, 9000, 12000, 15000);
  TFirm: array[0 .. 6] of String = ('����', '�����', 'SoftTeco', 'EPAM', 'Andersen', 'HardTeco', 'Itransition');
  TVacation: array[0 .. 4] of Integer = (21, 23, 25, 27, 28);
  TAge: array[0 .. 5] of Integer = (18, 25, 30, 50, 60, 65);

type
  TRangeAge = array [min .. max] of Integer;

  TVacancyInfo = record
    Index: Integer;
    Firm: String[20];
    Specialization: String[20];
    Post: String[20];
    Salary: Integer;
    Vacation: Integer;
    HighEdu: boolean;
    RangeAge: TRangeAge;
  end;

  TCandidateInfo = record
    Index: Integer;
    FIO: String[50];
    BirthDay: TDateTime;
    Specialization: String[20];
    Post: String[20];
    Salary: Integer;
    HighEdu: boolean;
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
    Info: TVacancyInfo;
    Adr: PPossibleVacancy;
  end;

  FileVacancy = file of TVacancyInfo;
  FileCandidate = file of TCandidateInfo;
  FilePossibleVacancy = file of TVacancyInfo;

implementation

end.
