{ This delphi demo shows how to capture the output of a command using TProcess
  now ported to delphi, originally from the FPC RTL/FCL
  Example: capture output of "dir" command (list directory contents), or any
           other command

  License: this demo is MIT/BSD, dprocess/dpipes is permissive modified LGPL
}

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses dprocess;  // this is the TProcess unit from FPC, now ported to delphi

procedure OutLn(s: string); overload;
begin
  form1.memo1.lines.add(s);
end;

procedure OutLn(s: string; i: integer); overload;
begin
  outln(s + inttostr(i));
end;

procedure DoLog(s: string);
begin
  OutLn('Log: '+s);
end;

function RunProcess(const Binary: string; args: TStrings): boolean;
const
  BufSize = 1024;
var
  p: TProcess;
  // Buf: string;  // L505 note: must use ansistring
  Buf: ansistring; //
  Count: integer;
  i: integer;
  LineStart: integer;
  // OutputLine: string;  //L505 note: must use ansistring
  OutputLine: ansistring; //

begin
  p := TProcess.Create(nil);
  try
    p.Executable := Binary;

    p.Options := [poUsePipes,
                  poStdErrToOutPut];
//    p.CurrentDirectory := ExtractFilePath(p.Executable);
    p.ShowWindow := swoHIDE {ShowNormal};

    p.Parameters.Assign(args);
    DoLog('Running command '+ p.Executable +' with arguments: '+ p.Parameters.Text);
    p.Execute;

    { Now process the output }
    OutputLine:='';
    SetLength(Buf,BufSize);
    repeat
      if (p.Output<>nil) then
      begin
        // Count:=p.Output.Read(Buf[1],Length(Buf));
        Count:=p.Output.Read(pchar(Buf)^, BufSize);  //L505 changed to pchar because of unicodestring
        // outln('DEBUG: len buf: ', length(buf));
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
          outln(OutputLine);
          OutputLine:='';
          // L505
          //if (i<Count) and (Buf[i+1] in [#10,#13]) and (Buf[i]<>Buf[i+1]) then
          if (i<Count) and (CharInset(Buf[i], [#10,#13])) and (Buf[i]<>Buf[i+1]) then
            inc(i);
          LineStart:=i+1;
        end;
        inc(i);
      end;
      OutputLine:=Copy(Buf,LineStart,Count-LineStart+1);
    until Count=0;
    if OutputLine <> '' then
      outln(OutputLine);
//  else
//    outln('DEBUG: empty line');
    p.WaitOnExit;
    Result := p.ExitStatus = 0;
    if not Result then
      outln('Command '+ p.Executable +' failed with exit code: ', p.ExitStatus);
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  args := TStringList.Create;
  SetArgs;
  RunProcess(prog, args);
  args.free; args := nil;
end;

end.
