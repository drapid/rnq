(*
{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}
*)

{$IFNDEF FPC}

  {$if CompilerVersion >= 21} // By Rapid D
    { $IFDEF NO_EXTENDED_RTTI}
      {$WEAKLINKRTTI ON}
      {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
    { $ENDIF}
  {$ifend}

{$ENDIF}

