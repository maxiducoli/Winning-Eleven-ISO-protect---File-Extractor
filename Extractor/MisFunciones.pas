unit MisFunciones;
interface
uses
  Windows, Messages,StrUtils, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids,WinInet, JPEG, ExtCtrls;

  Type TMyArray = array of Byte;

  Function BuscarTamVags(Archivo : UTF8String; const Cadena : UTF8string) : TStringList;
  Function BuscarOffsetVags(Archivo : UTF8String; const Cadena : UTF8string) : TStringList;
  Function BuscarVags (Archivo : UTF8String; const Cadena : UTF8string) : TStringList;
  Function ToRgb(cor : String;tipo:integer) :integer;
  Function ToHexa(corrgb : integer) : String;
  Function elev(num1,num2:integer):integer;
  Function BuscaStringEnFichero(const Fichero: string ;const Cadena: UTF8string):integer;
  function BuscaStringsEnFichero(const Fichero: string ;const Cadena: UTF8string; PosicionArchivo : int64):integer;
  procedure InsertarFicheroEnLaIso(const ISO : String; const Ruta: String; const Fichero : string; FicheroABuscar : string);
  Procedure ExtraerFicheroDeLaIso(const ISO : String ; const Fichero : string; const Directorio : string);
  Function BuscarGrafico(const ruta : string) : TStringGrid;
  Function BuscarPaleta (Const Ruta : String) : TStringGrid;
  Function tamanho(ruta:string;off:integer):integer;
  Procedure Descomprimir(RutaDestino : String;RutaOrigen : String; OffSet : Integer);
  Function formatearcodigo(entrada : string):string;
  Function selectCodigo(tipo : integer):string;
  function Desformatearcodigo(entrada : string):string;
  procedure ScreenShot(activeWindow: bool; destBitmap : TBitmap) ;
  function FindWindowByTitle(WindowTitle: string): Hwnd;
  function LeerArchivo(FileName: TFileName): string;
  procedure EscribirArchivo(FileName: TFileName; S: string);
  Function PasarAHexaPor2 (Valor : String): String;
  function UrlEncode(const DecodedStr: String; Pluses: Boolean): String;
  function UrlDecode(const EncodedStr: String): String;
  function HexToInt(HexStr: String): Int64;
  function Encode64(S: string): string;
  function HTTPEncode(const AStr: string): string;
  Function BorrarEspacio(S:String):String;
  function DownloadToBmp(Url: string; Bitmap: TBitmap): Boolean;
  function DownloadToStream(Url: string; Stream: TStream): Boolean;
  Function UltimoCaracter(s: string) : string;
  function ultimoahexa(s:string):string;
  function CopyEntre(Cadena:string; Desde,Hasta:string):string;
  Function PrimerosNumeros(s:string):string;
  Function InsertarEspacio(S:String):String;
  Function FindVAGs(Archivo : UTF8String; const Cadena : UTF8string) : TStringList;
  Procedure InsertVAG(aVAG,aISORA:  UTF8String; aFileSize, aFileOffset, maxFileSize : Integer);
  procedure FixVAGS(aVaGFile : UTF8String);
  Function GetLBABlocksCount(aFile : string): Cardinal;
  procedure WriteFile(aRA_Size : integer; aRAFile, aVagFile : string; finishFile : Boolean);
  procedure GetPointers(aIso, aRA : String; aList : TStringList; aLBA : integer;aLastByte: Integer);
  Procedure WritePointers(aISOPath : String; aBlock : Array of Byte; aBlockCount, aOffset : integer);
  Function EraseZeros(aHex : String; aHexSize : Integer) : String;
  Function InvertHex(aHex : string) : string;
  function CreateArray(aHex : string) : TMyArray;
  Function FindFilesOnIso(aFile: String;aFileInIso : UTF8String): TStringList;
  procedure WriteDataOnFile(aData : UTF8String; aFile : String; aOffset, aFileLength : integer);
  procedure GetResource(aResourceName, aOutPut : string);
  Function ReadFile(aFile : String) :  UTF8String;
  Function CompressFile(aProgram, aInputFile, aOutPutFile : string) : Boolean;
  function EjecutarYEsperar( sPrograma: String; Visibilidad: Integer ): Integer;
  function GetClutSize(aTimFileIn : string) : integer;
  procedure ExtractCLUT(aTimFile, aOutputClut : string);
  procedure openPicture(aPicture,outputFile : string);
  procedure ReadPointers(afile, aISO : string; aoffset, aSize, aLBAAmount : integer; aList : TListBox);
  Procedure FindVagsLBA(filePath : String; aList : TStringList);
  Function FindRA(aFile: String): TStringList;
  function FindLBAStart(aFile : string) : TStringList;
  function ReadRAFile(fileRA, fileISO : String) : TStringList;
//-------------------------------------------------------
  implementation

   // Ejecuta un programa y espera a que este termine
 // El parámetro iVisibilidad puede ser:

 //SW_SHOWNORMAL     -> Lo normal
 //SW_SHOWMINIMIZED  -> Minimizado (ventanas MS-DOS o ventanas no modales)
 //SW_HIDE           -> Oculto     (ventanas MS-DOS o ventanas no modales)

 //La función devuelve un cero si la ejecución terminó correctamente.

 function EjecutarYEsperar( sPrograma: String; Visibilidad: Integer ): Integer;
var
  sAplicacion: array[0..512] of char;
  DirectorioActual: array[0..255] of char;
  DirectorioTrabajo: String;
  InformacionInicial: TStartupInfo;
  InformacionProceso: TProcessInformation;
  iResultado, iCodigoSalida: DWord;
begin
  StrPCopy( sAplicacion, sPrograma );
  GetDir( 0, DirectorioTrabajo );
  StrPCopy( DirectorioActual, DirectorioTrabajo );
  FillChar( InformacionInicial, Sizeof( InformacionInicial ), #0 );
  InformacionInicial.cb := Sizeof( InformacionInicial );

  InformacionInicial.dwFlags := STARTF_USESHOWWINDOW;
  InformacionInicial.wShowWindow := Visibilidad;
  CreateProcess( nil, sAplicacion, nil, nil, False,
                 CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                 nil, nil, InformacionInicial, InformacionProceso );

  // Espera hasta que termina la ejecución
  repeat
    iCodigoSalida := WaitForSingleObject( InformacionProceso.hProcess, 1000 );
    Application.ProcessMessages;
  until ( iCodigoSalida <> WAIT_TIMEOUT );

  GetExitCodeProcess( InformacionProceso.hProcess, iResultado );
  MessageBeep( 0 );
  CloseHandle( InformacionProceso.hProcess );
  Result := iResultado;
end;

  //-------------------------
  Function InsertarEspacio(S:String):String;
  var a : string;
  i : integer;
  begin
  for i := 1 to Length(s) do
  begin
  a :=  a + copy(trim(s),1,2) + ' ';
  delete(s,1,2);
  end;
  Result := Trim(a);
  end;
 //-------------------------



  //---------------------------------------
  //-----------------------
Function PrimerosNumeros(s:string):string;
var a:string;
begin
a := a + s[1] + s[2];
if a = '00' then result := a;
End;

  //-----------------------
  //--------------------------
function CopyEntre(Cadena:string; Desde,Hasta:string):string;
  {
   ATENCION: Uses StrUtils para PosEx
   Devuelve una sub-string de la string 'Cadena' comprendida
   entre 'Desde' y 'Hasta'
   Ejemplo:
           Cadena:='213123123[bloke]Devuelve esto[/bloke]23423423245';
           Trozo:=CopyEntre(Cadena,'[bloke]','[/bloke]';
   Trozo valdría: 'Devuelve esto'
  }
  var
    Inicio,Final: integer;
  begin
    Result:='';
    Inicio:=Pos(Desde,Cadena)+Length(Desde);
    Final :=PosEx(Hasta,Cadena,Inicio);
    if (Inicio>0) and (Final>Inicio) then Result:=Copy( Cadena, Inicio, Final-Inicio );
  end;

  //--------------------------
//------------------------
function DownloadToStream(Url: string; Stream: TStream): Boolean;
var
  hNet: HINTERNET;
  hUrl: HINTERNET;
  Buffer: array[0..10240] of Char;
  BytesRead: DWORD;
begin
  Result := FALSE;
  hNet := InternetOpen('agent', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if (hNet <> nil) then
  begin
    hUrl := InternetOpenUrl(hNet, PChar(Url), nil, 0,
      INTERNET_FLAG_RELOAD, 0);
    if (hUrl <> nil) then
    begin
      while (InternetReadFile(hUrl, @Buffer, sizeof(Buffer), BytesRead)) do
      begin
        if (BytesRead = 0) then
        begin
          Result := TRUE;
          break;
        end;
        Stream.WriteBuffer(Buffer,BytesRead);
      end;
      InternetCloseHandle(hUrl);
    end;
    InternetCloseHandle(hNet);
  end;
         end;
//------------------------
//-----------------------
function DownloadToBmp(Url: string; Bitmap: TBitmap): Boolean;
var
  Stream: TMemoryStream;
  Jpg: TJPEGImage;
begin
  Result:= FALSE;
  Stream:= TMemoryStream.Create;
  try
    try
      if DownloadToStream(Url, Stream) then
      begin
        Jpg:= TJPEGImage.Create;
        try
          Stream.Seek(0,soFromBeginning);
          Jpg.LoadFromStream(Stream);
          Bitmap.Assign(Jpg);
          Result:= TRUE;
        finally
          Jpg.Free;
        end;
      end;
    finally
      Stream.Free;
    end;
  except end;
end;
//-----------------------
//------------------
function ultimoahexa(s:string):string;
var i : integer;
a : string;
begin
for i := 1 to length(s) do
If Length(s) = 10 then
begin
a := s;
result := a;
exit
end else
begin
if i < Length(s) then
begin
a := a + s[i]
end else
begin
a := a + inttohex(ord(s[i]),2);
end;
end;
result := a;
end;
//--------------------
//-------------------------
Function UltimoCaracter(s: string) : string;
var i :integer;
a : string;
const hexa = ['A'..'F','0'..'9'];
begin
for i := 0 to Length(s) do
begin
if s[i] in Hexa then
begin
a := a + s[i]
end else
begin
a := a + inttohex(ord(s[i]),2);
end;
end;
result := a;
end;
//-------------------------

//--------------------------------------------------
 Function BorrarEspacio(S:String):String;
 var i : integer;
 Begin
 For i := 0 to Length(s)- 1 do
 begin
 if s[i] = ' ' then Delete(s,i,1);
 end;
 Result := s;
 End;
//------------------------------------------------
function HTTPEncode(const AStr: string): string;
const
  NoConversion = ['A'..'Z', 'a'..'z', '*', '@', '.', '_', '-'];
var
  Sp, Rp: PChar;
begin
  SetLength(Result, Length(AStr) * 3);
  Sp := PChar(AStr);
  Rp := PChar(Result);
  while Sp^ <> #0 do
  begin
    if Sp^ in NoConversion then
      Rp^ := Sp^
    else if Sp^ = ' ' then
      Rp^ := '+'
    else
    begin
      FormatBuf(Rp^, 3, '%%%.2x', 6, [Ord(Sp^)]);
      Inc(Rp, 2);
    end;
    Inc(Rp);
    Inc(Sp);
  end;
  SetLength(Result, Rp - PChar(Result));
end;
//------------------------------------------------
 function UrlEncode(const DecodedStr: String; Pluses: Boolean): String;
var
  I: Integer;
begin
  Result := '';
  if Length(DecodedStr) > 0 then
    for I := 1 to Length(DecodedStr) do
    begin
      if not (DecodedStr[I] in ['0'..'9', 'a'..'z',
                                       'A'..'Z', ' ']) then
        Result := Result + '%' + IntToHex(Ord(DecodedStr[I]), 2)
      else if not (DecodedStr[I] = ' ') then
        Result := Result + DecodedStr[I]
      else
        begin
          if not Pluses then
            Result := Result + '%20'
          else
            Result := Result + '+';
        end;
    end;
end;

function UrlDecode(const EncodedStr: String): String;
var
  I: Integer;
begin
  Result := '';
  if Length(EncodedStr) > 0 then
  begin
    I := 1;
    while I <= Length(EncodedStr) do
    begin
      if EncodedStr[I] = '%' then
        begin
       // If EncodedStr[I+1] + EncodedStr[I+2] = '00' then Result := Result + '00';

          Result := Result + Chr(HexToInt(EncodedStr[I+1]
                                       + EncodedStr[I+2]));
          I := Succ(Succ(I));
        end
      else if EncodedStr[I] = '+' then
        Result := Result + ' '
      else
        Result := Result + EncodedStr[I];

      I := Succ(I);
    end;
  end;
end;

function HexToInt(HexStr: String): Int64;
var RetVar : Int64;
    i : byte;
begin
  HexStr := UpperCase(HexStr);
  if HexStr[length(HexStr)] = 'H' then
     Delete(HexStr,length(HexStr),1);
  RetVar := 0;

  for i := 1 to length(HexStr) do begin
      RetVar := RetVar shl 4;
      if HexStr[i] in ['0'..'9'] then
         RetVar := RetVar + (byte(HexStr[i]) - 48)
      else
         if HexStr[i] in ['A'..'F'] then
            RetVar := RetVar + (byte(HexStr[i]) - 55)
         else begin
            Retvar := 0;
            break;
         end;
  end;

  Result := RetVar;
end;



//-------------------------------------------------------
  Function PasarAHexaPor2 (Valor : String): String;
  Var i : Integer;
  Begin
  i := 2;
  Copy(Valor,1,i);
  Delete(Valor,1,i);
  Result := VAlor;
  End;

///--------------------------------------------------------------------
  procedure EscribirArchivo(FileName: TFileName; S: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    Stream.WriteBuffer(Pointer(S)^, Length(S));
  finally
    Stream.Free;
  end;
end;

function LeerArchivo(FileName: TFileName): string;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetString(Result, nil, Stream.Size);
    Stream.Read(Pointer(Result)^, Stream.Size);
  finally
    Stream.Free;
  end;
end;


//----------------------------------------
function FindWindowByTitle(WindowTitle: string): Hwnd;
var
  NextHandle: Hwnd;
  NextTitle: array[0..260] of char;
begin
  // Get the first window
  NextHandle := GetWindow(Application.Handle, GW_HWNDFIRST);
  while NextHandle > 0 do
  begin
    // retrieve its text
    GetWindowText(NextHandle, NextTitle, 255);
    if Pos(WindowTitle, StrPas(NextTitle)) <> 0 then
    begin
      Result := NextHandle;
      Exit;
    end
    else
      // Get the next window
      NextHandle := GetWindow(NextHandle, GW_HWNDNEXT);
  end;
  Result := 0;
end;



//---------------------------------CAPTURAR PANTALLA--------------------------------\\
procedure ScreenShot(activeWindow: bool; destBitmap : TBitmap) ;
var
   w,h : integer;
   DC : HDC;
   hWin : Cardinal;
   r : TRect;
begin
   if activeWindow then
   begin
     hWin := GetForegroundWindow;
     dc := GetWindowDC(hWin) ;
     GetWindowRect(hWin,r) ;
     w := 300;
     h := 300;
   end
   else
   begin
     hWin := GetDesktopWindow;
     dc := GetDC(hWin) ;
     w := GetDeviceCaps (DC, HORZRES) ;
     h := GetDeviceCaps (DC, VERTRES) ;
   end;

   try
    destBitmap.Width := w;
    destBitmap.Height := h;
    BitBlt(destBitmap.Canvas.Handle,
           0,
           0,
           destBitmap.Width,
           destBitmap.Height,
           DC,
           0,
           0,
           SRCCOPY) ;
   finally
    ReleaseDC(hWin, DC) ;
   end;
end;

//--------------------------------Quitar los % de los codigos del PET----------------------------------\\
//---------------------------------Formatear codigos Pets------------------------------\\
function Desformatearcodigo(entrada : string):string;
var salida : string;
begin
 if length(entrada) = 14 then
begin
salida := AnsiMidSTR(entrada,1,2) + ' ' +
AnsiMidSTR(entrada,4,2) + ' ' +
AnsiMidSTR(entrada,7,2) + ' ' +
AnsiMidSTR(entrada,10,2) + ' '
+ AnsiMidSTR(entrada,13,2);
end else
begin
salida := AnsiMidSTR(entrada,1,2) + ' ' +
AnsiMidSTR(entrada,4,2) + ' ' +
AnsiMidSTR(entrada,7,2) + ' ' +
AnsiMidSTR(entrada,10,4);
end;
result := salida;
end;



//---------------------------------Seleccionar tipo de codigo -------------------------\\
function selectCodigo(tipo : integer):string;
var cartel : string;
begin
if tipo = 14 then
begin
cartel :='Este producto es recomendable enviarlo con una manzana ($5)';
end else
begin
Cartel:='Este producto es recomendable enviarlo con un choclo ($5)';
end;
Result := Cartel;
end;

//---------------------------------Formatear codigos Pets------------------------------\\
function formatearcodigo(entrada : string):string;
var salida : string;
begin
 if length(entrada) = 14 then
begin
salida := AnsiMidSTR(entrada,1,2) + '%' +
AnsiMidSTR(entrada,4,2) + '%' +
AnsiMidSTR(entrada,7,2) + '%' +
AnsiMidSTR(entrada,10,2) + '%'
+ AnsiMidSTR(entrada,13,2);
end else
begin
salida := AnsiMidSTR(entrada,1,2) + '%' +
AnsiMidSTR(entrada,4,2) + '%' +
AnsiMidSTR(entrada,7,2) + '%' +
AnsiMidSTR(entrada,10,4);
end;
result := salida;
end;




// -----------------------------Buscar PAleta en los archivos BIN------------------------\\

Function BuscarPaleta(Const ruta : string) : TStringGrid;



var Arq2 : TFileStream;
    x:integer;
    b:integer;
    aBuffer2: array of char;
    h:integer;
    he:string;
    offset,offdif,off,tempor :integer;
    c,npos,valor:integer;
    busca,busca2: integer;
    Agraf , Agraf2 : Array Of String;
    Lista : TStringGrid;
    Lista2 : TStringList;


begin
Lista := TStringGrid.Create(nil);

Lista.ColCount := 9;
Lista.RowCount := 2;

Lista.ColWidths[0]:=30;
Lista.ColWidths[1]:=80;
Lista.ColWidths[2]:=90;
Lista.ColWidths[3]:=60;
Lista.ColWidths[4]:=50;
Lista.ColWidths[5]:=50;
Lista.ColWidths[6]:=50;
Lista.ColWidths[7]:=52;
Lista.ColWidths[8]:=40;

Lista.Cells[0,0]:='ID';
Lista.Cells[1,0]:='Offset Decimal';
Lista.Cells[2,0]:='Offset Hexadecimal';
Lista.Cells[3,0]:='VRAM X';
Lista.Cells[4,0]:='VRAM Y';
Lista.Cells[5,0]:='Largo';
Lista.Cells[6,0]:='Altura';
Lista.Cells[7,0]:='Tamaño';
Lista.Cells[8,0]:='Colores';


Lista2 := TStringList.Create;
Lista2.Clear;

                Arq2 := TFileStream.Create(ruta,fmOpenRead);
                x:=Arq2.Size;
                setlength(aBuffer2,x);
                setlength(aGraf2,x);
                Arq2.Position := 0;
                Arq2.Read(Pointer(aBuffer2)^,x);
                for b :=0 to x-1 do begin
                        h:=Ord(aBuffer2[b]);
                        he:=inttohex(h,2);
                        aGraf2[b]:=he;
                end;
                Arq2.Free;

                for b:=0 to x-16 do begin
                if   ((aGraf2[b]='09') and
                     (aGraf2[b+10]='00') and (aGraf2[b+11] ='00') and
                     (aGraf2[b+15]='80') and ((aGraf2[b+14]='10') or
                     (aGraf2[b+14]='11') or (aGraf2[b+14]='12') or
                     (aGraf2[b+14]='0C') or (aGraf2[b+14]='0D') or
                     (aGraf2[b+14]='0E') or (aGraf2[b+14]='0F') or
                     (aGraf2[b+14]='08'))) then

                 begin
                        offset:=0;

                        If aGraf2[b+14] = '08' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]) +5352;
                        If aGraf2[b+14] = '0C' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]) - 32768;
                        If aGraf2[b+14] = '0D' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]) + 32768;
                        If aGraf2[b+14] = '0E' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]) + 98304;
                        If aGraf2[b+14] = '0F' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]);
                        If aGraf2[b+14] = '10' Then offset := strtoint('$' + '1' + aGraf2[b+13]+aGraf2[b+12]);
                        If aGraf2[b+14] = '11' Then offset := strtoint('$' + '2' + aGraf2[b+13]+aGraf2[b+12]);
                        If aGraf2[b+14] = '12' Then offset := strtoint('$' + '3' + aGraf2[b+13]+aGraf2[b+12]);

                        Lista.Cells[0,Lista.RowCount-1]:=inttostr(Lista.RowCount-1);
                        Lista.Cells[1,Lista.RowCount-1]:=inttostr(offset);
                        Lista.Cells[2,Lista.RowCount-1]:=inttohex(offset,4);
                        Lista.Cells[3,Lista.RowCount-1]:=inttostr(strtoint('$' + aGraf2[b+3]+aGraf2[b+2]));
                        Lista.Cells[4,Lista.RowCount-1]:=inttostr(strtoint('$' + aGraf2[b+5]+aGraf2[b+4]));
                        Lista.Cells[5,Lista.RowCount-1]:=inttostr(strtoint('$' + aGraf2[b+7]+aGraf2[b+6])*2);
                        Lista.Cells[6,Lista.RowCount-1]:=inttostr(strtoint('$' + aGraf2[b+9]+aGraf2[b+8]));
                        Lista.RowCount:=Lista.RowCount+1;

                        lista2.add(inttostr(offset));

                end;
               If (aGraf2[b]='0A') and (aGraf2[b+1]='00') and
                (aGraf2[b+10]='00') and (aGraf2[b+11] ='00') and
                (aGraf2[b+15]='80') and ((aGraf2[b+14]='10') or
                (aGraf2[b+14]='11') or (aGraf2[b+14]='12') or
                (aGraf2[b+14]='0C') or (aGraf2[b+14]='0D') or
                (aGraf2[b+14]='0E') or (aGraf2[b+14]='0F')or
                (aGraf2[b+14]='08')) then
                 begin
                        If aGraf2[b+14] = '08' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]) +5320;
                        If aGraf2[b+14] = '0C' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]) - 32768;
                        If aGraf2[b+14] = '0D' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]) + 32768;
                        If aGraf2[b+14] = '0E' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]) + 98304;
                        If aGraf2[b+14] = '0F' Then offset := strtoint('$' + aGraf2[b+13]+aGraf2[b+12]);
                        If aGraf2[b+14] = '10' Then offset := strtoint('$' + '1' + aGraf2[b+13]+aGraf2[b+12]);
                        If aGraf2[b+14] = '11' Then offset := strtoint('$' + '2' + aGraf2[b+13]+aGraf2[b+12]);
                        If aGraf2[b+14] = '12' Then offset := strtoint('$' + '3' + aGraf2[b+13]+aGraf2[b+12]);

                        lista2.add(inttostr(offset));
                end;


        end;
        Lista.RowCount:=Lista.RowCount-1;


for b:=0 to Lista.RowCount -3 do begin
 for c:=0 to lista2.count-1 do begin
      if strtoint(lista2.strings[c])=strtoint(Lista.Cells[1,b+1]) then
      npos:=c;
end;

valor:=strtoint(Lista.Cells[1,b+2]);
tempor:=strtoint(lista2.strings[npos+1])-strtoint(lista2.strings[npos]);
Lista.Cells[7,b+1]:=inttostr(strtoint(lista2.strings[npos+1])-strtoint(lista2.strings[npos]));
Lista.Cells[8,b+1]:=inttostr(strtoint(Lista.Cells[7,b+1]) div 2);

if ((aGraf2[valor-32]='0A') and (aGraf2[valor-31]='00') and
   (aGraf2[valor-23]='00') and (aGraf2[valor-22] ='00') and
   (aGraf2[valor-17]='80') and ((aGraf2[valor-18]='10') or
   (aGraf2[valor-18]='11') or (aGraf2[valor-18]='12') or
   (aGraf2[valor-18]='0C') or (aGraf2[valor-18]='0D') or
   (aGraf2[valor-18]='0E') or (aGraf2[valor-18]='0F')or
   (aGraf2[valor-18]='08')))
   or
   ((aGraf2[valor-32]='09') and
   (aGraf2[valor-23]='00') and (aGraf2[valor-22] ='00') and
   (aGraf2[valor-17]='80') and ((aGraf2[valor-18]='10') or
   (aGraf2[valor-18]='11') or (aGraf2[valor-18]='12') or
   (aGraf2[valor-18]='0C') or (aGraf2[valor-18]='0D') or
   (aGraf2[valor-18]='0E') or (aGraf2[valor-18]='0F') or
   (aGraf2[valor-18]='08'))) then

   tempor:=strtoint(lista2.strings[npos+1])-strtoint(lista2.strings[npos])-32;
   Lista.Cells[7,b+1]:=inttostr(tempor);
   Lista.Cells[8,b+1]:=inttostr(tempor div 2);

end;

        busca:=strtoint(Lista.Cells[1,Lista.RowCount-1]);

        repeat
        busca:=busca+1;
        until


                ((aGraf2[busca]='0A') and (aGraf2[busca+1]='00') and
                (aGraf2[busca+10]='00') and (aGraf2[busca+11] ='00') and
                (aGraf2[busca+15]='80') and ((aGraf2[busca+14]='10') or
                (aGraf2[busca+14]='11') or (aGraf2[busca+14]='12') or
                (aGraf2[busca+14]='0C') or (aGraf2[busca+14]='0D') or
                (aGraf2[busca+14]='0E') or (aGraf2[busca+14]='0F')or
                (aGraf2[busca+14]='08')))
                 or
                 ((aGraf2[busca]='09') and
                (aGraf2[busca+10]='00') and (aGraf2[busca+11] ='00') and
                (aGraf2[busca+15]='80') and ((aGraf2[busca+14]='10') or
                (aGraf2[busca+14]='11') or (aGraf2[busca+14]='12') or
                (aGraf2[busca+14]='0C') or (aGraf2[busca+14]='0D') or
                (aGraf2[busca+14]='0E') or (aGraf2[busca+14]='0F') or
                (aGraf2[busca+14]='08')));

                tempor:=busca-strtoint(Lista.Cells[1,Lista.RowCount-1]);
                Lista.Cells[7,Lista.RowCount-1]:=inttostr(tempor);
                Lista.Cells[8,Lista.RowCount-1]:=inttostr(tempor div 2);
                Result := TStringGRid(Lista);

        end;







//------------------------------Descomprimir Grafico -------------------------\\

Procedure Descomprimir(RutaDestino : String;RutaOrigen : String ; OffSet : Integer);
var
    Anovo : Array Of String;
    Agraf : Array Of String;
    ABuffer : Array Of Char;
    Archivo,Salvado : TFileStream;
    orig:integer;
    k:integer;
    k2:integer;
    j,x,b:integer;
    k3:integer;
    i:integer;
    nloop,tmp,typo : integer;
    bb:integer;
    bits:byte;
    h,modif , counter: integer;
    he : String;
begin

ArChivo := TFileStream.Create(rutaorigen,fmOpenRead);
                x:=Archivo.Size;
                setlength(aBuffer,x);
                setlength(aGraf,x);
                Archivo.Position := 0;
                Archivo.Read(Pointer(aBuffer)^,x);
                for b :=0 to x-1 do begin
                        h:=Ord(aBuffer[b]);
                        he:=inttohex(h,2);
                        aGraf[b]:=he;
                end;
                Archivo.Free;

// Rutina de descompresion

setlength(aNovo,300000);
for bb:= 0 to 299999 do aNovo[bb]:='00';
counter:=0;
i := 0;
modif := 2000;
orig:=offset;
bits:=4;
typo := 1;
While (True) do
begin
    If (i And 256) = 0 Then
    begin
        k := (strtoint('$' + aGraf[orig]));
        orig := orig + 1;
        Counter := Counter + 1;
        i := k + 65280;
    end;
    k2 := (strtoint('$' + aGraf[orig]));

    If (i And 1) = 0 Then
    begin
        aNovo[modif]:= inttohex(k2,2);
        modif := modif + 1;
        orig := orig + 1;
        Counter := Counter + 1;
    End
    else begin
        If (k2 And 128) <> 0 Then
        begin
            orig := orig + 1;
            Counter := Counter + 1;
            If (k2 And 64) <> 0 Then
            begin
                k := k2;
                k3 := k - 185;
                If k = 255 Then  begin


//Salvado := TFileStream.Create(RutaDestino,FMCreate);
//SAlvado.Position := 0;
//Salvado.Write(ANovo[2000],8192);
//Salvado.Free;

                exit;
                end;
                for nloop:=k3 downto 0 do begin
                    k2 := (strtoint('$' + aGraf[orig]));
                    orig := orig + 1;
                    modif := modif + 1;
                    aNovo[modif - 1] := inttohex(k2,2);
                end;
                    Counter:=Counter + k3;

                i:=i shr 1;
                continue;

            end;
                j := (k2 And 15) + 1;
                k3 := (k2 shr 4) - 7;
        End
        else begin
                j := (strtoint('$' + aGraf[orig + 1]));
                orig := orig + 2;
                Counter := Counter + 2;
                k3 := (k2 shr 2) + 2;
                j := j Or (k2 And 3) shl 8;
        End;
          for nloop:=k3 downto 0 do begin
                tmp:=(strtoint('$'+aNovo[modif-j]));
                aNovo[modif] := inttohex(tmp,2);
                modif := modif + 1;
           end;
    End;
   i := i shr 1;
   end;

end;



//---------------------Tamaño del grafico en los archivos BIN----------------------\\

function tamanho(ruta : string;off:integer):integer;
var
    aGraf : Array Of String;
    Archivo : TFileStream;
    orig:integer;
    k:integer;
    k2:integer;
    j:integer;
    k3:integer;
    i:integer;
    tmp : integer;
    bb:integer;
    bits:byte;
    counter:integer;
    x,b,h,Offset,tama : Integer;
    he : String;
    aBuffer : Array Of Char;
begin

ArChivo := TFileStream.Create(ruta,fmOpenRead);
                x:=Archivo.Size;
                setlength(aBuffer,x);
                setlength(aGraf,x);
                Archivo.Position := 0;
                Archivo.Read(Pointer(aBuffer)^,x);
                for b :=0 to x-1 do begin
                        h:=Ord(aBuffer[b]);
                        he:=inttohex(h,2);
                        aGraf[b]:=he;
                end;
                Archivo.Free;

counter:=0;
i := 0;
orig:=off;

While (True) do
begin
    If (i And 256) = 0 Then
    begin
        k := (strtoint('$' + aGraf[orig])) And 255;
        orig := orig + 1;
        Counter := Counter + 1;
        i := (k Or 65280);
    end;
    k2 := (strtoint('$' + aGraf[orig])) And 255;

    If (i And 1) = 0 Then
    begin
        orig := orig + 1;
        Counter := Counter + 1;
    End
    else begin
        If (k2 And 128) <> 0 Then
        begin
            orig := orig + 1;
            Counter := Counter + 1;
            If (k2 And 64) <> 0 Then
            begin
                k := k2 And 255;
                k3 := k - 185;
                If k = 255 Then  begin
                tamanho:=counter;
                exit;
                end;
                repeat
                    k2 := (strtoint('$' + aGraf[orig])) And 255;
                    orig := orig + 1;
                    Counter := Counter + 1;
                    k3 := k3 - 1;
                until (k3 < 0);
                i:=i shr 1;
                continue;

            end;
                j := (k2 And 15) + 1;
                k3 := (k2 shr 4) - 7;
        End
        else begin
                j := (strtoint('$' + aGraf[orig + 1])) And 255;
                orig := orig + 2;
                Counter := Counter + 2;
                k3 := (k2 shr 2) + 2;
                j := j Or (k2 And 3) shl 8;
        End;
          repeat
                k3 := k3 - 1 ;
          until (k3 < 0);
    End;
    i := i shr 1;
end;
end;


//------------------ Buscar OffSets de los graficos en los archivos BIN----------------------\\
Function BuscarGrafico(const ruta : string) : TStringGrid;
var
agraf : Array Of String;
aBuffer : Array Of Char;
x,b,h,Offset,tama : Integer;
he : String;
ListaGraficos : TStringGrid;
Archivo : TFileStream;
Begin

ListaGraficos := TStringGrid.Create(nil);
ListaGraficos.ColCount := 8;
ListaGraficos.RowCount := 2;

ListaGRaficos.ColWidths[0]:=30;
ListaGRaficos.ColWidths[1]:=80;
ListaGRaficos.ColWidths[2]:=90;
ListaGRaficos.ColWidths[3]:=60;
ListaGRaficos.ColWidths[4]:=50;
ListaGRaficos.ColWidths[5]:=50;
ListaGRaficos.ColWidths[6]:=50;
ListaGRaficos.ColWidths[7]:=52;

ListaGraficos.Cells[0,0]:='ID';
ListaGraficos.Cells[1,0]:='Offset Decimal';
ListaGraficos.Cells[2,0]:='Offset Hexadecimal';
ListaGraficos.Cells[3,0]:='VRAM X';
ListaGraficos.Cells[4,0]:='VRAM Y';
ListaGraficos.Cells[5,0]:='Largo';
ListaGraficos.Cells[6,0]:='Altura';
ListaGraficos.Cells[7,0]:='Tamaño';

ArChivo := TFileStream.Create(ruta,fmOpenRead);
                x:=Archivo.Size;
                setlength(aBuffer,x);
                setlength(aGraf,x);
                Archivo.Position := 0;
                Archivo.Read(Pointer(aBuffer)^,x);
                for b :=0 to x-1 do begin
                        h:=Ord(aBuffer[b]);
                        he:=inttohex(h,2);
                        aGraf[b]:=he;
                end;
                Archivo.Free;
                for b:=0 to x-16 do begin

                        If (aGraf[b]='0A') and (aGraf[b+1]='00') and
                        (aGraf[b+10]='00') and (aGraf[b+11] ='00') and
                        (aGraf[b+15]='80') and ((aGraf[b+14]='10') or
                        (aGraf[b+14]='11') or (aGraf[b+14]='12') or
                        (aGraf[b+14]='0C') or (aGraf[b+14]='0D') or
                        (aGraf[b+14]='0E') or (aGraf[b+14]='0F') or
                        (aGraf[b+14]='08')) then
                        begin
                                offset:=0;
                                If aGraf[b+14] = '08' Then offset := strtoint('$' + aGraf[b+13]+aGraf[b+12]) +5320;
                                If aGraf[b+14] = '0C' Then offset := strtoint('$' + aGraf[b+13]+aGraf[b+12]) - 32768;
                                If aGraf[b+14] = '0D' Then offset := strtoint('$' + aGraf[b+13]+aGraf[b+12]) + 32768;
                                If aGraf[b+14] = '0E' Then offset := strtoint('$' + aGraf[b+13]+aGraf[b+12]) + 98304;
                                If aGraf[b+14] = '0F' Then offset := strtoint('$' + aGraf[b+13]+aGraf[b+12]);
                                If aGraf[b+14] = '10' Then offset := strtoint('$' + '1' + aGraf[b+13]+aGraf[b+12]);
                                If aGraf[b+14] = '11' Then offset := strtoint('$' + '2' + aGraf[b+13]+aGraf[b+12]);
                                If aGraf[b+14] = '12' Then offset := strtoint('$' + '3' + aGraf[b+13]+aGraf[b+12]);

                              ListaGraficos.cells[0,ListaGraficos.RowCount-1]:=inttostr(ListaGRaficos.rowcount-1);
                              ListaGraficos.Cells[1,ListaGraficos.RowCount-1]:=inttostr(offset);
                              ListaGraficos.Cells[2,ListaGraficos.RowCount-1]:=inttohex(offset,4);
                              ListaGraficos.Cells[3,ListaGraficos.RowCount-1]:=inttostr(strtoint('$' + aGraf[b+3]+aGraf[b+2]));
                              ListaGraficos.Cells[4,ListaGraficos.RowCount-1]:=inttostr(strtoint('$' + aGraf[b+5]+aGraf[b+4]));
                              ListaGraficos.Cells[5,ListaGraficos.RowCount-1]:=inttostr(strtoint('$' + aGraf[b+7]+aGraf[b+6])*2);
                              ListaGraficos.Cells[6,ListaGraficos.RowCount-1]:=inttostr(strtoint('$' + aGraf[b+9]+aGraf[b+8]));
                              ListaGraficos.Cells[7,ListaGraficos.RowCount-1]:=inttostr(tamanho(ruta,offset));
                              ListaGraficos.RowCount:=ListaGraficos.RowCount+1;


                        end;
                     end;
                                          Result := TStringGrid(ListaGraficos);

end;


// ---------- FUNCION DE HEXA PARA RGB ----------

Function ToRgb(cor : String;tipo:integer) :integer;
var RVA,RVA2:array[0..2] of integer;
    flag : Boolean;
    dato:integer;
    suma,suma2:integer;
    resto:integer;
    j:integer;
    i:integer;
begin
dato:=strtoint( '$' + cor);

For j := 1 To 3 do begin
   suma := 0 ;
   For i := 1 To 5 do begin
     resto := dato Mod 2;
     dato := dato div 2;
     suma := suma + (resto * (elev(2, (i-1))));

   end;
   suma2:=suma;
   flag := True;
   If (suma = 0) And (flag = True) Then begin
        suma:= 0;
        flag:= False;
   end;

   If (suma = 1) And (flag = True) Then begin
        suma:= 8;
        flag:= False;
   End;

   If (suma = 2) And (flag = True) Then begin
        suma:= 16;
        flag:= False;
   End;

   If (suma = 3) And (flag = True) Then begin
        suma:= 24;
        flag:= False;
   End;

   If (suma = 4) Then suma := 32;
   If (suma = 5) Then suma := 41;
   If (suma = 6) Then suma := 49;
   If (suma = 7) Then suma := 57;

   If (suma = 8) And (flag = True) Then begin
        suma:= 65;
        flag:= False;
   End;

   If (suma = 9) Then suma := 74;
   If (suma = 10) Then suma := 82;
   If (suma = 11) Then suma := 90;
   If (suma = 12) Then suma := 98;
   If (suma = 13) Then suma := 106;
   If (suma = 14) Then suma := 115;
   If (suma = 15) Then suma := 123;

   If (suma = 16) And (flag = True) Then begin
        suma := 131;
        flag := False;
   End;

   If (suma = 17) Then suma := 139;
   If (suma = 18) Then suma := 148;
   If (suma = 19) Then suma := 156;
   If (suma = 20) Then suma := 164;
   If (suma = 21) Then suma := 172;
   If (suma = 22) Then suma := 180;
   If (suma = 23) Then suma := 189;

   If (suma = 24) And (flag = True) Then begin
        suma := 197;
        flag := False;
   End;

   If (suma = 25) Then suma := 205;
   If (suma = 26) Then suma := 213;
   If (suma = 27) Then suma := 222;
   If (suma = 28) Then suma := 230;
   If (suma = 29) Then suma := 238;
   If (suma = 30) Then suma := 246;
   If (suma = 31) Then suma := 255;

   RVA[j - 1] := suma;
   RVA2[j - 1] := suma2;

   flag := True;

end;
//result = RVA[0] + (RVA[1] * 256) + (RVA[2] * 65536)
if tipo=0 then result:=rgb(RVA[0],RVA[1],RVA[2]);
if tipo=1 then result:=RVA[0];
if tipo=2 then result:=RVA[1];
if tipo=3 then result:=RVA[2];

if tipo=4 then result:=RVA2[0];
if tipo=5 then result:=RVA2[1];
if tipo=6 then result:=RVA2[2];

end;

// ---------- FUNCION DE RGB PARA HEXA ----------

Function ToHexa(corrgb : integer) : String;
var tot,valor, r, g, b: Integer;
begin
tot := corrgb;
b := GetBValue(corrgb);
g := GetGValue(corrgb);
r := GetRValue(corrgb);

valor := ((r div 8) + ((g div 8) * 32) + (b div 8) * 1024);
result := inttohex(valor,4);
End;

// ---------- FUNCION DE POTENCIA ----------

function elev(num1,num2:integer):integer;
var l:integer;

begin
result:=1;
for l:= 1 to num2 do result:=result*num1;

end;
//-----------------------------------------------
function BuscaStringEnFichero(const Fichero: string ;const Cadena: UTF8string):integer;
  const
    {Leeremos de 8K en 8K
    We will read of 8K in 8K }
    CUANTOBUFFER = 8192;
  var
    Corriente  : TFileStream;
    Almacen    : UTF8String;
    Donde      : integer;
    Parar      : boolean;
    Posicion   : integer;
  begin
    SetLength(Almacen, CUANTOBUFFER);
    Corriente:=TFileStream.Create(Fichero,fmOpenRead OR fmShareDenyNone);
    Result:=-1;
    try
      Corriente.Seek(0,soFromBeginning);
      Parar:=FALSE;
      repeat
        {Guardamos el inicio de lo leido, antes de leer
        We keep the beginning of that read, before reading }
        Posicion:=Corriente.Position;

        {Parar:=TRUE cuando no haya mas que leer o bien hayamos encontrado la cadena
         Parar(stop):=TRUE when there is not but to read or we have found the string }
        Parar:= ( Corriente.Read(Almacen[1],CUANTOBUFFER) < CUANTOBUFFER );
        {Buscamos la cadena en el Almacen leido
       We look for the string in the read Almacen }
        Donde:=Pos(Cadena, Almacen);

        If Donde <> 0 then begin
          Result:=Donde+Posicion-1;
          {Si la hemos encontrado... tambien paramos
          If we have found it... we also stopped }
          Parar:=TRUE;
        end else begin
          {Rebobinamos un poco por si la cadena estuviera en medio de dos
           páginas de CUANTOBUFFER de longitud:
          We rewind a little for if the string was in a middle of two
           pages of CUANTOBUFFER of longitude }
          Corriente.Seek(Length(Cadena),soFromCurrent);
        end;
      until Parar;
    finally
      Corriente.Free;
    end;
  end;

function BuscaStringsEnFichero(const Fichero: string ;const Cadena: UTF8string;
                               PosicionArchivo : int64):integer;
  { Busca la primera vez que la cadena 'Cadena' aparece dentro del fichero 'Fichero',
    devolviendo la posición (Offset) en la que se encuentra (contando desde el principio
    del fichero) o bien devuelve un -1 si la cadena no fué encontrada.
    It looks for the first time that the string ' Cadena' appears inside the file ' Fichero',
    returning the position (Offset) in the one that is (counting from the beginning
    of the file) or it returns a -1 if the string was not find
    Radikal Q3 para Trucomania}

  const
    {Leeremos de 8K en 8K
    We will read of 8K in 8K }
    CUANTOBUFFER = 8192;
  var
    Corriente  : TFileStream;
    Almacen    : UTF8String;
    Donde      : integer;
    Parar      : boolean;
    Posicion   : integer;
  begin
    SetLength(Almacen, CUANTOBUFFER);
    Corriente:=TFileStream.Create(Fichero,fmOpenRead OR fmShareDenyNone);
    Result:=-1;
    try
      Corriente.Seek(PosicionArchivo,soFromBeginning);
      Parar:=FALSE;
      repeat
        {Guardamos el inicio de lo leido, antes de leer
        We keep the beginning of that read, before reading }
        Posicion:=Corriente.Position;

        {Parar:=TRUE cuando no haya mas que leer o bien hayamos encontrado la cadena
         Parar(stop):=TRUE when there is not but to read or we have found the string }
        Parar:= ( Corriente.Read(Almacen[1],CUANTOBUFFER) < CUANTOBUFFER );
        {Buscamos la cadena en el Almacen leido
       We look for the string in the read Almacen }
        Donde:=Pos(Cadena, Almacen);

        If Donde <> 0 then begin
          Result:=Donde+Posicion-1;
          {Si la hemos encontrado... tambien paramos
          If we have found it... we also stopped }
          Parar:=TRUE;
        end else begin
          {Rebobinamos un poco por si la cadena estuviera en medio de dos
           páginas de CUANTOBUFFER de longitud:
          We rewind a little for if the string was in a middle of two
           pages of CUANTOBUFFER of longitude }
          Corriente.Seek(Length(Cadena),soFromCurrent);
        end;
      until Parar;
    finally
      Corriente.Free;
    end;
  end;

//-------------------------BUSCA LOS OFFSETS DE LOS ARCHIVOS VAGS DENTRO DE LOS RA-------------------------------------
Function BuscarOffsetVags(Archivo : UTF8String; const Cadena : UTF8string) : TStringList;
var
Arch : TFileStream;  // Creacion del String
buffer,texto : UTF8String;
Lista : TStringList;
Posicion : Integer;
Buf, Encontrado, ID, Offset : Integer;
Nombre : UTF8String;
begin
Lista := TStringList.Create;
Lista.Clear;
SetLength(Nombre,11);
Arch :=  TFileStream.Create(Archivo,FmOpenRead OR fmShareDenyNone);
Buf := Arch.Size;
ID := 0;
SetLength(buffer,buf);
Arch.Position :=0;
Offset := Arch.position;
arch.Read(buffer[1],Length(buffer));

Encontrado:= -1;
while Encontrado <> 0 do
begin

  //Encontrado:= POSEx(cadena,Buffer,Offset);
          Encontrado := BuscaStringsEnFichero(Archivo,cadena,offset);
        if Encontrado = -1 then break;


            Offset := Encontrado;
            Arch.Position := Offset;
            Arch.Read(nombre[1],Length(Nombre));
            Lista.Insert(ID,IntTostr(Offset));
            //Lista := Nombre + #13;
            //Lista.Cells[1,ID] := IntTostr(ID);
            inc(ID);
            Offset := Offset + 31;
//            Arch.Position := Encontrado + 500;
//Archiv'

end;
         Result := TStringList(Lista);
         arch.Free;
 //Lista.Delete(Lista.Count-1);
end;
//--------------------------------------BUSCA LA CANTIDAD DE VAGS EN LOS ARCHIVOS RA-----------------------------------
Function BuscarVags (Archivo : UTF8String; const Cadena : UTF8string) : TStringList;
var
Arch : TFileStream;
buffer,texto : UTF8String;
Lista : TStringList;
Posicion : Integer;
Buf, Encontrado, ID, Offset : Integer;
Nombre : UTF8String;
begin
Lista := TStringList.Create;
Lista.Clear;
SetLength(Nombre,32);
Arch :=  TFileStream.Create(Archivo,FmOpenRead OR fmShareDenyNone);
Buf := Arch.Size;
ID := 0;
SetLength(buffer,buf);
Arch.Position := 0;
Offset := 0;
arch.Read(buffer[1],Length(buffer));

Encontrado:= -1;

while Encontrado <> 0 do
begin

            //Encontrado:= POSEx(cadena,Buffer,Offset);
            Encontrado := BuscaStringsEnFichero(Archivo,cadena,offset);
            if Encontrado = -1 then break;

            Offset := Encontrado + 32;
            Arch.Position := Offset;
            Arch.Read(Nombre[1],Length(Nombre));
            Lista.Insert(ID,Trim( Nombre));
            //Lista := Nombre + #13;
            //Lista.Cells[1,ID] := IntTostr(ID);
            ID := ID +1;
            if ID = 275 then
            begin
             // ShowMessage('HOLA');
            end;
            offset := offset + 10;


//            Arch.Position := Encontrado + 500;
//Archiv'

end;
         Result := TStringList(Lista);
         arch.Free;
          //Lista.Delete(Lista.Count-1);
end;

//---------------------------TAMAÑO DE LOS ARCHIVOS VAG EN LOS ARCHIVOS RA--------------------------//
Function BuscarTamVags(Archivo : UTF8String; const Cadena : UTF8string) : TStringList;
var
Arch : TFileStream;
buffer,texto : UTF8String;
Lista,List : TStringList;
Posicion : Integer;
Buf, Encontrado, ID, Offset, Off1,Off2,Tam : Integer;
Nombre : UTF8String;
b : array [0..3] of byte;
it : integer;
begin
Lista := TStringList.Create;
List := TStringList.Create;
List.clear;
Lista.Clear;
SetLength(Nombre,4);
Arch :=  TFileStream.Create(Archivo,FmOpenRead OR fmShareDenyNone);
Buf := Arch.Size;
ID := 0;
SetLength(buffer,buf);
Arch.Position :=0;
Offset := Arch.position;
arch.Read(buffer[1],Length(buffer));
Tam := Arch.Size;
Encontrado:= -1;//POS(cadena,Buffer);
//vagSize := 0;
while Encontrado <> 0 do
begin

  //Encontrado:= POSEx(cadena,Buffer,Offset);
            Encontrado := BuscaStringsEnFichero(Archivo,cadena,offset);
        if Encontrado = -1 then break;

            Offset := Encontrado + 12;

            Arch.Position := Offset;

            Arch.Read(b,sizeof(b));
            nombre := IntToHex(b[0],2) + IntToHex(b[1],2)+
            IntToHex(b[2],2) + IntToHex(b[3],2);
            nombre := '$' + nombre;
            it := StrToInt(nombre);
            nombre := IntToStr(it + 32);
            Lista.Insert(ID,Nombre);
            ID := ID +1;
            Offset := Offset + 31;
end;
         Result := TStringList(Lista);
         arch.Free;
end;

//---------------------------- Extraer Ficheros de la ISO  ----------------///
Procedure ExtraerFicheroDeLaIso(const ISO : String ; const Fichero : string; const Directorio : string);
var
Archivo , temporal, ArchISO : TFileStream;
buff, nombre,cortar, largo,lba,buffer , bufferii  : UTF8string;
contador , Offset2, Offset , Tam , StartLba , Bloques, i,ii,j,k,h,m : integer;

begin

SetLength(buffer,4);
SetLength(bufferii,4);

SetLength(Cortar,11);
i := (BuscaStringEnFichero(ISO,Fichero));

if i =  -1 then
begin
MessageDlg('ISO not found', mtInformation,
      [mbOk], 0);

end
else
begin
ArchISO := TFileStream.Create(ISO,fmOpenRead OR fmShareDenyNone);
ArchISO.Position := i - 19;
ArchISO.Read(Buffer[1],4);
ii := i - 27 ;
ArchISO.Position := ii;
ArchISO.Read(Bufferii[1],4);

for k := 1 to 4 do
begin
largo := largo + inttohex((Ord(buffer[k])),2);
end;
j := HexToInt(largo);

tam := j;

for h := 1 to 4 do
begin
lba := lba + inttohex((Ord(bufferii[h])),2);
end;

m := HexToint(lba);
StartLba := m;

if j mod 2048 = 0 then
begin
Bloques := (j div 2048);
end else
    begin
      Bloques := (j div 2048) + 1;
    end;

Contador := 0;
SetLength(Buff,2048);

Offset := (startLBA * 2352) + 24;
Archiso.Position := Offset;
temporal := TFileStream.Create(directorio + Fichero,fmCreate);
Offset2 := 0;
temporal.Position := offset2;
repeat
Archiso.Read(Buff[1],Length(buff));
Temporal.Write(Buff[1],Length(Buff));
Offset := Offset + 2352;
Archiso.Position := Offset;
Offset2 := Temporal.Size;
Temporal.Position := Offset2;
Contador := Contador + 1;
until
Contador = Bloques;
Temporal.Size := tam;
Archiso.Free;
Temporal.Free;
end;
end;
//--------------Insertar Archivos en la ISO------------------//
procedure InsertarFicheroEnLaIso(const ISO : String; const Ruta: String; const Fichero : string; FicheroABuscar : string);
var
Archivo , temporal, ArchISO : TFileStream;
Path , buff, nombre,cortar, largo,lba,buffer , bufferii  : UTF8String;
contador , Offset2, Offset , Tam , StartLba , Bloques, i,ii,j,k,h,m : integer;

begin

SetLength(buffer,4);
SetLength(bufferii,4);
//Path := ExtractFilePath(iso);
SetLength(Cortar,11);
i := (BuscaStringEnFichero(ISO,FicheroABuscar));

if i =  -1 then
begin
MessageDlg('ISO not found', mtInformation,
      [mbOk], 0);

end
else
begin
ArchISO := TFileStream.Create(ISO,fmOpenReadWrite or FmShareDenyNone);
ArchISO.Position := i - 19;
ArchISO.Read(Buffer[1],4);
ii := i - 27 ;
ArchISO.Position := ii;
ArchISO.Read(Bufferii[1],4);

for k := 1 to 4 do
begin
largo := largo + inttohex((Ord(buffer[k])),2);
end;
j := HexToInt(largo);

tam := j;

for h := 1 to 4 do
begin
lba := lba + inttohex((Ord(bufferii[h])),2);
end;

m := HexToint(lba);
StartLba := m;
Bloques := (j div 2048);

Contador := 0;
SetLength(Buff,2048);

Offset := (startLBA * 2352) + 24;
Archiso.Position := Offset;
temporal := TFileStream.Create(Ruta + FICHERO,fmOpenRead or fmShareDenyNone);
Offset2 := 0;
temporal.Position := offset2;
repeat
Temporal.Read(Buff[1],Length(Buff));
Archiso.Write(Buff[1],Length(buff));
Offset := Offset + 2352;
Archiso.Position := Offset;
Offset2 := Offset2 + Length(Buff);
Temporal.Position := Offset2;
Contador := Contador + 1;
until
Contador = Bloques;
//Temporal.Size := tam;
Archiso.Free;
Temporal.Free;
end;

end;
//--------------
function Encode64(S: string): string;
 const
  Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := 1 to Length(s) do
  begin
    x := Ord(s[i]);
    b := b * 256 + x;
    a := a + 8;
    while a >= 6 do
    begin
      a := a - 6;
      x := b div (1 shl a);
      b := b mod (1 shl a);
      Result := Result + Codes64[x + 1];
    end;
  end;
  if a > 0 then
  begin
    x := b shl (6 - a);
    Result := Result + Codes64[x + 1];
  end;
end;
//------------------------------------------

function Decode64(S: string): string;
 const
  Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := 1 to Length(s) do
  begin
    x := Pos(s[i], codes64) - 1;
    if x >= 0 then
    begin
      b := b * 64 + x;
      a := a + 6;
      if a >= 8 then
      begin
        a := a - 8;
        x := b shr a;
        b := b mod (1 shl a);
        x := x mod 256;
        Result := Result + chr(x);
      end;
    end
    else
      Exit;
  end;
end;



//------------------------------------- BuscarINFODeLosVAGs -----------------------------//

Function FindVAGs(Archivo : UTF8String; const Cadena : UTF8string) : TStringList;
var
vagSize : array [0..3] of Byte; // Size of the VAG
nombreVAG : UTF8String; // Vag file name.

Arch : TFileStream; // Abrimos el archivo para lectura.

Lista : TStringList;

Posicion : Integer; // Contador de posiciones de VAGs

Encontrado, ID, Offset : Integer;
strData, vagName, vagOffset, vagSize_, buffSize : UTF8String;

b : array [0..3] of byte;
it, vagSizeInt : integer;
begin
strData := ''; // Reset Data
SetLength(nombreVAG, 16); // Seteamos el nombre del archivo del header.
//SetLength(vagSize, 4);
Lista := TStringList.Create;
//List := TStringList.Create;
Lista.Clear;
//SetLength(Nombre,4);
Arch :=  TFileStream.Create(Archivo,FmOpenRead OR fmShareDenyNone);
ID := 1;
Arch.Position :=0;
Offset := Arch.position;
Encontrado:= -1;//POS(cadena,Buffer);
//vagSize := 0;
Lista.Add('FILE;OFFSET; SIZE' );
while Encontrado <> 0 do
begin
          // Buscamos los VAGS.
          Encontrado := BuscaStringsEnFichero(Archivo,cadena,offset);

          // Si no encontramos nada, salimod.
         if Encontrado = -1 then
         begin
         ShowMessage('VAGS FOUND: ' + intToStr(ID));
             break;
         end;
            //strData := '';
            // Guardamos el offset del VAG encontrado.
            Offset := Encontrado;
            vagOffset :=  intToStr(Offset) ;
            // Posicionamos el puntero de lectura en el offset
            Arch.Position := Offset + 12;
            // Leemos el valor del tamaño del archivo VAG
            Arch.Read(vagSize,SizeOf(vagSize));
            buffSize := '';
            // Recorremos los registros para obetener el tamaño del VAG
            for it := 0 to 3 do
            begin
              buffSize := buffSize + inttohex((Ord(vagSize[it])),2);
            end;

            vagSize_ :=  IntToStr(HexToInt(buffSize) + 48) ;
              //vagSizeInt := HexToInt(vagSize);

            // Posicionamos el puntero en el offset del nombre del VAG
            Arch.Position := offset + 32;
            // Leemos el archivo con el nombre del VAG
            Arch.Read(nombreVAG[1], Length(nombreVAG));
            vagName := '"' + Trim(nombreVAG) + '"';

            // Agregamos los datos del VAG a la lista de salida.
            strData := vagName + ';' + vagOffset + ';' + vagSize_ ;
            if strData <> '' then Lista.Insert(ID,strData);

            // Incrementamos el ID
            inc(ID);
            // Vaciamos los Valores
            vagName := '';
            vagOffset := '';
            vagSize_ := '';
            strData := '';
            // Movemos el Offset
            Offset := Offset + 31;
end;
         // Devolvemos la lista
         Result := TStringList(Lista);
         // Liberamos el RA
         arch.Free;
end;


Procedure InsertVAG(aVAG,aISORA: UTF8String; aFileSize, aFileOffset, maxFileSize : Integer);
  var
  aFile : TFileStream; // Archivo para leer el VAG
  aMainFile : TFileStream; // Archivo para insertar
  aBuffer : UTF8String; //
  i : integer;
  begin
  //SetLength(aBuffer, aFileSize); // Seteamos el buffer para leer.
  aFile := TFileStream.Create(aVAG, fmOpenReadWrite); // Abrimos el VAG

   if aFile.Size  > aFileSize then
    begin

          if MessageDlg('Your file is great than max file Size. ' +
          'Do you want to continue?. This may damage your work',mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
          begin
          SetLength(aBuffer,maxFileSize);

          aMainFile := TFileStream.Create(aISORA, fmOpenReadWrite OR fmShareDenyNone); // Abrimos el RA
                  try
                  aFile.Position := 0; // Posicionamos el VAG para empezar a leer.
                  aFile.Read(aBuffer[1], Length(aBuffer)); // Leemos el VAG
                  FixVAGS(aBuffer);
                  //aFile.Position := aFile.Size - SizeOf(aEOF);
                  //aFile.Write(aEOF,SizeOf(aEOF));
                  //aFile.Position := 0; // Posicionamos el VAG para empezar a leer.
                  //aFile.Read(aBuffer[1], Length(aBuffer)); // Leemos el VAG

                  aMainFile.Position := aFileOffset; // Posicionamos el RA
                  aMainFile.Write(aBuffer[1], Length(aBuffer)); // Escribimos el RA
                  finally
                    aFile.Free; // Liberamos VAG
                    aMainFile.Free; // Liberamos RA
                  end;
          end else
          begin
          aFile.Free;
          ShowMessage('Operation cancelled by user');
          exit
          end;
        end         else
    begin
       aMainFile := TFileStream.Create(aISORA, fmOpenReadWrite OR fmShareDenyNone); // Abrimos el RA
        try
           SetLength(aBuffer, aFileSize);
           aFile.Position := 0; // Posicionamos el VAG para empezar a leer.
           aFile.Read(aBuffer[1], Length(aBuffer)); // Leemos el VAH
           aMainFile.Position := aFileOffset; // Posicionamos el RA
           aMainFile.Write(aBuffer[1], Length(aBuffer)); // Escribimos el RA
        finally
           aFile.Free; // Liberamos VAG
           aMainFile.Free; // Liberamos RA
        end;
     end;


  end;

   procedure FixVAGS(aVaGFile : UTF8String);
  var
  aEOF : array[0..15] of Byte;
  aStream : TMemoryStream;
  begin
  aEOF[0] := $00;
  aEOF[1] := $07;
  aEOF[2] := $77;
  aEOF[3] := $77;
  aEOF[4] := $77;
  aEOF[5] := $77;
  aEOF[6] := $77;
  aEOF[7] := $77;
  aEOF[8] := $77;
  aEOF[9] := $77;
  aEOF[10] := $77;
  aEOF[11] := $77;
  aEOF[12] := $77;
  aEOF[13] := $77;
  aEOF[14] := $77;
  aEOF[15] := $77;

  aStream := TMemoryStream.Create();
  try
  aStream.Seek32(0,soBeginning);
  aStream.Position := 0;
  aStream.Read(aVaGFile[1],length(aVaGFile));
  aStream.Seek(Length(aVaGFile) - SizeOf(aEOF), soBeginning);
  aStream.Write(aEOF,SizeOf(aEOF));
  finally
    aStream.Free;
  end;
     end;


 Function GetLBABlocksCount(aFile : string): Cardinal;
CONST BLOCKSIZE = 2048;
var
aTempFile : TFileStream;
arest : Double;
begin
aTempFile := TFileStream.Create(aFile, fmOpenRead);

arest := aTempFile.Size mod 2048;

if arest <> 0 then
begin
Result := aTempFile.Size div 2048 + 1;
end else
begin
  Result := aTempFile.Size div 2048;
end;


try

finally
  aTempFile.Free;
end;

end;

procedure WriteFile(aRA_Size : integer; aRAFile, aVagFile : string; finishFile : Boolean);
var
aTempFile : TFileStream;
aRaF : TFileStream;
abuff : TMemoryStream;
aBlockSize, aTempFileSize: Integer;
aVagFileSize, aFillVagSize : Cardinal;
aFileContent, aFill, aFillVag : UTF8String;
aFileCont : array of Byte;
i, j : Cardinal;
//aRAHeader : TFileStream;
afillChar : Byte;
begin
afillChar := 0;
aRAF := TFileStream.Create(aRAFile, fmOpenReadWrite or fmShareDenyNone);
abuff := TMemoryStream.Create;
//aRaF.Position := 0;
aRaF.Seek(0, soEnd );
try

        aBlockSize := GetLBABlocksCount(aVagFile);

        // VAG
        aTempFile := TFileStream.Create(aVagFile, fmOpenRead + fmShareDenyNone);

        aTempFile.Seek(0, soBeginning);

        aTempFileSize :=(aBlockSize * 2048);

        SetLength(aFileContent,aTempFile.Size);

        aTempFile.Read(aFileContent[1],Length(aFileContent));

        aRaF.Write(aFileContent[1],Length(aFileContent));

          j := aTempFileSize - aTempFile.Size ;

          if j > 0 then
          begin
          j := aTempFileSize - aTempFile.Size ;
          end;

          if j = 0 then
          begin
            j := aTempFile.Size;
          end;

        for I := 0 to j - 1 do
          begin
            aRaf.Seek(0, soEnd);
            aRaF.Write(aFillChar,SizeOf(aFillChar));
          end;
        // Tamaño con LBA

        //aVagFileSize := (aBlockSize * 2048) + 2048;
        //aFileContent := '';

//        aFillVagSize :=  (aBlockSize * 2048) - aTempFile.Size;
//        SetLength(aFillVag, aFillVagSize);
//
        aRaF.Seek(0, soEnd);

//        aRaF.Write(aFillVag[1], Length(aFillVag));

//        aRaF.Size := aTempFileSize
 // end;



finally
  aTempFile.Free;


  if finishFile then
  begin

  SetLength(aFill ,aRA_Size - aRaF.Size);
  aRaF.Write(aFill[1],Length(aFill));
  aRaF.Size := aRA_Size;
  //ShowMessage('Listo!');
  //aRaF.Free;
  end;
  if aRaF <> nil then freeAndNil(aRaF);

end;


end;


procedure GetPointers(aIso, aRA : String; aList : TStringList;aLBA : integer; aLastByte: Integer);
 var
 aIsoFile, aRAFile : TFileStream;
 aVAGSize : integer;
 aLBAPosition, aTempLBA : integer;
 aOffset, aTempOffset : integer;
 aOffsetList : TStringList;
 i : integer;
 aTempLine, aTempHex, aInvertHex : String;
 aTempVaGSize : array[0..3] of Byte;
 aArray : TMyArray;
 //aName : UTF8String;
 begin
 //SetLength(aName, 11);
 aoffset := 0;
 aOffsetList := TStringList.Create;


 aRAFile := TFileStream.Create(aRA, fmOpenRead + fmShareDenyNone);
 aOffsetList := BuscarOffsetVags(aRA,'VAGp');


 for I := 0 to aOffsetList.Count - 1 do
   begin
   // OFFSET DEL VAG
   aTempLBA := StrToInt(aOffsetList[i]);
   //aTempLine := aTempLine + aOffsetList[i] + ';';
     //     BUSCAMOS LBA y lo que tenga que ser al RA
     if aTempLBA mod 2048 = 0 then
     begin
     aLBAPosition := (aTempLBA div 2048) + aLBA;
     end else
     begin
     aLBAPosition := ((aTempLBA div 2048) + 1) + aLBA;
     end;
     // Escribimos el LBA en la variable de texto
     aTempLine := aTempLine + InvertHex(IntToHex(aLBAPosition,2))  ;
     //aTempLine := aTempLine + IntToHex(aLBAPosition) + ';' ;

     //  leemos El tamaño del VAG
     aTempOffset := strToInt(aOffsetList[i]) + 12;
     aRAFile.Position := aTempOffset;
     aRAFile.Read(aTempVaGSize, SizeOf(aTempVaGSize));
     aTempHex := IntToHex(aTempVAGSize[0]) + IntToHex(aTempVAGSize[1]) +
                                IntToHex(aTempVAGSize[2]) + IntToHex(aTempVAGSize[3]);
     //aTempLine := aTempLine + IntToStr( HexToInt(aTempHex));
//     aInvertHex := copy(aTempHex,7,2) + copy(aTempHex,5,2) + copy(aTempHex,3,2) + copy(aTempHex,1,2);
//     aTempLine :=
     aTempLBA := HexToInt(aTempHex) + 48;
//     aTempLine := aTempLine + IntToHex(aTempLBA + 48) + ';';
     if aTempLBA mod 2048 = 0 then
     begin
        aTempLBA := aTempLBA div 2048;
     end else
         begin
         aTempLBA := (aTempLBA div 2048) + 1;
         end;

     // TAMAÑO DEL VAG EN LBA
     aTempLine := aTempLine + IntToHex(aTempLBA,2)+  IntToHex(aLastByte,2);
     aTempLine := InvertHex(aTempLine);
//     aRAFile.Position := aTempOffset + 20;
//     aRAFile.Read(aName[1],length(aName));
//     aTempLine := aTempLine + TRIM(aName);
     if (aTempLine <> '')  then  aList.add(aTempLine);
     aTempLine := '';
     aTempHex := '';

   end;

 end;



function CreateArray(aHex : string) : TMyArray;
 CONST aByteLarge = 2;
 var
 aTempByte : TMyArray;
 aStartPosition ,  aLength : integer;
 i : integer;
 begin
 aStartPosition := 1;
 aLength := Length(aHex);
 aTempByte[0] := 0;
 aTempByte[1] := 0;
 aTempByte[2] := 0;
 aTempByte[3] := 0;
 i := 0;
 repeat

 aTempByte[i] := Ord(HexToInt(Copy(aHex,aStartPosition,aByteLarge)));
 aStartPosition := aStartPosition + aByteLarge;
 inc(i);
 until (aStartPosition >= aLength);

 Result := aTempByte;
 end;

Procedure WritePointers(aISOPath : String; aBlock : Array of Byte; aBlockCount, aOffset : integer);
 var
 aISOFile : TFileStream;
 aTempOffset : integer;
 i : integer;
 begin
 //SetLength(aTempArray, aBlockCount);
 aTempOffset := aOffset;


 aISOFile := TFileStream.Create(aISOPath, fmOpenWrite + fmShareDenyNone);
 try

   aISOFile.Position := aTempOffset;
   aISOFile.Write(aBlock,SizeOf(aBlockCount));

 finally
   aISOFile.Free;
 end;




 end;

Function EraseZeros(aHex : String; aHexSize : Integer) : String;
var
aValue, aNewValue, aDummy : String;
aStartOffset : Integer;

begin
aStartOffset := 1;
aValue := '';
aNewValue := '';

repeat
aNewValue := copy(aHex,aStartOffset,aHexSize);

if aNewValue = '00' then
begin
aValue := aValue + '';
end else
    begin
      aValue := aValue +  aNewValue;
    end;
aStartOffset := aStartOffset + aHexSize;
until (aStartOffset >= Length(aHex));

Result := aValue;
end;

Function InvertHex(aHex : string) : string;
var
aValue : string;
aLength : Integer;
begin
aValue := '';
aLength := Length(aHex);
repeat

  aValue := aValue + Copy(aHex,aLength - 1,2);

  aLength := aLength - 2;

until (aLength <= 0);

Result := aValue;

end;


Function FindFilesOnIso(aFile: String; aFileInIso : UTF8String): TStringList;
var
  aFileToRead: TFileStream;
  // Archivoaleer
  Buffer: UTF8String; // Buffer donde guardo los datos a leer
  Lista: TStringList; // Listas con los datos
  nomArchivo: UTF8String; // Nombre del archivo VAG
  posArchivo, tamArchivo: Integer;
  Encontrado, ID, Offset: Integer;
  // Contadores y registros varios
begin

  aFileToRead := TFileStream.Create(aFile, FmOpenRead OR FmShareDenyNone);
  // Abrimos el archivo
  aFileToRead.Position := 0;
  Lista := TStringList.Create; // Resultado
  Lista.Clear; // Limpio la lista
  SetLength(nomArchivo, 12);
  // Asigno el largo del nombre con todo y su extensión (VAG)
  ID := 0; // regitro de archivos
  Offset := 0; // Posiciono el Offset a 0
  Encontrado := -1; // POS(cadena,Buffer);
  // seteamos a 0 la posición para empezar a leer el archivo.
  while Encontrado <> 0 do
  begin
    Encontrado := BuscaStringsEnFichero(aFile, aFileInIso, Offset);
    // Buscamos el VAG. OFFSET si existe -1 Si no.
    if Encontrado = -1 then // Si no encuentra más VAGS, sale.
      break;
    Offset := Encontrado - 8;
    aFileToRead.Position := Offset;
    aFileToRead.Read(nomArchivo[1], Length(nomArchivo));

    Lista.Add(Trim(nomArchivo)); // .Insert(ID,Trim(nomArchivo));
    ID := ID + 1;
    Offset := Offset + 15;
  end;
  Result := Lista;
end;


  procedure WriteDataOnFile(aData : UTF8String; aFile : String; aOffset, aFileLength : integer);
  var
  aTempFile : TFileStream;
  begin

  if Length(aData) > aFileLength then
  begin
  if MessageDlg('The File is greater than block',mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrNo  then
  exit
  end else
  begin
  aTempFile := TFileStream.Create(aFile,fmOpenWrite + fmShareDenyNone);
  try
  // Posicionamos el cursor del archivo en el inicio
  // Posicionamos el archivo a escribir en el offset correspondiente
  aTempFile.Position := aOffset;

  // Escribimos el archivo con los datos leidos.
  aTempFile.Write(aData[1], Length(aData));

  finally
    aTempFile.Free;
  end;
  end;

  end;

  Function ReadFile(aFile : String) : UTF8String;
  var
  aTempFile : TFileStream;
  aData : UTF8String;
  begin
  aTempFile := TFileStream.Create(aFile,fmOpenRead);
  try
    aTempFile.Position := 0;
    SetLength(aData,aTempFile.Size);
    aTempFile.Read(aData[1], Length(aData));
  finally
    aTempFile.Free;
  end;
  Result := aData;
  end;

  function GetaFileSize(aFile : string) : integer;
  var
  aTempFile: TFileStream;
  begin


  aTempFile := TFileStream.Create(aFile, fmOpenRead);
  try
    Result := aTempFile.Size;
  finally
    aTempFile.Free;
  end;

  end;

  procedure GetResource(aResourceName, aOutPut : string);
  var
  aStream: TResourceStream;
  begin

  aStream := TResourceStream.Create(HInstance, aResourceName , RT_RCDATA);
  try
   aStream.SaveToFile(aOutPut);

  finally
   aStream.Free;
  end;
  end;

  Function CompressFile(aProgram, aInputFile, aOutPutFile : string) : Boolean;
  var
  cmd : string;
  begin

  cmd := '"' + aProgram + '" ' + '-f "' + aInputFile + '" -o "' + aOutPutFile + '"';
  if EjecutarYEsperar(cmd,SW_HIDE) = 0 then
  begin
  Result := true;
  end else
    begin
      Result := False;
    end;

  end;

 function GetClutSize(aTimFileIn : string) : integer;
 var
 aClutSize : Byte;
 aTim : TFileStream;
 begin
 aTim := TFileStream.Create(aTimFileIn, fmOpenRead);
 try
 aTim.position := 4;
 aTim.Read(aClutSize, sizeOf(aClutSize));
 finally
   aTim.Free;

   case aClutSize of
   8: Result := 32;
   9: Result := 512;
   end;

 end;
 end;

 procedure ExtractCLUT(aTimFile, aOutputClut : string);
 var
 aTim,aPal : TFileStream;
 aData : UTF8String;
 aClutSize : integer;
 begin

 aClutSize := GetClutSize(aTimFile);

 aTim := TFileStream.Create(aTimFile,fmOpenRead);
 aPal := TFileStream.Create(aOutputClut,fmCreate);
 try
 aTim.Position := 20;
 SetLength(aData, aClutSize);
 aTim.Read(aData[1],Length(aData));
 finally
   aTim.Free;
   aPal.Write(aData[1], Length(aData));
   aPal.Free;
 end;

 end;

 procedure openPicture(aPicture, outputFile : string);
  var
  Picture: TPicture;
  Bitmap: TBitmap;
 begin
  Picture := TPicture.Create;
  try
    Picture.LoadFromFile(aPicture);
    Bitmap := TBitmap.Create;
    try
      Bitmap.Width := Picture.Width;
      Bitmap.Height := Picture.Height;
      Bitmap.Canvas.Draw(0, 0, Picture.Graphic);
      Bitmap.SaveToFile(outputFile);
    finally
      Bitmap.Free;
    end;
  finally
    Picture.Free;

  end;
   end;



 procedure ReadPointers(afile, aISO : string; aoffset, aSize, aLBAAmount : integer; aList : TListBox);
var
aTempFile, aISOFile : TFileStream;
i,aIndex, aTempOffset,aISOOffset : integer;
aVAGName : UTF8String;
aDataArray : array [0..3] of Byte;
aHexOffset, aTempLine : String;
aLst : TStringList;
begin
aIndex := 0;
SetLength(aVAGName,11);
aTempLine := '';
aLst := TStringList.Create;
aLst.DelimitedText := ';';
aLst.StrictDelimiter := true;
aLst.Clear;
aLst.Add('#;Puntero completo; Posición LBA del puntero(HEX);Posición LBA del puntero (DEC);' +
         'Tamaño del archivo VAG en bloques LBA(HEX);Tamaño del archivo VAG en bloques LBA(DEC);' +
         'Indicador deconocido(HEX);Indicador deconocido(DEC);' +
         'Offset en la ISO;' + 'Nombre del fichero al que apunta');

aTempOffset := aoffset;
aTempFile := TFileStream.Create(afile, fmOpenRead or fmShareDenyNone);
aISOFile := TFileStream.Create(aISO, fmOpenRead or fmShareDenyNone);

try
  aTempFile.Position := aTempOffset;

  while i <= aSize do
  begin
    aTempLine := IntToStr(aIndex) + ';';
    aTempFile.Read(aDataArray, SizeOf(aDataArray)); // Leemos los datos del puntero
    aHexOffset := '$' + IntToHex(adataArray[0]) + IntToHex(aDataArray[1]); // Juntamos los dos bytes
    aTempLine := aTempLine + IntToHex(aDataArray[0],2) + IntToHex(aDataArray[1],2) +
                 IntToHex(aDataArray[2],2) + IntToHex(aDataArray[3],2) + ';'; // Puntero completo

    aTempLine := aTempLine + IntToHex(aDataArray[0],2) + IntToHex(aDataArray[1],2) + ';'; // Posicion LBA
    aTempLine := aTempLine + IntToStr(Swap(StrToInt(aHexOffset))) + ';'; // posicion LBA DEC
    aTempLine := aTempLine + IntToHex(aDataArray[2],2) + ';'; // Tamaño del bloque LBA del VAG HEX
    aTempLine := aTempLine + IntToHex(aDataArray[2],2) + ';'; // Tamaño del bloque LBA del VAG DEC
    aTempLine := aTempLine + IntToStr(aDataArray[3]) + ';'; // Byte desconocido
    aTempLine := aTempLine + IntToStr(aDataArray[3]) + ';'; // Byte desconocido

    aISOOffset := Swap(StrToInt((aHexOffset)));  // Pasamos el offset a entero
    aISOOffset := ((aISOOffset + aLBAAmount) * 2352) + 24;
    aTempLine := aTempLine + IntToStr(aISOOffset) + ';'; // Offset en la ISO

    aISOFile.Position := aISOOffset + 32;
    aISOFile.Read(aVAGName[1], Length(aVAGName));
    aTempLine := aTempLine + TRIM(aVAGName);
    aLst.Add(aTempLine);

    aTempOffset := aTempOffset + 4;
    i := i + 4;
    inc(aIndex);
    aTempLine := '';
  end;

finally
  aTempFile.Free;
  aList.Items := aLst;
  aLst.Free;
end;
end;


 Procedure FindVagsLBA(filePath : String; aList : TStringList);
 CONST jumpSize = 2352;
 CONST jumpVAGp = 12;
 CONST vagp = 'VAGp';
 var
aISOFile : TFileStream;
aLBAData : Array [0..3] of Byte;
aVAGName, aTempData : UTF8String;
aVAGp : Array [0..3] of Byte;

aLine, aVAGTemp : String;
aOffset, aTempOffset : integer;

 begin
 SetLength(aVAGName, 11);
 SetLength( aTempData ,48);
 aOffset := 12;
 aISOFile := TFileStream.Create(filePath, fmOpenRead);
 try
 aLine := '';
 aList.DelimitedText := ';';
 aList.StrictDelimiter := true;
 aList.Clear;
 aList.Add('LBA;NOMBRE;OFFSET');

  while aOffset <= aISOFile.Size do
   begin
   aISOFile.Position := aOffset;
   aISOFile.Read(aLBAData, SizeOf(aLBAData)); // Leemos el dato LBA
   aISOFile.Position := aOffset + jumpVAGp; // Saltamos a la posición del VAG
   //aISOFile.Read(aVAGp,SizeOf(aVAGp)); // Leemos el dato.
   aISOFile.Read(aTempData[1], length(aTempData));
   aVAGTemp := copy(aTempData,1,4);

   if aVAGTemp = 'VAGp' then
   begin

   //aTempOffset := aISOFile.Position;

   aVAGName := Copy(aTempData,32,11);


//   aISOFile.Position := aISOFile.Position + 32; //Vamos al nombre de VAG
//   aISOFile.Read(aVAGName[1],Length(aVAGName));

//   aISOFile.Position := aISOFile.Position - 32;

   aLine := IntToHex(aLBAData[0],2) + IntToHex(aLBAData[1],2) + // LBA DATA
            IntToHex(aLBAData[2],2) + IntToHex(aLBAData[3],2) + ';' +
            TRIM(aVAGName) + ';' + IntToStr(aISOFile.Position - 36);
   aList.Add(aLine);
   aISOFile.Position := aISOFile.Position - SizeOf(aLBAData)- aOffset -Length(aTempData) - jumpVAGp;
   end;

   aISOFile.Position := aISOFile.Position + jumpSize; // Saltamos 2352 posiciones
   aOffset := aISOFile.Position;
   //aVAGp := '';
   end;


 finally
   aISOFile.Free;
 end;
 end;



 Function FindRA(aFile: String): TStringList;
CONST
  mNumber: UTF8String = '.RA;';
var
  aFileToRead: TFileStream;
  // Archivoaleer
  Buffer: UTF8String; // Buffer donde guardo los datos a leer
  Lista: TStringList; // Listas con los datos
  nomArchivo: UTF8String; // Nombre del archivo VAG
  posArchivo, tamArchivo: Integer;
  Encontrado, ID, Offset: Integer;
  // Contadores y registros varios
begin

  aFileToRead := TFileStream.Create(aFile, FmOpenRead OR FmShareDenyNone);
  // Abrimos el archivo
  aFileToRead.Position := 0;
  Lista := TStringList.Create; // Resultado
  Lista.Clear; // Limpio la lista
  SetLength(nomArchivo, 11);
  // Asigno el largo del nombre con todo y su extensión (VAG)
  ID := 0; // regitro de archivos
  Offset := 0; // Posiciono el Offset a 0
  Encontrado := -1; // POS(cadena,Buffer);
  // seteamos a 0 la posición para empezar a leer el archivo.
  while Encontrado <> 0 do
  begin
    Encontrado := BuscaStringsEnFichero(aFile, mNumber, Offset);
    // Buscamos el VAG. OFFSET si existe -1 Si no.
    if Encontrado = -1 then // Si no encuentra más VAGS, sale.
      break;
    Offset := Encontrado - 8;
    aFileToRead.Position := Offset;
    aFileToRead.Read(nomArchivo[1], Length(nomArchivo));

    Lista.Add(nomArchivo); // .Insert(ID,Trim(nomArchivo));
    ID := ID + 1;
    Offset := Offset + 15;
  end;
  Result := Lista;
end;


function FindLBAStart(aFile : string) : TStringlist;
CONST dataBlockSize = 2048;
var
headerData : Byte; // OFSET of the LBA
Arch : TFileStream; // Abrimos el archivo para lectura.
Posicion : Integer; // Contador de posiciones de VAGs
Encontrado, ID, Offset : Integer;
dataToFind, ra00LBABlock, aFileName: UTF8String;
aLBAData,aFileSizeData : Dword;
I: Integer;
aStart : Byte;
lst : TStringList;
endFile : Boolean;
begin
i := 0;
endFile := False;
Arch :=  TFileStream.Create(aFile,FmOpenRead OR fmShareDenyNone);
ID := 0;
Arch.Position :=0;
Offset := Arch.position;
lst := TStringList.Create;
SetLength(aFileName,11);
//SetLength(ra00LBABlock, dataBlockSize);
Encontrado:= -1;//POS(cadena,Buffer);
lst.Add('TAMAÑO DEL HEADER (HEX), TAMAÑO DEL HEADER (DECIMAL),OFFSET DEL LBA(HEXA),' +
'OFFSET DEL LBA(DECIMAL),TAMAÑO DEL ARCHIVO(HEXA), TAMAÑO DEL ARCHIVO(DECIMAL), NOMBRE DEL ARCHIVO,' +
'OFFSET DEL HEADER (HEXA),OFFSET DEL HEADER (DECIMAL)');
//vagSize := 0;
dataToFind := 'pBAV';
//SetLength(abufferData,4);

          // Vamos deducir si estamos en el RA00 o en algún otro RA
          // RA 00 encontrará la palabra pBAV al primcipio del archivo
          // Si la encontramos, sabemos que es ese RA y debemos buscar
          // los bloques de LBA HEDER, si no la encuentra los LBA HEADER
          // estarán uno debajo del otro desde el offset 0 en el archivo.

           Encontrado := BuscaStringEnFichero(aFile,dataToFind);


          // Si encontamos algo nos va a devolver el offset en donde
          // estaría lo encontrado. Si no quiere decir que estamos en
          // un RA diferente al 00
         if Encontrado <> -1 then
         begin

           //Vamos a buscar LBAs
           repeat

            // Acá buscaremos el primer headerdata del archivo.
            offset := BuscaStringsEnFichero(aFile,'VAG;', i);
            Arch.Position := Offset - 160;
            ID := Arch.Position;
            Arch.Read(headerData, SizeOf(headerData));

            while headerData = 0 do
            begin
              Arch.Position := ID;
              Arch.Read(headerData,SizeOf(headerData));
              Inc(ID);
            end;
            // Una vez encontrado, deberemos recorrer al archivo en su totalidad
            // buscando todos los HEADERS LBA
            i := (ID - 1) + 96;
            Arch.Position := i;
           // Encontramos el primer LBA.
            Arch.Read(aStart, 1);
            //i := Arch.Position;

            repeat
            Arch.Position := i + 2;
            Arch.Read(aLBAData, 4);
            Arch.Position := i + 6;
            Arch.Read(aFileSizeData,4);
            Arch.Position := i + 33;
            Arch.Read(aFileName[1], Length(aFileName));
            aFileName := AnsiReplaceText(aFileName,';','');

            lst.Add(IntToHex(aStart,4 )+ ',' + IntToStr(aStart) + ',' + IntToHex(aLBAData,4) + ',' +  IntToStr(aLBAData) +
             ',' + IntToHex(aFileSizeData,4) + ',' + IntToStr(aFileSizeData) + ',' + aFileName + ',' + IntToHex(i,8) + ',' + IntToStr(i) );

            i := i + (aStart); // Corremos el índice de I al siguiente header
            Arch.Position := i;
            Arch.Read(aStart,1);

            if aStart = 0 then
            begin
            endFile := true;
            inc(i);
            end;

            //endFile := True;

            until (endFile = true);
            endFile := False;

           until (offset = -1);


            //lst.Add(IntToStr(headerData));
         end else
         begin
         i := 0;

         Arch.Position := i;
           // Encontramos el primer LBA.
            Arch.Read(aStart, 1);
            //i := Arch.Position;

            repeat
            Arch.Position := i + 2;
            Arch.Read(aLBAData, 4);
            Arch.Position := i + 6;
            Arch.Read(aFileSizeData,4);
            Arch.Position := i + 33;
            Arch.Read(aFileName[1], Length(aFileName));
           // lst.Add(IntToStr(aStart ) + ',' + IntToHex(aLBAData,4) +
           //  '(HEXA),' + IntToHex(aFileSizeData,4) + '(HEXA),' + aFileName + ',' + IntToHex(i,8) + '(HEXA)');
            lst.Add(IntToHex(aStart,4 )+ ',' + IntToStr(aStart) + ',' + IntToHex(aLBAData,4) + ',' +  IntToStr(aLBAData) +
             ',' + IntToHex(aFileSizeData,4) + ',' + IntToStr(aFileSizeData) + ',' + aFileName + ',' + IntToHex(i,8) + ',' + IntToStr(i) );

            i := i + (aStart); // Corremos el índice de I al siguiente header
            Arch.Position := i;
            Arch.Read(aStart,1);

                    if aStart = 0 then
                    begin
                    i := BuscaStringsEnFichero(aFile,'VAG;1',i);

                    if i <> -1 then
                    begin
                    i := i - 45;
                    Arch.Position := i;
                    Arch.Read(headerData, SizeOf(headerData));
                    ID := Arch.Position;

                    while headerData = 0 do
                    begin
                      Arch.Position := ID;
                      Arch.Read(headerData,SizeOf(headerData));
                      Inc(ID);
                    end;

                    i := ID - 1;
                    end else
                        begin
                          endFile := true;
                        end;

                    end;

//              if i >= Arch.Size / 2 then endFile := true;

            //endFile := True;

            until (endFile = true);
           // endFile := False;

         end;

         Result := lst;
         arch.Free;


end;


function ReadRAFile(fileRA, fileISO : String) : TStringList;
CONST BLOCK_ONE = 8192;
CONST BLOCK_TWO = 8192;
CONST BLOCK_THREE = 32176;
CONST BLOCK_FOUR = 3824;
CONST LBASpeak = 20000;
CONST LBACalls = 50000;
CONST OFFSETBLOCK_ONE = 4640;
CONST OFFSETBLOCK_TWO = 14336;
CONST OFFSETBLOCK_THREE = 270336;
CONST OFFSETBLOCK_FOUR = 303104;
var
pointerOffset,loopCount,offsetOfVAG, offsetOnRA, LBACount, blockCount, nextPos : integer;
aRAHeader : array [0..3] of byte;
aISO, aRA : TFileStream;
aList : TStringList;
endOfBLock : Boolean;
vagName : UTF8String;
offsetOnISO : Integer;
begin
endOfBLock := False;
loopCount := 0;
blockCount := 0;
aRa := TFileStream.Create(fileRA,fmOpenRead);
aISO := TFileStream.Create(fileISO, fmOpenRead);
aList := TStringList.Create;
aList.StrictDelimiter := true;
aList.DelimitedText := ';';
aList.Clear;
SetLength(vagName, 11);
try

case blockCount of
0:
begin
aRA.Position := OFFSETBLOCK_ONE;
while endOfBlock = False do
begin
aRA.Read(aRAHeader,sizeOf(aRAHeader));
pointerOffset := HexToInt( IntToHex(aRAHeader[1],1) + IntToHex(aRAHeader[0],1));
offsetOnISO := ((pointerOffset + 20000) * 2352) + 24;
LBACount := aRAHeader[2];
aISO.Position := offsetOnISO;
aISO.Read(vagName,Length(vagName));
nextPos := aRA.Position + 4;
//pointerOffset := '';
end;

end;

1:
begin

end;
2:
begin

end;

3:
begin

end;

end;

finally
  aRa.Free;
  aISO.Free;
end;




end;


end.

