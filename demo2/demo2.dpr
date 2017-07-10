{ Console program demo showing use of TProcess

  License: This demo is BSD/MIT
           But dprocess.pas is FPC Modified LGPL (okay for commercial)
}

program demo2;

{$APPTYPE CONSOLE}

{$R *.res}

uses sysutils, classes, dprocess;

procedure DoLog(s: string);
begin
  writeln(s);
end;

function RunProcess(const Binary: string; args: TStrings): boolean;
const
  BufSize = 1024;
var
  p: TProcess;
  Buf: string;
  Count: integer;
  i: integer;
  LineStart: integer;
  OutputLine: string;
begin
  p := TProcess.Create(nil);
  try
    p.Executable := Binary;

    p.Options := [poUsePipes, poStdErrToOutPut];
//    p.CurrentDirectory := ExtractFilePath(p.Executable);
    p.ShowWindow := swoShowNormal;  // Is this needed?

    p.Parameters.Assign(args);
    DoLog('Running command '+ p.Executable +' with arguments: '+ p.Parameters.Text);
    p.Execute;

    { Now process the output }
    OutputLine:='';
    SetLength(Buf,BufSize);
    repeat
      if (p.Output<>nil) then
      begin
        Count:=p.Output.Read(Buf[1],Length(Buf));
      end
      else
        Count:=0;
      LineStart:=1;
      i:=1;
      while i<=Count do
      begin
        // L505
        //if Buf[i] in [#10,#13] then
        if CharInSet(Buf[i], [#10,#13]) then
        begin
          OutputLine:=OutputLine+Copy(Buf,LineStart,i-LineStart);
          writeln(OutputLine);
          OutputLine:='';
          // L505
          //if (i<Count) and (Buf[i+1] in [#10,#13]) and (Buf[i]<>Buf[i+1]) then
          if (i<Count) and (CharInset(Buf[i+1], [#10,#13])) and (Buf[i]<>Buf[i+1]) then
            inc(i);
          LineStart:=i+1;
        end;
        inc(i);
      end;
      OutputLine:=Copy(Buf,LineStart,Count-LineStart+1);
    until Count=0;
    if OutputLine <> '' then
      writeln(OutputLine);
    p.WaitOnExit;
    Result := p.ExitStatus = 0;
    if not Result then
      Writeln('Command ', p.Executable ,' failed with exit code: ', p.ExitStatus);
  finally
    FreeAndNil(p);
  end;
end;

const
{$ifdef MSWINDOWS}prog = 'cmd';{$endif}

{$ifdef MACOS}prog = 'ls';{$endif}

var args: TStringList;

{$ifdef MSWINDOWS}
procedure SetArgs;
begin
  args.add('/c');
  args.add('dir');
end;
{$endif}

{$ifdef MACOS}
procedure SetArgs;
begin
 // does LS require launching shell (sh) ??
end;
{$endif}

begin
  args := TStringList.Create;
  SetArgs;
  RunProcess(prog, args);
  args.free; args := nil;
  writeln('press enter to exit');
  readln;
end.
