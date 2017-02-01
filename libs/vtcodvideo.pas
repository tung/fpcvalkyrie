unit vtcodvideo;

interface

procedure SetTCODVideoDriver;

implementation

uses video, vtcod;

var
  tcolor_from_vidcell: array[0..15] of TCOD_color_t = (
    ( r:   0; g:   0; b:   0 ), { black }
    ( r:   0; g:   0; b: 191 ), { dark blue }
    ( r:  78; g: 154; b:   6 ), { dark green }
    ( r:   6; g: 152; b: 154 ), { dark cyan }
    ( r: 204; g:   0; b:   0 ), { dark red }
    ( r: 117; g:  80; b: 123 ), { dark magenta }
    ( r: 196; g: 160; b:   0 ), { dark yellow }
    ( r: 211; g: 215; b: 207 ), { gray }

    ( r:  85; g:  87; b:  83 ), { dark gray }
    ( r: 114; g: 159; b: 207 ), { blue }
    ( r: 138; g: 226; b:  52 ), { green }
    ( r:  52; g: 226; b: 226 ), { cyan }
    ( r: 239; g:  41; b:  41 ), { red }
    ( r: 173; g: 127; b: 168 ), { magenta }
    ( r: 252; g: 233; b:  79 ), { yellow }
    ( r: 255; g: 255; b: 255 )  { white }
  );
  cursor_type: word = crHidden;

procedure TCODVidInitDriver;
var
  i: integer;
begin
  ScreenWidth := 80;
  ScreenHeight := 25;
  TCOD_console_init_root(ScreenWidth, ScreenHeight, 'Valkyrie TCOD Application', false, TCOD_RENDERER_SDL);
end;

procedure TCODVidUpdateScreen(force: boolean);
var
  i: integer;
  x, y, ch: integer;
  fgc, bgc: TCOD_color_t;
  cursor: boolean;
begin
  for i := 0 to (VideoBufSize div SizeOf(TVideoCell)) - 1 do begin
    x := i mod ScreenWidth;
    y := i div ScreenWidth;
    { Assume little-endian. }
    ch := VideoBuf^[i] and $00FF;
    fgc := tcolor_from_vidcell[(VideoBuf^[i] and $0F00) shr 8];
    bgc := tcolor_from_vidcell[(VideoBuf^[i] and $7000) shr 12];
    { Ignore blink bit. }
    if (cursor_type <> crHidden) and (x = CursorX) and (y = CursorY)
      then TCOD_console_put_char_ex(nil, x, y, ch, bgc, fgc)
      else TCOD_console_put_char_ex(nil, x, y, ch, fgc, bgc);
  end;
  TCOD_console_flush;
end;

procedure TCODVidClearScreen;
begin
  TCOD_console_clear(nil);
end;

procedure TCODVidSetCursorPosition(x, y: word);
begin
  CursorX := x;
  CursorY := y;
end;

function TCODVidGetCursorType: word;
begin
  TCODVidGetCursorType := cursor_type;
end;

procedure TCODVidSetCursorType(ct: word);
begin
  cursor_type := ct;
end;

function TCODVidGetCapabilities: word;
begin
  TCODVidGetCapabilities := cpColor + cpChangeCursor;
end;

const
  TCODVideoDriver: TVideoDriver = (
    InitDriver: @TCODVidInitDriver;
    DoneDriver: nil;
    UpdateScreen: @TCODVidUpdateScreen;
    ClearScreen: @TCODVidClearScreen;
    SetVideoMode: nil;
    GetVideoModeCount: nil;
    GetVideoModeData: nil;
    SetCursorPos: @TCODVidSetCursorPosition;
    GetCursorType: @TCODVidGetCursorType;
    SetCursorType: @TCODVidSetCursorType;
    GetCapabilities: @TCODVidGetCapabilities;
  );

procedure SetTCODVideoDriver;
begin
  SetVideoDriver(TCODVideoDriver);
end;

end.
