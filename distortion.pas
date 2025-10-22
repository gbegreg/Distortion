unit distortion;

interface

uses System.Math, FMX.Types, FMX.Filter.Effects, FMX.Graphics, FMX.Objects, System.UITypes, system.sysutils, FMX.Utils;

type
  TDistortionStyle = (all, top, bottom);
  TDistortion = class
  private
    FOriginal, FModify: TBitmap;
    FSinTable  : array of Integer; // valeurs calculées par ligne de l'image des décalages sur X
    FCosTable  : array of Integer; // valeurs calculées par colonne de l'image des décalages sur Y
    procedure BuildSinTable(const AHeight: Integer);
    procedure BuildCosTable(const AWidth: Integer);
  public
    amplitudeX, amplitudeY : integer;
    time, frequencyX, frequencyY, speed : single;
    distortionStyle : TDistortionStyle;
    constructor Create(const AImage: TBitmap);
    destructor Destroy; override;
    function ApplyDistortion: TBitmap;
    function restoreOriginal: TBitmap;
  end;

implementation

{ TDistortion }
function TDistortion.ApplyDistortion: TBitmap;
var
  SrcData, DstData: TBitmapData;
  SrcPtr, DstPtr: PAlphaColorArray;
  srcColor: TAlphaColor;
  newX, newY, y, x: Integer;
begin
  time := time + speed;

  // time a changé, on recacule les valeurs dans les 2 tableaux
  BuildSinTable(FOriginal.Height);
  BuildCosTable(FOriginal.Width);

  FModify.SetSize(FOriginal.Width, FOriginal.Height);
  var W := FOriginal.Width;
  var H := FOriginal.Height;

  if not (FOriginal.Map(TMapAccess.Read, SrcData) and
          FModify.Map(TMapAccess.Write, DstData)) then
    Exit(nil);

  try
    var startY := 0;
    var endY := H;
    case distortionStyle of
       TDistortionStyle.bottom: startY := round(H *0.5);
       TDistortionStyle.top: endY := round(H *0.5);
    end;

    for y := startY to endY - 1 do
    begin
      // Accès direct à la ligne source/destination
      SrcPtr := SrcData.GetScanline(y);
      DstPtr := DstData.GetScanline(y);

      for x := 0 to W - 1 do begin
        // Application de la distorsion sinusoïdale
        newX := (x + FSinTable[y] + W) mod W;
        newY := (y + FCosTable[x] + H) mod H;

        // Lecture directe de la couleur source
        srcColor := PAlphaColorArray(SrcData.GetScanline(newY))^[newX];

        // Écriture directe
        DstPtr^[x] := srcColor;
      end;
    end;
  finally
    FOriginal.Unmap(SrcData);
    FModify.Unmap(DstData);
  end;

  Result := FModify;
end;


constructor TDistortion.Create(const AImage: TBitmap);
begin
  FOriginal := TBitmap.create;
  FOriginal.Assign(AImage); // On conserve l'image d'origine
  FModify := TBitmap.create;
  FModify.Assign(AImage); // On conserve l'image d'origine
  SetLength(FSinTable, FOriginal.Height);  // On dimensionne le tableau des valeurs précalculées utilisant sinus à la dimensions de la hauteur de l'image
  SetLength(FCosTable, FOriginal.Width);  // On dimensionne le tableau des valeurs précalculées utilisant cosinus à la dimensions de la largeur de l'image
  time := 0;
  amplitudeX := 50;
  frequencyX := 0.05;
  amplitudeY := 0;
  frequencyY := 0;
  speed := 0.1;
  distortionStyle := TDistortionStyle.all;
end;

destructor TDistortion.Destroy;
begin
  FOriginal.Free;
  FModify.free;
  inherited;
end;

function TDistortion.restoreOriginal: TBitmap;
begin
  result := Foriginal;
end;

// Calcul les valeurs de modification de décalage en X par ligne
procedure TDistortion.BuildSinTable(const AHeight: Integer);
begin
  var start := 0;
  var endY := AHeight;
  if distortionStyle = TDistortionStyle.top then endy := round(AHeight * 0.5);
  if distortionStyle = TDistortionStyle.bottom then start := round(AHeight * 0.5);
  var amplitude := 0.0;
  for var i := start to endY - 1 do begin
    if start = 0 then amplitude := amplitudeX
    else begin
      if amplitude < amplitudeX then amplitude := amplitude + 0.1
      else amplitude := amplitudeX;
    end;
    FSinTable[i] := Round(Sin(time + i * frequencyX) * amplitude);
  end;
end;

// Calcul les valeurs de modification de décalage en Y par colonne
procedure TDistortion.BuildCosTable(const AWidth: Integer);
begin
  for var i := 0 to AWidth - 1 do
    FCosTable[i] := Round(Cos(time + i * frequencyY) * amplitudeY);
end;

end.
