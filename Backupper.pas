unit Backupper;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellApi, Vcl.ExtCtrls,
  IOUtils, Types, DateUtils;

Const
  fn = 'LastGeneratedFolder.txt';
  CrLf = #13#10;

type
  TSaveBackupper = class(TForm)
    btnDo: TButton;
    lblBackup: TLabel;
    tmrAutoBackup: TTimer;
    lblAutosave: TLabel;
    btnTimerBool: TButton;
    edtAutoSave: TEdit;
    lblCountDown: TLabel;
    tmrRefresh: TTimer;
    function GetUserName: String;
    function CopyDir(const fromDir, toDir: string): Boolean;
    function GetLastModifiedFolderName(AFolder: String): string;
    function LeerArchivox(const FileName: TFileName): String;
    function FileIsEmpty(const FileName: String): Boolean;
    procedure btnDoClick(Sender: TObject);
    procedure tmrAutoBackupTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MakeAStringlistAndSaveThat(CheckForFileOnly: Boolean);
    procedure edtAutosaveChange(Sender: TObject);
    procedure btnTimerBoolClick(Sender: TObject);
    procedure tmrRefreshTimer(Sender: TObject);

  private
    TimerInterval: Cardinal;
    CountDown: Integer;
    GeneratedBackupFolder: String;
    BackupFolder: String;
    SaveFolder: String;
    DiffFolder: String;
    LastModifiedSave: String;
    Autosaving: Boolean;
    User: String;

  public
    { Public declarations }
  end;

var
  SaveBackupper: TSaveBackupper;

implementation

{$R *.dfm}

procedure TSaveBackupper.btnTimerBoolClick(Sender: TObject);
begin
  tmrAutoBackup.Enabled := NOT tmrAutoBackup.Enabled;

  if (tmrAutoBackup.Enabled) then
    btnTimerBool.Caption := 'Disable autosaving'
  else if (NOT tmrAutoBackup.Enabled) then
    btnTimerBool.Caption := 'Enable autosaving';

   tmrRefresh.Enabled := tmrAutoBackup.Enabled;
   if tmrRefresh.Enabled then CountDown := TimerInterval;
   
end;

function TSaveBackupper.CopyDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := FO_COPY;
    fFlags := FOF_FILESONLY;
    pFrom := PChar(fromDir + #0);
    pTo := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

procedure TSaveBackupper.edtAutosaveChange(Sender: TObject);
begin

  tmrAutoBackup.Enabled := False;
  tmrRefresh.Enabled    := False;
  btnTimerBool.Enabled  := False;

  if (edtAutoSave.Text = '') OR (StrToInt(edtAutoSave.Text) <= 9) then
  begin
    lblCountDown.Caption := 'ERROR';
    btnTimerBool.Caption := 'ERROR';
    exit
  end;

  TimerInterval := StrToInt(edtAutoSave.Text);
  CountDown := TimerInterval;
  if TimerInterval > 9 then
    tmrAutoBackup.Interval := TimerInterval * 1000;

  if btnTimerBool.Caption = 'ERROR' then btnTimerBool.Caption := 'Enable autosaving';

  if not (btnTimerBool.Caption = 'Enable autosaving') then
  begin
    tmrRefresh.Enabled    := True;
    tmrAutoBackup.Enabled := True;
  end;

  btnTimerBool.Enabled  := True;
end;

function TSaveBackupper.GetUserName: String;
var
  nSize: DWord;
begin
  nSize := 1024;
  SetLength(Result, nSize);
  if Winapi.Windows.GetUserName(PChar(Result), nSize) then
  begin
    SetLength(Result, nSize - 1)
  end
  else
  begin
    RaiseLastOSError;
  end
end;

procedure TSaveBackupper.FormCreate(Sender: TObject);
begin

  Autosaving := False;
  User := Self.GetUserName;

  DiffFolder := GetLastModifiedFolderName('C:\Users\' + User + '\Zomboid\Saves\');
  LastModifiedSave := GetLastModifiedFolderName('C:\Users\' + User + '\Zomboid\Saves\' + DiffFolder + '\');

  BackupFolder := 'C:\Users\' + User + '\Zomboid\BackupSaves\';
  MakeAStringlistAndSaveThat(True);
  GeneratedBackupFolder := LeerArchivox(fn);
  if NOT (GeneratedBackupFolder = '') then GeneratedBackupFolder := StringReplace(GeneratedBackupFolder,#$D#$A,'',[rfReplaceAll]);

end;

procedure TSaveBackupper.FormShow(Sender: TObject);
begin

  if (GeneratedBackupFolder = '') then
  begin
    lblBackup.Caption := 'Autosaving' + CrLf + 'you cannot replace your save, yet.';
    lblBackup.left := 46;
    lblBackup.Top := 53;
    btnDo.Enabled := False;
    btnDo.Visible := False;
  end
  else
  begin
    lblBackup.Caption := 'Do you wish to replace your save?';
    lblBackup.left := 45;
    lblBackup.Top := 29;
    btnDo.Enabled := True;
  end;

  TimerInterval := (tmrAutoBackup.Interval div 1000);
  edtAutoSave.Text := IntToStr(TimerInterval);

  CountDown := TimerInterval;

  tmrAutoBackup.Enabled := True;

  if (tmrAutoBackup.Enabled) then
    btnTimerBool.Caption := 'Disable autosaving'
  else if (NOT tmrAutoBackup.Enabled) then
    btnTimerBool.Caption := 'Enable autosaving';
end;

procedure TSaveBackupper.tmrAutoBackupTimer(Sender: TObject);
begin

  tmrRefresh.Enabled := False;
  tmrAutoBackup.Enabled := False;

  CountDown := 0;
  lblCountDown.Caption := IntToStr(CountDown);

  lblBackup.Caption := 'Do you wish to replace your save?';
  lblBackup.left := 45;
  lblBackup.Top := 29;

  btnDo.Enabled := True;
  btnDo.Visible := True;

  DiffFolder := GetLastModifiedFolderName('C:\Users\' + User +
  '\Zomboid\Saves\');

  LastModifiedSave := GetLastModifiedFolderName('C:\Users\' + User +
  '\Zomboid\Saves\' + DiffFolder + '\');

  SaveFolder := 'C:\Users\' + User + '\Zomboid\Saves\' + DiffFolder + '\' + LastModifiedSave;

  DateTimeToString(GeneratedBackupFolder, 'dd-mm-yy_hh-nn-ss', Now);
//  GeneratedBackupFolder := GeneratedBackupFolder + '-' + GenerateRandomString(4,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890');
  CreateDir(BackupFolder + GeneratedBackupFolder);
  CopyDir(SaveFolder, BackupFolder + GeneratedBackupFolder);


  MakeAStringlistAndSaveThat(False);

  tmrAutoBackup.Enabled := True;
  tmrRefresh.Enabled := True;

end;

procedure TSaveBackupper.tmrRefreshTimer(Sender: TObject);
begin

  if tmrAutoBackup.Enabled then
    dec(CountDown, 1)
  else if NOT tmrAutoBackup.Enabled then
    CountDown := TimerInterval;

  if CountDown <= 0 then
    CountDown := TimerInterval;

  lblCountDown.Caption := IntToStr(CountDown);

end;

procedure TSaveBackupper.MakeAStringlistAndSaveThat(CheckForFileOnly: Boolean);

var
  MyText: TStringlist;
  dir: String;

begin
  dir := GetCurrentDir;
  MyText := TStringlist.create;
  try

    if NOT FileExists(fn) then
    FileCreate(fn);

    if CheckForFileOnly then exit;

    if (GeneratedBackupFolder = '') then exit;

    MyText.Add(GeneratedBackupFolder);
    MyText.SaveToFile(GetCurrentDir + '\' + fn);

  finally
    MyText.Free
  end;
end;

function TSaveBackupper.FileIsEmpty(const FileName: String): Boolean;
var
  fad: TWin32FileAttributeData;
begin
  Result := GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @fad)
    and (fad.nFileSizeLow = 0) and (fad.nFileSizeHigh = 0);
end;

function TSaveBackupper.LeerArchivox(const FileName: TFileName): String;

var
  List: TStringlist;
begin

  Result := '';

  if (FileExists(FileName)) then
  begin
    List := TStringlist.create;
    List.Loadfromfile(FileName);
    Result := List.Text;
    List.Free;
  end;
end;

procedure TSaveBackupper.btnDoClick(Sender: TObject);

begin

  if (NOT FileExists(fn)) then FileCreate(fn);

  if (GeneratedBackupFolder = '') AND (FileExists(fn)) AND (FileIsEmpty(fn)) then exit
  else if (GeneratedBackupFolder = '') AND (FileExists(fn)) AND (NOT FileIsEmpty(fn)) then GeneratedBackupFolder := LeerArchivox(fn);

  if NOT(GeneratedBackupFolder = '') then
  begin
    tmrAutoBackup.Enabled := False;
    CopyDir('C:\Users\' + User + '\Documents\backup\' + GeneratedBackupFolder +
      '\' + LastModifiedSave + '\', 'C:\Users\' + User +
      '\Zomboid\Saves\' + DiffFolder + '\');
    tmrAutoBackup.Enabled := True;
  end;
end;

function TSaveBackupper.GetLastModifiedFolderName(AFolder: String): string;
var
  sr: TSearchRec;
  aTime: Integer;
begin
  Result := '';
  aTime := 0;

  if FindFirst(IncludeTrailingPathDelimiter(AFolder) + '*', faDirectory, sr) = 0
  then
  begin
    repeat
      if (sr.Attr and faDirectory) = faDirectory then
      begin
        if (sr.Name <> '.') and (sr.Name <> '..') then
        begin
          if sr.Time > aTime then
          begin
            aTime := sr.Time;
            Result := sr.Name;
          end;
        end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end
  else
  begin
    Result := '-1';
  end;
end;
 (*
function TSaveBackupper.GenerateRandomString(const ALength: Integer;
  const ACharSequence
  : String =
  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'): String;
var
  Ch, SequenceLength: Integer;

begin
  SequenceLength := Length(ACharSequence);
  SetLength(Result, ALength);
  Randomize;

  for Ch := Low(Result) to High(Result) do
    Result[Ch] := ACharSequence.Chars[Random(SequenceLength)];
end;


            NOT USING ANYMORE - MAY COME HANDY LATER ON

          *)
end.
