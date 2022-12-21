object SaveBackupper: TSaveBackupper
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'AutoSave'
  ClientHeight = 125
  ClientWidth = 255
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblBackup: TLabel
    Left = 45
    Top = 29
    Width = 165
    Height = 13
    Caption = 'Do you wish to replace your save?'
  end
  object lblAutosave: TLabel
    Left = 8
    Top = 99
    Width = 77
    Height = 13
    Caption = 'Autosave timer:'
  end
  object lblCountDown: TLabel
    Left = 118
    Top = 8
    Width = 2
    Height = 8
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowFrame
    Font.Height = -7
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object btnDo: TButton
    Left = 62
    Top = 64
    Width = 130
    Height = 25
    Caption = 'Replace'
    Enabled = False
    TabOrder = 0
    OnClick = btnDoClick
  end
  object btnTimerBool: TButton
    Left = 135
    Top = 92
    Width = 112
    Height = 25
    TabOrder = 1
    OnClick = btnTimerBoolClick
  end
  object edtAutoSave: TEdit
    Left = 91
    Top = 95
    Width = 38
    Height = 21
    MaxLength = 4
    NumbersOnly = True
    TabOrder = 2
    OnChange = edtAutosaveChange
  end
  object tmrAutoBackup: TTimer
    Interval = 300000
    OnTimer = tmrAutoBackupTimer
    Left = 216
    Top = 48
  end
  object tmrRefresh: TTimer
    OnTimer = tmrRefreshTimer
    Left = 16
    Top = 48
  end
end
