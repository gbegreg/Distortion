program DistortionDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {FMain},
  distortion in 'distortion.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
