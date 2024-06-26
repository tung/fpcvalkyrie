{$INCLUDE valkyrie.inc}
unit vtigio;
interface

uses viotypes, vioeventstate, viomousestate, vioconsole;

type TTIGColor         = TIOColor;
     TTIGRect          = TIORect;
     TTIGPoint         = TIOPoint;

type TTIGCursorType      = (
  VTIG_CTNONE, VTIG_CTINPUT
);

type TTIGDrawCommandType = (
  VTIG_CMD_TEXT,
  VTIG_CMD_CLEAR,
  VTIG_CMD_FRAME,
  VTIG_CMD_RULER,
  VTIG_CMD_BAR
);

type TTIGSoundEvent = (
  VTIG_SOUND_CHANGE,
  VTIG_SOUND_ACCEPT
);

type TTIGInputEvent = (
  VTIG_IE_UNUSED    = 128,
  VTIG_IE_UP        = 129,
  VTIG_IE_DOWN      = 130,
  VTIG_IE_LEFT      = 131,
  VTIG_IE_RIGHT     = 132,
  VTIG_IE_HOME      = 133,
  VTIG_IE_END       = 134,
  VTIG_IE_PGUP      = 135,
  VTIG_IE_PGDOWN    = 136,
  VTIG_IE_CANCEL    = 137, // ESCAPE
  VTIG_IE_SELECT    = 138, // SPACE
  VTIG_IE_CONFIRM   = 139, // ENTER
  VTIG_IE_BACKSPACE = 140,
  VTIG_IE_MCONFIRM  = 141 // MOUSE LEFT
);

type TTIGCursorInfo = record
    CType    : TTIGCursorType;
    Position : TTIGPoint;
  end;


type TTIGDrawCommand = record
    CType : TTIGDrawCommandType;
    Clip  : TTIGRect;
    Area  : TTIGRect;
    Text  : TTIGPoint;
    FG    : TTIGColor;
    BG    : TTIGColor;
    XC    : TTIGColor;
  end;

type TTIGDrawList = class
     FCommands : array of TTIGDrawCommand;
     FCmdCount : Integer;
     FText     : array of Char;
  end;

type TTIGDrawData = class
     FLists     : array of TTIGDrawList;
     FListCount : Integer;
     FCursor    : TTIGCursorInfo;
  end;

type TTIGSoundCallback = procedure( aEvent : TTIGSoundEvent; aParam : Pointer );

type TTIGIOState = class
  public
    constructor Create;
    procedure Initialize( aRenderer : TIOConsoleRenderer; aDriver : TIODriver; aClearOnRender : Boolean = True );
    procedure Clear;
    procedure Render( aData : TTIGDrawData );
    procedure Update;
    procedure EndFrame;
    procedure PlaySound( aEvent : TTIGSoundEvent );
    destructor Destroy; override;
  private
    FEventState     : TIOEventState;
    FMouseState     : TIOMouseState;
    FRenderer       : TIOConsoleRenderer;
    FDriver         : TIODriver;
    FTime           : Single;
    FClearOnRender  : Boolean;
    FMousePosition  : TIOPoint;
    FSoundCallback  : TTIGSoundCallback;
    FSoundParameter : Pointer;
  private
    function GetSize : TIOPoint;
  public
    property SoundParameter : Pointer            write FSoundParameter;
    property SoundCallback  : TTIGSoundCallback  write FSoundCallback;
    property EventState     : TIOEventState      read FEventState;
    property MouseState     : TIOMouseState      read FMouseState;
    property Renderer       : TIOConsoleRenderer read FRenderer;
    property MousePosition  : TIOPoint           read FMousePosition write FMousePosition;
    property Size           : TIOPoint           read GetSize;
    property Driver         : TIODriver          read FDriver;
end;

implementation

uses SysUtils, vutil;

constructor TTIGIOState.Create;
begin
  FEventState := TIOEventState.Create;
  FMouseState := TIOMouseState.Create;
  FRenderer   := nil;
  FDriver     := nil;
  FTime           := 0.0;
  FClearOnRender  := False;
  FMousePosition  := Point( -1, -1 );
  FSoundCallback  := nil;
  FSoundParameter := nil;
end;

procedure TTIGIOState.Initialize( aRenderer : TIOConsoleRenderer; aDriver : TIODriver; aClearOnRender : Boolean = True );
begin
  FRenderer      := aRenderer;
  FDriver        := aDriver;
  FClearOnRender := aClearOnRender;
end;

procedure TTIGIOState.Clear;
begin
  if not Assigned( FRenderer ) then Exit;
  FRenderer.Clear;
  FRenderer.HideCursor;
  FRenderer.Update;
end;

procedure TTIGIOState.Render( aData : TTIGDrawData );
var iL, iC, i : Integer;
    iX, iY    : Integer;
    iList     : TTIGDrawList;
    iCmd      : TTIGDrawCommand;
    iCoord    : TIOPoint;
    iChar     : DWord;
    iBorder   : PChar;
    iGlyph    : Char;
begin
  if not Assigned( FRenderer ) then Exit;
  if FClearOnRender then
    FRenderer.Clear;

  if aData.FCursor.CType <> VTIG_CTNONE then
  begin
    FRenderer.ShowCursor;
    FRenderer.MoveCursor( aData.FCursor.Position.X, aData.FCursor.Position.Y );
  end
  else
    FRenderer.HideCursor;

  if aData.FListCount > 0 then
  for iL := 0 to aData.FListCount - 1 do
  begin
    iList := aData.FLists[iL];
    if iList.FCmdCount > 0 then
    for iC := 0 to iList.FCmdCount - 1 do
    begin
      iCmd := iList.FCommands[iC];
      case iCmd.CType of
        VTIG_CMD_CLEAR: FRenderer.ClearRect( iCmd.Area.x, iCmd.Area.y, iCmd.Area.x2, iCmd.Area.y2, iCmd.BG );
        VTIG_CMD_TEXT:
        begin
          iCoord := iCmd.Area.Pos;
          for i := iCmd.Text.X to iCmd.Text.Y - 1 do
          begin
            iChar := DWord( iList.FText[i] );
            if iChar = Ord(#13) then Continue;
            {
            if Char(iChar) > #$7F then
            begin
              iCode := 0;
              len := uchar32_from_utf8(@iCode, @(iList.FText[i]), @(iList.FText[dlist.TextLength]));
              if len > 0 then
              begin
                if FUTF8.TryGetValue(iCode, iChar) then
                  Inc(i, len - 1)
                else
                begin
                  NV_LOG_ERROR('unknown UTF codepoint - ', code);
                  Continue;
                end;
              end
              else
                iChar := 0;
            end;
            }
            if (iChar = Ord(#10)) or (iCoord.X > iCmd.Clip.X2) then
            begin
              Inc(iCoord.Y);
              if iCoord.Y >= iCmd.Clip.Y2 then Break;
              iCoord.X := iCmd.Area.X;
              if iChar = Ord(#10) then Continue;
            end;
            FRenderer.OutputChar(iCoord.X, iCoord.Y, iCmd.FG, iCmd.BG, Char(iChar));
            Inc(iCoord.X);
          end;
        end;
        VTIG_CMD_RULER:
        begin
          iBorder := PChar(@iList.FText[iCmd.Text.X]);
          iGlyph  := iBorder[0];
          if iCmd.Area.X = iCmd.Area.X2 then iGlyph := iBorder[1];
          for iCoord in iCmd.Area do
            FRenderer.OutputChar( iCoord.x, iCoord.y, iCmd.FG, iCmd.BG, iGlyph );
        end;
        VTIG_CMD_BAR:
        begin
          iBorder := PChar(@iList.FText[iCmd.Text.X]);
          for iCoord in iCmd.Area do
            FRenderer.OutputChar( iCoord.x, iCoord.y, iCmd.XC, iCmd.BG, iBorder[2] );
          FRenderer.OutputChar( iCmd.Area.X,  iCmd.Area.Y,  iCmd.FG, iCmd.BG, iBorder[0] );
          FRenderer.OutputChar( iCmd.Area.X2, iCmd.Area.Y2, iCmd.FG, iCmd.BG, iBorder[1] );
        end;
        VTIG_CMD_FRAME:
        begin
          FRenderer.ClearRect( iCmd.Area.X, iCmd.Area.Y, iCmd.Area.X2, iCmd.Area.Y2, iCmd.BG );
          iBorder := PChar(@iList.FText[iCmd.Text.X]);
          for iX := 0 to iCmd.Area.w - 1 do
          begin
            FRenderer.OutputChar( iCmd.Area.X + iX, iCmd.Area.Y,  iCmd.FG, iCmd.BG, iBorder[0]);
            FRenderer.OutputChar( iCmd.Area.X + iX, iCmd.Area.Y2, iCmd.FG, iCmd.BG, iBorder[1]);
          end;
          for iY := 0 to iCmd.Area.h - 1 do
          begin
            FRenderer.OutputChar( iCmd.Area.X,  iCmd.Area.Y + iY, iCmd.FG, iCmd.BG, iBorder[2]);
            FRenderer.OutputChar( iCmd.Area.X2, iCmd.Area.Y + iY, iCmd.FG, iCmd.BG, iBorder[3]);
          end;
          FRenderer.OutputChar( iCmd.Area.X,  iCmd.Area.Y,  iCmd.FG, iCmd.BG, iBorder[4]);
          FRenderer.OutputChar( iCmd.Area.X2, iCmd.Area.Y,  iCmd.FG, iCmd.BG, iBorder[5]);
          FRenderer.OutputChar( iCmd.Area.X,  iCmd.Area.Y2, iCmd.FG, iCmd.BG, iBorder[6]);
          FRenderer.OutputChar( iCmd.Area.X2, iCmd.Area.Y2, iCmd.FG, iCmd.BG, iBorder[7]);
        end;
      else
        // Handle default case if necessary
      end;
    end;
  end;

  if (FMousePosition.X <> -1) and (FMousePosition.Y <> -1) then
    FRenderer.OutputChar( FMousePosition.X, FMousePosition.Y, White, Chr(30) );

  FRenderer.Update;
end;

procedure TTIGIOState.Update;
var iMSTime : DWord;
    iCTime  : Single;
    iDTime  : Single;
begin
  if not Assigned( FRenderer ) then Exit;
  iMSTime := FDriver.GetMs;
  iCTime  := iMSTime / 1000.0;
  iDTime  := 1.0 / 60.0;
  if FTime > 0 then
    iDTime := iCTime - FTime;
  FTime := iCTime;
  FEventState.update( iDTime );
  FMouseState.update( iDTime );
end;

procedure TTIGIOState.EndFrame;
begin
  FEventState.EndFrame;
  FMouseState.EndFrame;
end;

procedure TTIGIOState.PlaySound( aEvent : TTIGSoundEvent );
begin
  if Assigned( FSoundCallback ) then FSoundCallback( aEvent, FSoundParameter );
end;

destructor TTIGIOState.Destroy;
begin
  FreeAndNil( FEventState );
  FreeAndNil( FMouseState );
  inherited Destroy;
end;

function TTIGIOState.GetSize : TIOPoint;
begin
  if Assigned( FRenderer ) then Exit( FRenderer.GetDeviceArea.Dim );
  Exit( Point(0,0) );
end;


end.

