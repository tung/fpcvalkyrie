unit vtcod;

{$linklib tcod}

interface

{$include vtcodtypes.inc}
{$include vtcodconst.inc}

var
  { standard colors }
  TCOD_red: TCOD_color_t; cvar; external;
  TCOD_yellow: TCOD_color_t; cvar; external;
  TCOD_green: TCOD_color_t; cvar; external;
  TCOD_cyan: TCOD_color_t; cvar; external;
  TCOD_blue: TCOD_color_t; cvar; external;
  TCOD_magenta: TCOD_color_t; cvar; external;

  { darker colors }
  TCOD_dark_red: TCOD_color_t; cvar; external;
  TCOD_dark_yellow: TCOD_color_t; cvar; external;
  TCOD_dark_green: TCOD_color_t; cvar; external;
  TCOD_dark_cyan: TCOD_color_t; cvar; external;
  TCOD_dark_blue: TCOD_color_t; cvar; external;
  TCOD_dark_magenta: TCOD_color_t; cvar; external;

  { grey (with an 'e') levels }
  TCOD_black: TCOD_color_t; cvar; external;
  TCOD_dark_grey: TCOD_color_t; cvar; external;
  TCOD_grey: TCOD_color_t; cvar; external;
  TCOD_white: TCOD_color_t; cvar; external;

{ Console }
procedure TCOD_console_init_root(w, h: integer; title: pchar; fullscreen: boolean; renderer: TCOD_renderer_t); cdecl; external;
function TCOD_console_is_window_closed: boolean; cdecl; external;
function TCOD_console_wait_for_keypress(flushbuf: boolean): TCOD_key_t; cdecl; external;
procedure TCOD_console_set_keyboard_repeat(initial_delay, interval: integer); cdecl; external;
procedure TCOD_console_flush; cdecl; external;
procedure TCOD_console_clear(con: TCOD_console_t); cdecl; external;
procedure TCOD_console_put_char(con: TCOD_console_t; x, y, c: integer; flag: TCOD_bkgnd_flag_t); cdecl; external;
procedure TCOD_console_put_char_ex(con: TCOD_console_t; x, y, c: integer; fore, back: TCOD_color_t); cdecl; external;
procedure TCOD_console_print(con: TCOD_console_t; x, y: integer; fmt: pchar); cdecl; varargs; external;
function TCOD_console_check_for_keypress(flags: integer): TCOD_key_t; cdecl; external;
function TCOD_console_is_key_pressed(key: TCOD_keycode_t): boolean; cdecl; external;
procedure TCOD_console_set_window_title(title: pchar); cdecl; external;

implementation

end.
