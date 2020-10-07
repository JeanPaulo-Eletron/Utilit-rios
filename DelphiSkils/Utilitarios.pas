unit Utilitarios;

interface

uses Windows, SysUtils, Generics.Collections,  Classes, JvADOQuery, JvBaseDBThreadedDataset, Data.DB, Vcl.StdCtrls,
     Data.Win.ADODB, Graphics, Vcl.Forms, Dialogs;

Type
  TCallBack = reference to procedure;
  //Objeto que carregara a procedure Callback que ser� chamada no AfterThreadExecution.
  TObjCallBack     = Class(TObject)
    Callback : TCallBack;
    //Uso interno, serve para ele chamar o callback que eu configurei ao criar esse objeto para ser chamada no AfterThreadExecution.
    procedure CallBackSQLAssync(DataSet: TDataSet;Operation: TJvThreadedDatasetOperation);
  End;

  //Alguns tipos para uso interno
  TQrys    = Array of TADOQuery;
  TButtons = Array of TButton;
  TProcedure  = Procedure of object;

  //Esse � o objeto timer super simplificado.
  TTimeOut  = Class(TObject)
    Callback : TProc;
    RestInterval : Integer;
    LoopTimer: Boolean;
    IDEvent : Integer;
    Tag     : Integer;
    FreeOnTerminate: Boolean;
    PEnabled : Boolean;
    procedure SetEnabled(Enabled: Boolean);
    property Enabled: Boolean read PEnabled write SetEnabled;
  End;

  // Aten��o, coloque uma variavel no form main para contar o numero de consultas ativas, no before destroy do form main
  // coloque um while pare ele esperar terminar as consultas(evita o erro de consultas assyncronas).

  //Use essa aqui caso queira um uso r�pido dessa fun��o no atualiza banco de dados
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection):String;overload;

  //Use essa aqui caso queira um uso r�pido dessa fun��o no atualiza banco de dados ( e a Qry do form main seja impactada )
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Qry : TAdoQuery):String;overload;

  //Use essa aqui caso queira um uso r�pido dessa fun��o
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Button : TButton; Qry : TAdoQuery):String;overload;

  //Use essa aqui caso queira dar o Refresh(close e open) em todas as qrys envolvidas assim que ele teminar de fazer a SP
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Button : TButton; Qrys : TQrys):String;overload;

  //Caso geral, use apenas caso queira desabilitar v�rios bot�es, caso contr�rio, use a function acima.
  Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Buttons : TButtons; Qrys : TQrys):String;overload;

  // Caso queira setar um timer de modo r�pido que se desative sozinho ao ser acionado.
  Function  SetTimeOut (CallBack: TProcedure; RestInterval: Integer; LoopTimer: Boolean = False; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
  Function  SetTimeOut (CallBack: TProc; RestInterval: Integer; LoopTimer: Boolean = False; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;

  // Caso queira setar um timer de modo r�pido que se desative quando a pessoa setar o TTimeOut de retorno com a propriedade ".LoopTimer := False"
  Function  SetInterval(CallBack: TProcedure; RestInterval: Integer; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
  Function  SetInterval(CallBack: TProc; RestInterval: Integer; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;

  // Uso interno, localiza a posi��o do timer na lista de timers pelo seu IDEVENT.
  Function  Localizar(idEvent:UINT):Integer;

  //Serve para alertar quando o usu�rio apertou determinada tecla;
  function TeclaEstaPressionada(const Key: integer): boolean;

  Function GetPrintScreen() : TBitmap;

  //Fun��es de controle de mouse e teclado
  procedure PressionarTeclaShiftEManter;
  procedure SoltarTeclaShift;
  procedure ClicarESegurar(X, Y: Integer);
  procedure PressionarControlEManter;
  procedure PressionarTeclaC;
  procedure PressionarTeclaV;
  procedure SoltarClick(X, Y: Integer);
  procedure SoltarControl;
  procedure MoverScroll(X: INTEGER);
  procedure PressionarTeclaEnd;
  procedure PressionarTeclaHome;
  procedure MoverMouse(X, Y: Integer);
  procedure MoverMouseSuavemente(X, Y, Velocidade, Ruido: Integer; CallBack: TCallBack);

  procedure EscreverLivrementeNaTela(Texto: String; Y: Integer);
  procedure ConfigurarConexao(Alias: TAdoConnection);

//--//--//--//--//--//--//--//--//--//--/EM DESENVOLVIMENTO/--//--//--//--//--//--//--//--//--//--//--//--//

  procedure DesenharSeta(OCor: TColor; OLargura: Integer; Origem, Destino: TPoint);

//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

var
  TimeOut  : TList<TTimeOut>;
  QtdeTimers : Integer;
implementation

Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection):String;overload;
//Use essa aqui caso queira um uso r�pido dessa fun��o no atualiza banco de dados
var Buttons : TButtons;
    Qrys    : TQrys;
begin
  SetLength(Buttons, 0);
  SetLength(Qrys, 0);
  ExecutaSQLAssync(SQLText, Connection, Buttons, Qrys);
end;

Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Qry : TAdoQuery):String;overload;
//Use essa aqui caso queira um uso r�pido dessa fun��o no atualiza banco de dados ( e a Qry do form main seja impactada )
var Buttons : TButtons;
    Qrys    : TQrys;
begin
  SetLength(Buttons, 0);
  SetLength(Qrys, 1);
  Qrys[0] := Qry;
  ExecutaSQLAssync(SQLText, Connection, Buttons, Qrys);
end;

Function ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Button : TButton; Qry : TAdoQuery):String;overload;
//Use essa aqui caso queira um uso r�pido dessa fun��o
var Buttons : TButtons;
    Qrys    : TQrys;
begin
  SetLength(Buttons, 1);
  SetLength(Qrys, 1);
  Buttons[0] := Button;
  Qrys[0] := Qry;
  ExecutaSQLAssync(SQLText, Connection, Buttons, Qrys);
end;

Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Button : TButton; Qrys : TQrys):String;overload;
//Use essa aqui caso queira dar o Refresh(close e open) em todas as qrys envolvidas assim que ele teminar de fazer a SP
var Buttons : TButtons;
begin
  SetLength(Buttons, 1);
  Buttons[0] := Button;
  ExecutaSQLAssync(SQLText, Connection, Buttons, Qrys);
end;

Function  ExecutaSQLAssync(SQLText : String; Connection: TAdoConnection; Buttons : TButtons; Qrys : TQrys):String; overload;
//Caso geral, use apenas caso queira desabilitar v�rios bot�es, caso contr�rio, use a function acima.
var Button : TButton;
    _Qry : TJvADOQuery;
    Obj : TObjCallBack;
begin
  result := '';
  if SQLText = ''
    then Exit;
  Try
    _Qry := TJvADOQuery.Create(nil);
    Obj  := TObjCallBack.Create;
    Obj.Callback := Procedure
                    begin
                      SetTimeOut(
                        Procedure
                        var Qry    : TAdoQuery;
                            Button : TButton;
                        begin
                          for Qry in Qrys do Qry.Active := False;
                          for Qry in Qrys do Qry.Active := True;  // Abrindo e fechando as qrys passadas por parametro.
                          for Button in Buttons do Button.Enabled := True;
                          _Qry.Free;
                          Obj.Free;
                        end, 1000);
                      _Qry.Close;
                    end;
    _Qry.ThreadOptions.OpenInThread := True;
    _Qry.SQL.Clear;
    _Qry.SQL.Add('select 1 -- Para n�o dar erro');
    _Qry.SQL.Add(SQLText);
    _Qry.Connection := Connection;
    _Qry.AfterThreadExecution := Obj.CallBackSQLAssync;
    _Qry.Open;
    for Button in Buttons do Button.Enabled := False;
  Except
    Result := 'Erro';
  End;

end;

procedure TObjCallBack.CallBackSQLAssync(DataSet: TDataSet;Operation: TJvThreadedDatasetOperation);
begin
  Callback;
end;

// !!!!!!!!!!!  TIMER  !!!!!!!!!!!!!!!!!!! \\

procedure MyTimeout( hwnd: HWND; uMsg: UINT;idEvent: UINT ; dwTime : DWORD);
stdcall;
VAR
  _CallBack : TProc;
  _TimeOut: TTimeOut;
begin
  _TimeOut := TimeOut.List[Localizar(idEvent)];
  _TimeOut.Enabled := False;
  _CallBack := _TimeOut.Callback;
  _CallBack;
  if (_TimeOut.LoopTimer)
    then _TimeOut.Enabled := True
    else begin
      _TimeOut.Enabled := False;
      if (_TimeOut.FreeOnTerminate) then begin
        TimeOut.Remove(_TimeOut);
        _TimeOut.Free;
        _TimeOut := Nil;
      end;
    end;
end;

Function SetTimeOut(CallBack: TProc; RestInterval: Integer; LoopTimer: Boolean = False; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
var Timer : TTimeOut;
begin
  if TimeOut = nil
    then TimeOut := TList<TTimeOut>.Create;
  QtdeTimers := QtdeTimers + 1;
  Timer  := TTimeOut.Create;
  Timer.Callback        := CallBack;
  Timer.RestInterval    := RestInterval;
  Timer.LoopTimer       := LoopTimer;
  Timer.Tag             := 0;
  Timer.FreeOnTerminate := FreeOnTerminate;
  Timer.Enabled := True;
  TimeOut.Add(Timer);
  Result := Timer;
end;

function SetTimeOut(CallBack: TProcedure; RestInterval: Integer; LoopTimer: Boolean = False; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;
begin
  Result := SetTimeOut(procedure begin Callback end, RestInterval, LoopTimer, FreeOnTerminate, Assync);
end;

Function SetInterval(CallBack: TProcedure; RestInterval: Integer; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
begin
  Result := SetInterval(procedure begin CallBack end,RestInterval, FreeOnTerminate, Assync);
end;

Function SetInterval(CallBack: TProc; RestInterval: Integer; FreeOnTerminate: Boolean = True; Assync: Boolean = False):TTimeOut;overload;
begin
  Result := SetTimeOut(CallBack, RestInterval, True, FreeOnTerminate, Assync);
end;

Function Localizar(idEvent:UINT):Integer;
var I : Integer;
begin
  for I := 0 to TimeOut.Count - 1 do
    if TimeOut.List[I].IDEvent = idEvent then break;
  Result := I;
end;

function TeclaEstaPressionada(const Key: integer): boolean;
begin
  Result := GetKeyState(Key) and 128 > 0;
end;

function GetPrintScreen() : TBitmap;
var
  vHDC : HDC;
  vCanvas : TCanvas;
begin
  Result := TBitmap.Create;
  Result.Width := Screen.Width;
  Result.Height := Screen.Height;

  vHDC := GetDC(0);
  vCanvas := TCanvas.Create;
  vCanvas.Handle := vHDC;

  Result.Canvas.CopyRect(
  Rect(0, 0, Result.Width, Result.Height), vCanvas,
  Rect(0, 0, Result.Width, Result.Height));

  vCanvas.Free;
  ReleaseDC(0, vHDC);
end;

//--//--//--//--//--//--//--//--//--//--/EM DESENVOLVIMENTO/--//--//--//--//--//--//--//--//--//--//--//--//

{Desenha a Seta!}
procedure DesenharSeta(OCor: TColor; OLargura: Integer; Origem, Destino: TPoint);
const
ANGULO = 15;
PONTA  = 20;
var
Canvas : TCanvas;
  vHDC : HDC;
AlphaRota, Alpha, Beta       : Extended;
vertice1, vertice2, vertice3 : TPoint;
begin
vHDC := GetDC(0);
Canvas := TCanvas.Create;
Canvas.Handle := vHDC;
Canvas.Pen.Color   := OCor;
Canvas.Brush.Color := OCor;
if (Destino.X >= Origem.X) then
  begin
  if (Destino.Y >= Origem.Y) then
    begin
    AlphaRota := Destino.X - Origem.X;
    if (AlphaRota <> 0)
      then Alpha := ArcTan((Destino.Y - Origem.Y) / AlphaRota)
      else Alpha := ArcTan(Destino.Y - Origem.Y);
    Beta := (ANGULO * (PI / 180)) / 2;
    vertice1.X := Destino.X - Round(Cos(Alpha + Beta));
    vertice1.Y := Destino.Y - Round(Sin(Alpha - Beta));
    vertice2.X := Round(vertice1.X - PONTA * Cos(Alpha + Beta));
    vertice2.Y := Round(vertice1.Y - PONTA * Sin(Alpha + Beta));
    vertice3.X := Round(vertice1.X - PONTA * Cos(Alpha - Beta));
    vertice3.Y := Round(vertice1.Y - PONTA * Sin(Alpha - Beta));
    Canvas.Polygon([vertice1,vertice2,vertice3]);
    end
  else
    begin
    AlphaRota := Destino.Y - Origem.Y;
    if (AlphaRota <> 0)
      then Alpha := ArcTan((Destino.X - Origem.X) / AlphaRota)
      else Alpha := ArcTan(Destino.X - Origem.X);
    Beta := (ANGULO * (PI / 180)) / 2;
    vertice1.X := Destino.X - Round(Cos(Alpha + Beta));
    vertice1.Y := Destino.Y - Round(Sin(Alpha - Beta));
    vertice2.X := Round(vertice1.X + PONTA * Sin(Alpha + Beta));
    vertice2.Y := Round(vertice1.Y + PONTA * Cos(Alpha + Beta));
    vertice3.X := Round(vertice1.X + PONTA * Sin(Alpha - Beta));
    vertice3.Y := Round(vertice1.Y + PONTA * Cos(Alpha - Beta));
    Canvas.Polygon([vertice1,vertice2,vertice3]);
    end;
  end
else
  begin
  Alpha := ArcTan((Destino.Y - Origem.Y) / (Destino.X - Origem.X));
  Beta := (ANGULO * (PI / 180)) / 2;
  vertice1.X := Destino.X - Round(Cos(Alpha + Beta));
  vertice1.Y := Destino.Y - Round(Sin(Alpha - Beta));
  vertice2.X := Round(vertice1.X + PONTA * Cos(Alpha + Beta));
  vertice2.Y := Round(vertice1.Y + PONTA * Sin(Alpha + Beta));
  vertice3.X := Round(vertice1.X + PONTA * Cos(Alpha - Beta));
  vertice3.Y := Round(vertice1.Y + PONTA * Sin(Alpha - Beta));
  Canvas.Polygon([vertice1,vertice2,vertice3]);
  end;
end;

procedure TTimeOut.SetEnabled(Enabled: Boolean);
begin
  if (Enabled) and (not (PEnabled))
    then begin
      PEnabled := True;
      IDEvent := SetTimer(0, QtdeTimers, RestInterval, @MyTimeOut)
    end
    else begin
      KillTimer(0,IDEvent);
      PEnabled := False;
    end;
end;

procedure PressionarTeclaShiftEManter;
begin
  Keybd_event(VK_SHIFT, 0, KEYEVENTF_EXTENDEDKEY or 0, 0);
end;

procedure SoltarTeclaShift;
begin
  Keybd_event(VK_SHIFT, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
end;

procedure ClicarESegurar(X, Y: Integer);
BEGIN
  Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, X, Y, 0, 0);
END;

procedure SoltarClick(X, Y: Integer);
BEGIN
  Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, X, Y, 0, 0);
END;

procedure PressionarControlEManter;
begin
  keybd_event(VK_CONTROL,0, KEYEVENTF_EXTENDEDKEY or 0,0);
end;

Procedure SoltarControl;
begin
  keybd_event(VK_CONTROL,$45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
end;

procedure PressionarTeclaC;
begin
  keybd_event($43,0,0,0);
end;

procedure PressionarTeclaV;
begin
  keybd_event($56,0,0,0);
end;

procedure PressionarTeclaEnd;
begin
  keybd_event(VK_END,   0, KEYEVENTF_EXTENDEDKEY or 0, 0);
  Keybd_event(VK_END, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
end;

procedure PressionarTeclaHome;
begin
  keybd_event(VK_HOME,0,0,0);
end;

procedure MoverScroll(X: INTEGER);
begin
  mouse_event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(ROUND(X)), 0);
end;

procedure MoverMouse(X, Y: Integer);
BEGIN
  Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, X, Y, 0, 0);
END;

procedure EscreverLivrementeNaTela(Texto: String; Y: Integer);
var
  Canvas : TCanvas;
  vHDC : HDC;
  pt: TPoint;
BEGIN
  vHDC := GetDC(0);
  Canvas := TCanvas.Create;
  Canvas.Handle      := vHDC;
  Canvas.Pen.Color   := ClRed;
  Canvas.Brush.Color := ClRed;

  GetCursorPos(pt);


  Canvas.Rectangle(Pt.x,Pt.y,Pt.x + Length(Texto) * 5, Pt.y + Y);
  Canvas.TextOut(Pt.x,Pt.y-10+Y,Texto);
END;

procedure ConfigurarConexao(Alias: TAdoConnection);
var TxtFile : TextFile;
    Txt, LicencaServidor, LicencaDataBase, LicencaSenha, LicencaUsuario, ExePath, CaminhoENomeArquivo : String;
begin
  ExePath := ExtractFilePath(Application.ExeName);
  {$Region 'Se o arquivo "Config.ini" n�o existir, ent�o crie um com as configura��es padr�o'}
    if not FileExists(ExePath+'Config.ini') then begin
        CaminhoENomeArquivo := ExePath + 'Config.ini';
        FileSetAttr(CaminhoENomeArquivo, 0);
        AssignFile(TxtFile, CaminhoENomeArquivo);
        Rewrite(TxtFile);
        Writeln(TxtFile,'Servidor        : LAPTOP-GK2QJ6O0');
        Writeln(TxtFile,'Usu�rio         : sa');
        Writeln(TxtFile,'Senha           : senhatst');
        Writeln(TxtFile,'LicencaDataBase : AmigosFacebook');
        Writeln(TxtFile,'O Sistema s� ir� considerar as 4 primeiras linhas e somente o que estiver ap�s o ":",');
        Writeln(TxtFile,'ele n�o ira considerar espa�os adicionais a direita e esquerda.');
        CloseFile(TxtFile);
  //    FileSetAttr(CaminhoENomeArquivo, FileGetAttr(CaminhoENomeArquivo) or faHidden); Descomente caso queira que o .ini fique oculto
    end;
  {$EndRegion}
  Try
    Alias.Connected   := False;
    Alias.LoginPrompt := False;
    AssignFile(TxtFile, ExePath+'Config.ini');
    Reset(TxtFile);
    ReadLn(TxtFile, Txt);
    LicencaServidor := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt) ));
    ReadLn(TxtFile, Txt);
    LicencaUsuario  := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    ReadLn(TxtFile, Txt);
    LicencaSenha    := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    ReadLn(TxtFile, Txt);
    LicencaDataBase := TRIM(Copy(Txt,POS(':',Txt)+1,Length(Txt)));
    Alias.ConnectionString := 'Provider=SQLOLEDB.1;'+
                              'Password='+LicencaSenha+';'+
                              'Persist Security Info=True;'+
                              'User ID='+LicencaUsuario+';'+
                              'Initial Catalog='+LicencaDataBase+';'+
                              'Data Source='+LicencaServidor+';'+
                              'Use Procedure for Prepare=1;'+
                              'Auto Translate=True;'+
                              'Packet Size=4096;'+
                              'Workstation ID=anonimo;'+
                              'Use Encryption for Data=False;'+
                              'Tag with column collation when possible=False';
    Alias.Connected        := True;
  Except
    ShowMessage('N�o foi poss�vel conectar ao servidor ! Verifique o arquivo de licen�a ! ');
    Abort;
  end;
end;

procedure MoverMouseSuavemente(X, Y, Velocidade, Ruido: Integer; CallBack: TCallBack);
var Xp, Yp, RuidoX, RuidoY: Integer;
    pt: TPoint;
    TimerMoverMouse: TTimeOut;
begin
  GetCursorPos(pt);

  Pt.x := Round(Pt.x * (65535 / Screen.Width));
  Pt.y := Round(Pt.y * (65535 / Screen.Height));

  if pt.X < X
    then RuidoX := Ruido * 1000
    else RuidoX := - Ruido * 1000;

  if Pt.Y < Y
    then RuidoY := Ruido * 1000
    else RuidoY := - Ruido * 1000;

  Xp               := pt.X + RuidoX;
  Yp               := pt.Y + RuidoY;

  TimerMoverMouse :=
  SetInterval(
    Procedure
    begin
      TimerMoverMouse.Enabled := False;

      MoverMouse(Xp, Yp);
      RuidoX := RuidoX;
      RuidoY := RuidoY;

      if ((Xp < X) and (RuidoX > 0)) or ((Xp > X) and (RuidoX < 0))
        then begin
          Xp := Xp + RuidoX //+ Round(random(1)-random(1));
  //        Yp := Yp + Round(random(2)*((random(2)-1)));
        end
        else Xp := X;

      if ((Yp < Y) and (RuidoY > 0)) or ((Yp > Y) and (RuidoY < 0))
        then begin
          Yp := Yp + RuidoY //+ Round(random(1)-random(1));
  //        Xp := Xp + Round(random(2)*((random(2)-1)));
        end else Yp := Y;
      TimerMoverMouse.Enabled := True;
      if (not (((Xp < X) and (RuidoX > 0)) or ((Xp > X) and (RuidoX < 0)))) and
         (not (((Yp < Y) and (RuidoY > 0)) or ((Yp > Y) and (RuidoY < 0))))
        then begin
          MoverMouse(X, Y);
          TimerMoverMouse.Callback :=
          procedure
          begin
            TimerMoverMouse.Enabled := False;
            CallBack;
          end;
        end;
    End,
  Velocidade);
end;

end.