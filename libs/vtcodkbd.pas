unit vtcodkbd;

{$MODE OBJFPC}

interface

procedure SetTCODKeyboardDriver;

implementation

uses keyboard, vtcod;

var
  KeyRecordIsQueued: boolean = false;
  QueuedKeyRecord: TKeyRecord;

procedure TCODKbdInitDriver;
begin
  TCOD_console_set_keyboard_repeat(300, 30);
end;

{ Convert a TCOD event to a Pascal key record.  Returns true for recognized keys. }
function TCODEventToKeyRecord(tkt: TCOD_key_t; out tkr: TKeyRecord) : boolean;
begin
  { For now, ignore key release events. }
  if tkt.pressed then begin
    if tkt.c <> #0 then begin
      tkr.Flags := kbASCII;
      tkr.KeyCode := word(tkt.c);
      Result := true;
    end else begin
      { translate the keys that matter }
      tkr.Flags := kbFnKey;
      Result := true;
      case tkt.vk of
      TCODK_UP: tkr.KeyCode := kbdUp;
      TCODK_DOWN: tkr.KeyCode := kbdDown;
      TCODK_LEFT: tkr.KeyCode := kbdLeft;
      TCODK_RIGHT: tkr.KeyCode := kbdRight;
      TCODK_HOME: tkr.KeyCode := kbdHome;
      TCODK_END: tkr.KeyCode := kbdEnd;
      TCODK_PAGEUP: tkr.KeyCode := kbdPgUp;
      TCODK_PAGEDOWN: tkr.KeyCode := kbdPgDn;
      TCODK_F1: tkr.KeyCode := kbdF1;
      TCODK_F2: tkr.KeyCode := kbdF2;
      TCODK_F3: tkr.KeyCode := kbdF3;
      TCODK_F4: tkr.KeyCode := kbdF4;
      TCODK_F5: tkr.KeyCode := kbdF5;
      TCODK_F6: tkr.KeyCode := kbdF6;
      TCODK_F7: tkr.KeyCode := kbdF7;
      TCODK_F8: tkr.KeyCode := kbdF8;
      TCODK_F9: tkr.KeyCode := kbdF9;
      TCODK_F10: tkr.KeyCode := kbdF10;
      TCODK_F11: tkr.KeyCode := kbdF11;
      TCODK_F12: tkr.KeyCode := kbdF12;
      else Result := false
      end;
    end;

    tkr.ShiftState := 0;
    if tkt.shift then tkr.ShiftState := tkr.ShiftState + kbShift;
    if tkt.lctrl or tkt.rctrl then tkr.ShiftState := tkr.ShiftState + kbCtrl;
    if tkt.lalt or tkt.ralt then tkr.ShiftState := tkr.ShiftState + kbAlt;
  end else begin
    Result := false
  end;
end;

function TCODKbdGetKeyEvent: TKeyEvent;
var
  tkt: TCOD_key_t;
  tkr: TKeyRecord;
  found: boolean;
begin
  if KeyRecordIsQueued then begin
    KeyRecordIsQueued := false;
    Result := TKeyEvent(QueuedKeyRecord);
  end else begin
    found := false;
    while not found do begin
      tkt := TCOD_console_wait_for_keypress(false);
      found := TCODEventToKeyRecord(tkt, tkr);
    end;
    Result := TKeyEvent(tkr);
  end;
end;

function TCODKbdPollKeyEvent: TKeyEvent;
var
  tkt: TCOD_key_t;
  tkr: TKeyRecord;
  found: boolean;
begin
  if KeyRecordIsQueued then begin
    Result := TKeyEvent(QueuedKeyRecord);
  end else begin
    tkt := TCOD_console_check_for_keypress(TCOD_KEY_PRESSED);
    if TCODEventToKeyRecord(tkt, tkr) then begin
      KeyRecordIsQueued := true;
      QueuedKeyRecord := tkr;
      Result := TKeyEvent(QueuedKeyRecord);
    end else begin
      Result := 0;
    end;
  end;
end;

function TCODKbdGetShiftState: Byte;
begin
  Result := 0;
  if TCOD_console_is_key_pressed(TCODK_SHIFT) then Result := Result + kbShift;
  if TCOD_console_is_key_pressed(TCODK_CONTROL) then Result := Result + kbCtrl;
  if TCOD_console_is_key_pressed(TCODK_ALT) then Result := Result + kbAlt;
end;

function TCODKbdTranslateKeyEvent(tke: TKeyEvent): TKeyEvent;
begin
  TCODKbdTranslateKeyEvent := tke;
end;

const
  TCODKeyboardDriver: TKeyboardDriver = (
    InitDriver: @TCODKbdInitDriver;
    DoneDriver: nil;

    GetKeyEvent: @TCODKbdGetKeyEvent;
    PollKeyEvent: @TCODKbdPollKeyEvent;
    GetShiftState: @TCODKbdGetShiftState;

    TranslateKeyEvent: @TCODKbdTranslateKeyEvent;
    TranslateKeyEventUniCode: @TCODKbdTranslateKeyEvent;
  );

procedure SetTCODKeyboardDriver;
begin
  SetKeyboardDriver(TCODKeyboardDriver);
end;

end.
