unit Generator;

{ $DEFINE LETTER}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, Noise, Viewer;

const
  NH = 4;
  NV = 4;
  DEF_PROG_LEN = 50;
  MUT_MEM = 10;
  MUT_PROG = 5;

type
  MemArray = array[0..255] of Byte;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    Prog: array[0..NV * NH - 1] of string;
    Mem: array[0..NV * NH - 1] of MemArray;
    LastProg: array[0..1] of string;
    LastMem: array[0..1] of MemArray;
    Cur: Integer;
    Enlarge: Integer;

    procedure Mutate;
    procedure DrawNext (Sender: TObject; var Done: Boolean);
    procedure Paint;

  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}



procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormCreate(Sender: TObject);
  var
    i, j, k, N, a, b: Integer;
begin
  Randomize;

 {$IFDEF LETTER}
  with Image3.Canvas do
  begin
    Font.Name := 'Arial';
    Font.Size := 4 * Image3.Height div 5;
    Font.Style := [fsBold];
    TextOut ((Image3.Width - TextWidth ('A')) div 2, (Image3.Height - TextHeight ('A')) div 2, 'A');
  end;
  for j := 0 to Image2.Height - 1 do
    for i := 0 to Image2.Width - 1 do
    begin
      k := 0;
      for b := -1 to 1 do
        for a := -1 to 1 do
          if Image3.Canvas.Pixels[i+b, j+a] = clBlack then
            Inc (k);
      k := k * 12;
      if Image3.Canvas.Pixels[i, j] = clBlack then
        Inc (k, $80);
      Image2.Canvas.Pixels[i, j] := RGB (k, k, k);
    end;
 {$ENDIF}
  Image2.Visible := FALSE;
  Image3.Visible := FALSE;

  for j := 0 to NV - 1 do
    for i := 0 to NH - 1 do
    begin
      N := j * NH + i;
      for k := 0 to 255 do
        Mem[N, k] := Random (256);
      Prog[N] := '';
      for k := 0 to DEF_PROG_LEN - 1 do
        Prog[N] := Prog[N] + Chr (Random (256)) + Chr (Random (256));
    end;

  Application.OnIdle := DrawNext;
  Cur := 0;
  Enlarge := -1;
end;

function LimitRGB (R, G, B: Integer): Integer;
begin
  if R < 0 then R := 0 else if R > 255 then R := 255;
  if G < 0 then G := 0 else if G > 255 then G := 255;
  if B < 0 then B := 0 else if B > 255 then B := 255;
  LimitRGB := RGB (R, G, B);
end;

procedure GetRGB (RGB: Integer; var R: Integer; var G: Integer; var B: Integer);
begin
  R := RGB and $FF;
  G := (RGB shr 8) and $FF;
  B := (RGB shr 16) and $FF;
end;

procedure Draw (c: TCanvas; x, y, w, h: Integer; const Prog: string; const Mem: MemArray; img: TImage);
  var
    R, G, B: Integer;
    A: Integer;
    i, j, k, ii, jj, ai, aj: Integer;
    RX, RY, r1, r2: Real;
    Opcode, Data: Integer;
    Skip: Integer;
    CX, CY: Integer;
begin
  c.Brush.Color := RGB (Mem[0], Mem[1], Mem[2]);



  for j := 0 to h - 1 do
  begin
    for i := 0 to w - 1 do
    begin
      ii := i - w div 2;
      jj := j - h div 2;
      ai := 256 * abs (ii) div w;
      aj := 256 * abs (jj) div h;
      ii := 256 * i div w;
      jj := 256 * j div h;

      RX := i / w;
      RY := j / h;

      R := Mem[3];
      G := Mem[4];
      B := Mem[5];

      CX := Mem[6];
      CY := Mem[7];

      A := Round (255 * (Noise2 (RX * 5 + CX / W, RY * 5 + CY / H)));


      Skip := 0;

      for k := 0 to Length (Prog) div 2 - 1 do
      begin
        Opcode := Ord (Prog[2 * k + 1]);
        Data := Ord (Prog[2 * k + 2]);

        if Skip > 0 then
          Dec (Skip)
        else
        case Opcode of
           0: begin R := A; G := A; B := A; end;
           1: begin R := Data; G := Data; B := Data; end;

           2: A := i;
           3: A := j;

           4: Dec (R);
           5: Dec (G);
           6: Dec (B);
           7: Dec (A);

           8: Inc (R);
           9: Inc (G);
          10: Inc (B);
          11: Inc (A);

          12: Dec (R, Data);
          13: Dec (G, Data);
          14: Dec (B, Data);
          15: Dec (A, Data);

          16: Inc (R, Data);
          17: Inc (G, Data);
          18: Inc (B, Data);
          19: Inc (A, Data);

          20: Dec (R, ai);
          21: Dec (G, ai);
          22: Dec (B, ai);
          23: Dec (A, ai);

          24: Inc (R, ai);
          25: Inc (G, ai);
          26: Inc (B, ai);
          27: Inc (A, ai);

          28: R := R * Data;
          29: G := G * Data;
          30: B := B * Data;
          31: A := A * Data;

          32: R := Mem[Data and $FF];
          33: G := Mem[Data and $FF];
          34: B := Mem[Data and $FF];
          35: A := Mem[Data and $FF];

          36: Inc (R, ((Data - $80) div $20) * Mem[ii and $FF]);
          37: Inc (G, ((Data - $80) div $20) * Mem[ii and $FF]);
          38: Inc (B, ((Data - $80) div $20) * Mem[ii and $FF]);
          39: Inc (A, ((Data - $80) div $20) * Mem[ii and $FF]);

          40: Inc (R, ((Data - $80) div $20) * Mem[jj and $FF]);
          41: Inc (G, ((Data - $80) div $20) * Mem[jj and $FF]);
          42: Inc (R, ((Data - $80) div $20) * Mem[jj and $FF]);
          43: Inc (R, ((Data - $80) div $20) * Mem[jj and $FF]);

          44: R := Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $3) + 1 + CY / H))));
          45: G := Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $3) + 1 + CY / H))));
          46: B := Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $3) + 1 + CY / H))));
          47: A := Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $3) + 1 + CY / H))));

          48: Inc (R, Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $3) + 1 + CY / H)))));
          49: Inc (G, Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $3) + 1 + CY / H)))));
          50: Inc (B, Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $3) + 1 + CY / H)))));
          51: Inc (A, Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $3) + 1 + CY / H)))));

          52: R := R + Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $F) + 1 + CY / H))));
          53: G := G + Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $F) + 1 + CY / H))));
          54: B := B + Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $F) + 1 + CY / H))));
          55: A := A + Round (255 * (Noise2 (RX * ((Data and $3) + 1 + CX / W), RY * ((Data and $F) + 1 + CY / H))));

          56: R := A;
          57: G := A;
          58: B := A;

          59: R := A * Data and $F;
          60: G := A * Data and $F;
          61: B := A * Data and $F;

          62: R := -R + Data;
          63: G := -G + Data;
          64: B := -B + Data;

          65: R := R + Round (255 * (Noise2 (RX / ((Data and $3) + 1 + CX / W), RY / ((Data and $F) + 1 + CY / H))));
          66: G := G + Round (255 * (Noise2 (RX / ((Data and $3) + 1 + CX / W), RY / ((Data and $F) + 1 + CY / H))));
          67: B := B + Round (255 * (Noise2 (RX / ((Data and $3) + 1 + CX / W), RY / ((Data and $F) + 1 + CY / H))));
          68: A := A + Round (255 * (Noise2 (RX / ((Data and $3) + 1 + CX / W), RY / ((Data and $F) + 1 + CY / H))));

          69: R := Abs (R);
          70: G := Abs (G);
          71: B := Abs (B);

          72: R := Round (256 * Sin (A / 64));
          73: G := Round (256 * Sin (A / 64));
          74: B := Round (256 * Sin (A / 64));

          75: A := i;
          76: A := j;

          77: R := R + A;
          78: G := G + A;
          79: B := B + A;

          80: if A < $80 then Skip := Data and $F;
          81: Skip := A and 1;

          82: Inc (R, ii);
          83: Inc (G, ii);
          84: Inc (B, ii);
          85: Inc (A, ii);

          86: Inc (R, jj);
          87: Inc (G, jj);
          88: Inc (B, jj);
          89: Inc (A, jj);

          90: if A < Data then Skip := Data and $F;

          91: CX := Data * w div 256;
          92: CY := Data * h div 256;
          93: begin
                r1 := Sqr (CX / 256 - rx);
                r2 := Sqr (CY / 256 - ry);
                A := Round (Sqrt (Data * (r1 + r2)));
              end;
          94: begin
                r1 := Sqr (CX / 256 - rx);
                r2 := Sqr (CY / 256 - ry);
                A := Round (Sqrt (Data * (r1 + r2)) / 16);
              end;

          95: A := Abs (A);

          96: R := R * Data div 256;
          97: G := G * Data div 256;
          98: B := B * Data div 256;
          99: A := A * Data div 256;

         100: R := R + (Data - 128) div 256;
         101: G := G + (Data - 128) div 256;
         102: B := B + (Data - 128) div 256;
         103: A := A + (Data - 128) div 256;

         104: A := Round (128 * Sin (A / 64));
         105: A := Round (128 * Cos (A / 64));
         106: A := Round (128 * ArcTan (A / 64));

         107: A := A div 2;
         108: A := A * 2;

         109: A := Round (128 * Noise1 (A / 64 + CX / W + CY / H));

         110: R := R - A;
         111: G := G - A;
         112: B := B - A;

         113: R := 255 - R + Data;
         114: G := 255 - G + Data;
         115: B := 255 - B + Data;
         116: A := 255 - A + Data;

         117: A := Data * (((ii+10000) div ((Data and $3F) + 1) + ((jj+10000) div ((Data and $3F) + 1)) mod 2));

        {$IFDEF LETTER}
         118: GetRGB (img.Canvas.Pixels[Round (RX * img.Width), Round (RY * img.Height)], R, G, B);
         119: GetRGB (img.Canvas.Pixels[Round (RX * img.Width), Round (RY * img.Height)], A, A, A);
        {$ENDIF}




        end;

      end;

      c.Pixels[x + i, y + j] := LimitRGB (R, G, B);
    end;
  end;
  Sleep (1);

end;

procedure TMainForm.Mutate;
  var
    i, j: Integer;
    N: Integer;
    k: Integer;
begin
  N := Cur;
 // for j := 0 to NV - 1 do
 //   for i := 0 to NH - 1 do
    begin
 //     N := j * NH + i;

      for k := 1 to MUT_MEM do
        Mem[N, Random (256)] := Random (256);

      for k := 1 to MUT_PROG do
        Prog[N, Random (Length (Prog[N]) - 1) + 1] := Chr (Random (256));

    end;
end;

procedure TMainForm.Paint;
  var
    i, j: Integer;
    w, h: Integer;
    N: Integer;
begin
  if Enlarge >= 0 then
  begin
    w := Form2.Image1.Width;
    h := Form2.Image1.Height;

    N := Enlarge;

    Form2.Show;
    Draw (Form2.Image1.Canvas, 0, 0, w, h, Prog[N], Mem[N], Image2);

    //Sleep (1000);

    Enlarge := -1;
  end
  else
  begin

    w := Image1.Width div NH;
    h := Image1.Height div NV;
    for j := 0 to NV - 1 do
      for i := 0 to NH - 1 do
      begin
        N := j * NH + i;
        if N = Cur then
        begin
          Draw (Image1.Canvas, i * w, j * h, w, h, Prog[N], Mem[N], Image2);
          Image1.Repaint;
        end;
      end;

  end;
end;

procedure TMainForm.DrawNext (Sender: TObject; var Done: Boolean);
begin
  Done := FALSE;

  Mutate;
  Paint;

  Inc (Cur);
  Cur := Cur mod (NH * NV);
  
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  Image1.Picture.Bitmap.Width := MainForm.ClientWidth;
  Image1.Picture.Bitmap.Height := MainForm.ClientHeight;
end;

procedure TMainForm.New1Click(Sender: TObject);
begin
  FormCreate (Sender);
end;

procedure TMainForm.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    i, j: Integer;
    w, h: Integer;
    N, M: Integer;
begin
  w := MainForm.ClientWidth div NH;
  h := MainForm.ClientHeight div NV;
  M := (Y div h) * NH + X div w;

  if ssShift in Shift then
  begin
    if Button = mbLeft then
    begin
      Enlarge := M;
    end;

  end
  else
  begin
    if Button = mbMiddle then
    begin
      Mem[M] := LastMem[1];
      Prog[M] := LastProg[1];
    end
    else
      if Button = mbRight then
      begin
        Mem[M] := LastMem[0];
        Prog[M] := LastProg[0];
      end
      else
      begin
        LastProg[1] := LastProg[0];
        LastMem[1] := LastMem[0];
        LastProg[0] := Prog[M];
        LastMem[0] := Mem[M];
      end;

    for j := 0 to NV - 1 do
      for i := 0 to NH - 1 do
      begin
        N := j * NH + i;
        if N <> M then
        begin
          Mem[N] := Mem[M];
          Prog[N] := Prog[M];
        end;
      end;
    end;

 // Mutate;
end;

end.
