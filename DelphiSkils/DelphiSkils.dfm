object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Utilit'#225'rios'
  ClientHeight = 161
  ClientWidth = 534
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 550
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object JvPageControl1: TJvPageControl
    Left = 0
    Top = 0
    Width = 534
    Height = 161
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Atalhos do teclado'
      object Label1: TLabel
        Left = 0
        Top = 0
        Width = 526
        Height = 133
        Align = alClient
        Caption = 
          'Sobre o bloco de texto Selecionado'#13#10'Control + 0 = Adiciona "+Fim' +
          'LinhaStr+" e duplica aspas simples '#13#10'Control + 1 = Desfaz o que ' +
          'o Control + 0 fez'#13#10'Control + 2 = Seta uma region gen'#233'rica sobre'#13 +
          #10'Control + 3 = Iguala o distanciamento entre os iguais'
        Font.Charset = ANSI_CHARSET
        Font.Color = clMaroon
        Font.Height = -16
        Font.Name = 'Tempus Sans ITC'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 484
        ExplicitHeight = 100
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Mouse E Teclado Autom'#225'tizado'
      ImageIndex = 1
      TabVisible = False
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 1080
      ExplicitHeight = 375
    end
  end
end
