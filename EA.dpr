program EA;

uses
  Forms,
  Generator in 'Generator.pas' {MainForm},
  Viewer in 'Viewer.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
