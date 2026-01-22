program WE_Extractor;

uses
  Vcl.Forms,
  WEExt in 'WEExt.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
