{ Freepascal pipes unit converted to Delphi.

  License: FPC Modified LGPL (okay to use in commercial projects)

  Changes to the code marked with "L505" in comments }

{
    This file is part of the Free Pascal run time library.
    Copyright (c) 1999-2000 by Michael Van Canneyt

    Implementation of pipe stream.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


unit dpipes;

interface

uses
  system.types, // L505
  sysutils, Classes;

type
  EPipeError = Class(EStreamError);
  EPipeSeek = Class(EPipeError);
  EPipeCreation = Class(EPipeError);

  { TInputPipeStream }

  TInputPipeStream = Class(THandleStream)
    Private
      FPos : Int64;
      function GetNumBytesAvailable: DWord;
      procedure WriteNotImplemented; // L505
      procedure FakeSeekForward(Offset: Int64; const Origin: TSeekOrigin;
        const Pos: Int64); // L505
      procedure DiscardLarge(Count: int64; const MaxBufferSize: Longint); // L505
      procedure Discard(const Count: Int64); // L505

    protected
      function GetPosition: Int64; // override; //L505
      procedure InvalidSeek; // override; //L505
    public
      destructor Destroy; override;
      Function Write (Const Buffer; Count : Longint) :Longint; Override;
      function Seek(const Offset: int64; Origin: TSeekOrigin): int64; override;
      Function Read (Var Buffer; Count : Longint) : longint; Override;
      property NumBytesAvailable: DWord read GetNumBytesAvailable;
    end;

  TOutputPipeStream = Class(THandleStream)
    Private
      procedure ReadNotImplemented; // L505
      procedure InvalidSeek; // L505
    Public
      destructor Destroy; override;
      function Seek(const Offset: int64; Origin: TSeekOrigin): int64; override;
      Function Read(Var Buffer; Count : Longint) : longint; Override;
    end;

Function CreatePipeHandles (Var Inhandle,OutHandle : THandle; APipeBufferSize : Cardinal = 1024) : Boolean;
Procedure CreatePipeStreams (Var InPipe : TInputPipeStream;
                             Var OutPipe : TOutputPipeStream);

Const EPipeMsg = 'Failed to create pipe.';
      ENoSeekMsg = 'Cannot seek on pipes';


Implementation

{$IFDEF MACOS}   // L505
  {$i pipes_macos.inc}
{$ENDIF}

{$IFDEF MSWINDOWS} // L505
  {$i pipes_win.inc}
{$ENDIF}


Procedure CreatePipeStreams (Var InPipe : TInputPipeStream;
                             Var OutPipe : TOutputPipeStream);
Var InHandle,OutHandle: THandle;
begin
  if CreatePipeHandles(InHandle, OutHandle) then
    begin
    InPipe:=TInputPipeStream.Create(InHandle);
    OutPipe:=TOutputPipeStream.Create(OutHandle);
    end
  Else
    Raise EPipeCreation.Create(EPipeMsg)
end;

destructor TInputPipeStream.Destroy;
begin
  PipeClose(Handle);
  inherited;
end;

// L505
procedure TInputPipeStream.DiscardLarge(Count: int64; const MaxBufferSize: Longint);
var
  Buffer: array of Byte;
begin
  if Count=0 then
     Exit;
  if Count>MaxBufferSize then
    SetLength(Buffer,MaxBufferSize)
  else
    SetLength(Buffer,Count);
  while (Count>=Length(Buffer)) do
    begin
    ReadBuffer(Buffer[0],Length(Buffer));
    Dec(Count,Length(Buffer));
    end;
  if Count>0 then
    ReadBuffer(Buffer[0],Count);
end;

// L505
procedure TInputPipeStream.Discard(const Count: Int64);
const
  CSmallSize      =255;
  CLargeMaxBuffer =32*1024; // 32 KiB
var
  Buffer: array[1..CSmallSize] of Byte;
begin
  if Count=0 then
    Exit;
  if Count<=SizeOf(Buffer) then
    ReadBuffer(Buffer,Count)
  else
    DiscardLarge(Count,CLargeMaxBuffer);
end;

// L505
procedure TInputPipeStream.FakeSeekForward(Offset: Int64;  const Origin: TSeekOrigin; const Pos: Int64);
//var
//  Buffer: Pointer;
//  BufferSize, i: LongInt;
begin
  if Origin=soBeginning then
    Dec(Offset,Pos);
  if (Offset<0) or (Origin=soEnd) then
    InvalidSeek;
  if Offset>0 then
    Discard(Offset);
end;

// L505
procedure TInputPipeStream.WriteNotImplemented;
begin
  raise EStreamError.CreateFmt('Cannot write to this stream, not implemented', []);
end;

// L505
procedure TOutputPipeStream.ReadNotImplemented;
begin
  raise EStreamError.CreateFmt('Cannot read from this stream, not implemented', []);
end;

Function TInputPipeStream.Write(Const Buffer; Count : Longint) : longint;
begin
  WriteNotImplemented;
  Result := 0;
end;

Function TInputPipeStream.Read(Var Buffer; Count : Longint) : longint;
begin
  Result:=Inherited Read(Buffer,Count);
  Inc(FPos,Result);
end;

function TInputPipeStream.Seek(const Offset: int64; Origin: TSeekOrigin): int64;
begin
  FakeSeekForward(Offset,Origin,FPos);
  Result:=FPos;
end;

destructor TOutputPipeStream.Destroy;
begin
  PipeClose(Handle);
  inherited;
end;

Function TOutputPipeStream.Read(Var Buffer; Count : Longint) : longint;
begin
  ReadNotImplemented;
  Result := 0;
end;

procedure TOutputPipeStream.InvalidSeek;
begin
  raise EStreamError.CreateFmt('Invalid seek in TProcess', []);
end;

function TOutputPipeStream.Seek(const Offset: int64; Origin: TSeekOrigin): int64;
begin
  Result:=0; { to silence warning mostly }
  InvalidSeek;
end;

end.
