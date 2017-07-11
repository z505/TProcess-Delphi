object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 328
  ClientWidth = 552
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
    Left = 176
    Top = 8
    Width = 305
    Height = 16
    Caption = 'This program captures the output of a command'
  end
  object Memo1: TMemo
    Left = 8
    Top = 39
    Width = 520
    Height = 276
    Lines.Strings = (
      'Output:'
      '')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 24
    Top = 8
    Width = 121
    Height = 25
    Caption = 'Run Command'
    TabOrder = 1
    OnClick = Button1Click
  end
end
