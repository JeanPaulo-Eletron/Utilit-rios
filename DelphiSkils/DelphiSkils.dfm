object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Utilit'#225'rios'
  ClientHeight = 236
  ClientWidth = 536
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
    Width = 536
    Height = 236
    ActivePage = TSConfigConect
    Align = alClient
    TabOrder = 0
    OnChange = JvPageControl1Change
    object TabSheet1: TTabSheet
      Caption = 'Atalhos do teclado'
      object Label1: TLabel
        Left = 0
        Top = 0
        Width = 528
        Height = 208
        Align = alClient
        Caption = 
          'Sobre o bloco de texto Selecionado'#13#10'Control + 0 = Tr'#225's programa ' +
          'para frente'#13#10'Control + 1 = Adiciona "+FimLinhaStr+" e duplica as' +
          'pas simples. '#13#10'Control + 2 = Desfaz o que o Control + 0 fez.'#13#10'Co' +
          'ntrol + 3 = Seta uma region gen'#233'rica sobre.'#13#10'Control + 4 = Igual' +
          'a o distanciamento entre os iguais.'#13#10'Control + 5 = Lista todos o' +
          's campos da tabela ou tabelas do campo, '#13#10'ignora plural.'#13#10'Contro' +
          ' + 6  = Procura todo o termo selecionado nas SPs, Triggers, etc.' +
          '..'
        Font.Charset = ANSI_CHARSET
        Font.Color = clMaroon
        Font.Height = -16
        Font.Name = 'Tempus Sans ITC'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 538
        ExplicitHeight = 180
      end
    end
    object TSConfigConect: TTabSheet
      Caption = 'Configurar conex'#227'o'
      ImageIndex = 2
      object Label2: TLabel
        Left = 16
        Top = 5
        Width = 40
        Height = 13
        Caption = 'Servidor'
      end
      object Label3: TLabel
        Left = 16
        Top = 53
        Width = 36
        Height = 13
        Caption = 'Usu'#225'rio'
      end
      object Label4: TLabel
        Left = 168
        Top = 51
        Width = 30
        Height = 13
        Caption = 'Senha'
      end
      object Label5: TLabel
        Left = 168
        Top = 5
        Width = 49
        Height = 13
        Caption = 'Data Base'
      end
      object EditServidor: TEdit
        Left = 16
        Top = 24
        Width = 121
        Height = 21
        Hint = 'LAPTOP-GK2QJ6O0'
        TabOrder = 0
        Text = 'EditServidor'
        OnExit = EditConfiguraConexaoExit
      end
      object EditUsuario: TEdit
        Left = 16
        Top = 70
        Width = 121
        Height = 21
        TabOrder = 1
        Text = 'EditUsuario'
        OnExit = EditConfiguraConexaoExit
      end
      object EditSenha: TEdit
        Left = 168
        Top = 70
        Width = 121
        Height = 21
        TabOrder = 2
        Text = 'EditSenha'
        OnExit = EditConfiguraConexaoExit
      end
      object EditDataBase: TEdit
        Left = 168
        Top = 24
        Width = 121
        Height = 21
        TabOrder = 3
        Text = 'EditDataBase'
        OnExit = EditConfiguraConexaoExit
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Mouse E Teclado Autom'#225'tizado'
      ImageIndex = 1
      TabVisible = False
    end
  end
end
