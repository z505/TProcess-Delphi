unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
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
  Form2: TForm2;

implementation

{$R *.dfm}

uses
  dprocess;  // TProcess from FPC, ported to delphi

procedure TForm2.Button1Click(Sender: TObject);
var output: ansistring;
begin
  RunCommand('cmd', ['/c', 'dir'], output, [poNoConsole]);
  memo1.Lines.Add(output);
end;

end.
