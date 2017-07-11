object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 283
  ClientWidth = 611
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 16
    Top = 256
    Width = 441
    Height = 16
    Caption = 
      'This program captures the output of a console program, using TPr' +
      'ocess'
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 601
    Height = 236
    Lines.Strings = (
      'Output:')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 472
    Top = 250
    Width = 137
    Height = 25
    Caption = 'Run Command'
    TabOrder = 1
    OnClick = Button1Click
  end
end
