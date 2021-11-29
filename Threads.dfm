object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'Threads'
  ClientHeight = 203
  ClientWidth = 508
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 14
    Top = 23
    Width = 94
    Height = 13
    Caption = 'Numero de Threads'
  end
  object Label2: TLabel
    Left = 149
    Top = 23
    Width = 82
    Height = 13
    Caption = 'Tempo Intera'#231#227'o'
  end
  object edtNumeroThread: TEdit
    Left = 14
    Top = 38
    Width = 131
    Height = 21
    NumbersOnly = True
    TabOrder = 0
  end
  object edtTempoInteracao: TEdit
    Left = 149
    Top = 38
    Width = 129
    Height = 21
    NumbersOnly = True
    TabOrder = 1
  end
  object Button1: TButton
    Left = 420
    Top = 36
    Width = 75
    Height = 25
    Caption = 'Iniciar'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 14
    Top = 71
    Width = 481
    Height = 89
    TabOrder = 3
  end
  object ProgressBar: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 183
    Width = 502
    Height = 17
    Align = alBottom
    TabOrder = 4
    ExplicitLeft = 8
    ExplicitTop = 192
  end
end
