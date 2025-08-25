unit distortion;

interface

uses System.Math, FMX.Types, FMX.Filter.Effects, FMX.Graphics, FMX.Objects, System.UITypes, system.sysutils;

type
  TDistortionStyle = (all, middle);
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
  srcColor: TAlphaColor;
begin
  time := time + speed;
  // time a changé, on recacule les valeurs dans les 2 tableaux
  BuildSinTable(FOriginal.Height);
  BuildCosTable(FOriginal.Width);

  if not (FOriginal.Map(TMapAccess.Read, SrcData) and
          FModify.Map(TMapAccess.Write, DstData)) then begin
    Result := nil;
    Exit;
  end;

  try
    for var y := 0 to FOriginal.Height - 1 do begin
      for var x := 0 to FOriginal.Width - 1 do begin

        var newX := x + FSinTable[y];  // On récupère la valeur depuis le tableau cela évite de la calculer pour chaque pixel
        var newY := y + FCosTable[x];  // Même chose avec le second tableau

        if inRange(newX, 0, FOriginal.Width-1) and inRange(newY, 0, FOriginal.Height-1) then  // Si les nouvelles coordonnées calculées sont bien dans l'image d'origine
          srcColor := SrcData.GetPixel(newX, newY) // alors on récupère la couleur du pixel de l'image d'origine à ces nouvelles coordonnées
        else begin
          if newX < 0 then newX := FOriginal.width + Newx
          else newX := newX - FOriginal.Width;
          if newY < 0 then newY := newY + FOriginal.height
          else newY := newy - FOriginal.height;
          if distortionStyle = TDistortionStyle.middle then newY := newY + Round(FOriginal.Height * 0.5);

          srcColor := SrcData.GetPixel(newX, newY);
        end;

        DstData.SetPixel(x, y, srcColor); // On dessine dans l'image de destination aux coordonnées (x,y) la couleur trouvée précédemment
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
  if distortionStyle = TDistortionStyle.middle then start := round(AHeight * 0.5);
  var amplitude := 0.0;
  for var i := start to AHeight - 1 do begin
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
