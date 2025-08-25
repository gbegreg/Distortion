unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Objects, System.Math, FMX.Filter.Effects, FMX.Edit,
  FMX.EditBox, FMX.NumberBox, FMX.Layouts, distortion, FMX.Types3D,
  System.Math.Vectors, FMX.MaterialSources, FMX.Objects3D, FMX.Controls3D,
  FMX.Viewport3D, FMX.Ani, FMX.ListBox;

type
  TFMain = class(TForm)
    Image: TImage;
    Timer: TTimer;
    recIHM: TRectangle;
    gbX: TGroupBox;
    lblAmplitudeX: TLabel;
    nbAmplitudeX: TNumberBox;
    lblFrequenceX: TLabel;
    nbFrequenceX: TNumberBox;
    GroupBox1: TGroupBox;
    lblAmplitudeY: TLabel;
    nbAmplitudeY: TNumberBox;
    lblFrequenceY: TLabel;
    nbFrequenceY: TNumberBox;
    lblVitesse: TLabel;
    nbVitesse: TNumberBox;
    layIHM: TLayout;
    Viewport3D1: TViewport3D;
    Light1: TLight;
    Cube1: TCube;
    LightMaterialSource1: TLightMaterialSource;
    FloatAnimation2: TFloatAnimation;
    Switch1: TSwitch;
    lbl3D: TLabel;
    Sphere1: TSphere;
    FloatAnimation5: TFloatAnimation;
    Cone1: TCone;
    FloatAnimation8: TFloatAnimation;
    cbStyle: TComboBox;
    lblStyle: TLabel;
    Dummy1: TDummy;
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Switch1Switch(Sender: TObject);
    procedure cbStyleChange(Sender: TObject);
  private
    aDistortion : TDistortion;
    procedure animerDistortion3D(en3D: boolean);
  public
  end;

var
  FMain: TFMain;

implementation
{$R *.fmx}

procedure TFMain.cbStyleChange(Sender: TObject);
begin
  if viewPort3D1.visible then LightMaterialSource1.Texture.assign(aDistortion.restoreOriginal)
  else image.bitmap.assign(aDistortion.restoreOriginal);
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  aDistortion := TDistortion.Create(image.bitmap);
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  aDistortion.free;
end;

procedure TFMain.Switch1Switch(Sender: TObject);
begin
  if switch1.isChecked then begin
    viewport3D1.visible := true;
    image.bitmap.clear(TAlphacolorrec.Black);
  end else begin
    viewport3D1.visible := false;
  end;
end;

procedure TFMain.TimerTimer(Sender: TObject);
begin
  if viewPort3D1.visible then animerDistortion3D(true)
  else animerDistortion3D(false);
end;

procedure TFMain.animerDistortion3D(en3D : boolean);
begin
  aDistortion.speed := nbVitesse.value;
  aDistortion.amplitudeX := Round(nbAmplitudeX.value);
  aDistortion.frequencyX := nbFrequenceX.value;
  aDistortion.amplitudeY := Round(nbAmplitudeY.value);
  aDistortion.frequencyY := nbFrequenceY.value;
  if cbStyle.ItemIndex = 0 then aDistortion.distortionStyle := TDistortionStyle.all
  else aDistortion.distortionStyle := TDistortionStyle.middle;

  if en3D then LightMaterialSource1.Texture.Assign(aDistortion.ApplyDistortion)
  else image.bitmap.assign(aDistortion.ApplyDistortion);
end;

end.
