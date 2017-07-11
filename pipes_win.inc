{ Freepascal pipes unit converted to Delphi (needed for TProcess)

  License: FPC Modified LGPL (okay to use in commercial projects)

  Changes to the code marked with "L505" in comments }

{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1998 by Michael Van Canneyt

    Win part of pipe stream.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
uses
  windows; //L505

// L505
type
  PSecurityAttributes = ^TSecurityAttributes;
  TSecurityAttributes = record
    nLength : DWORD;
    lpSecurityDescriptor : Pointer;
    bInheritHandle : BOOL;
  end;

Const piInheritablePipe : TSecurityAttributes = (
                           nlength:SizeOF(TSecurityAttributes);
                           lpSecurityDescriptor:Nil;
                           Binherithandle:True);
      piNonInheritablePipe : TSecurityAttributes = (
                             nlength:SizeOF(TSecurityAttributes);
                             lpSecurityDescriptor:Nil;
                             Binherithandle:False);


      PipeBufSize = 1024;


Function CreatePipeHandles (Var Inhandle,OutHandle : THandle; APipeBufferSize : Cardinal = PipeBufSize) : Boolean;
begin
  // L505
  // Result := CreatePipe(@Inhandle,@OutHandle,@piNonInheritablePipe,APipeBufferSize);
  Result := CreatePipe(Inhandle,OutHandle,@piNonInheritablePipe,APipeBufferSize);
  //writeln('DEBUG: createpipe result: ', result);
end;

Function TInputPipeStream.GetNumBytesAvailable: DWord;
begin
  if not PeekNamedPipe(Handle, nil, 0, nil, @Result, nil) then
    Result := 0;
end;

function TInputPipeStream.GetPosition: Int64;
begin
  Result:=FPos;
end;

procedure TInputPipeStream.InvalidSeek;
begin
  Raise EPipeSeek.Create(ENoSeekMsg);
end;

procedure PipeClose(const FHandle: THandle); inline;
begin
  FileClose(FHandle);
end;
