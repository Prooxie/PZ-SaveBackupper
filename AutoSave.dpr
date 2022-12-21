program AutoSave;

uses
  Vcl.Forms,
  Backupper in 'Backupper.pas' {SaveBackupper};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSaveBackupper, SaveBackupper);
  Application.Run;
end.
