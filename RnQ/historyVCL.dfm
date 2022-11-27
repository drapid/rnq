object HistoryData: THistoryData
  Height = 329
  Width = 523
  PixelsPerInch = 168
  object histmenu: TPopupMenu
    OwnerDraw = True
    OnPopup = histmenuPopup
    Left = 152
    Top = 28
    object add2rstr: TMenuItem
      Action = hAaddtoroaster
    end
    object copylink2clpbd: TMenuItem
      Caption = 'Copy link'
      OnClick = copylink2clpbdClick
    end
    object copy2clpb: TMenuItem
      Action = hACopy
    end
    object savePicMnu: TMenuItem
      Caption = 'Save pic'
      OnClick = savePicMnuClick
    end
    object selectall1: TMenuItem
      Action = hASelectAll
    end
    object viewmessageinwindow1: TMenuItem
      Caption = 'View message in window'
      OnClick = viewmessageinwindow1Click
    end
    object saveas1: TMenuItem
      Action = hAsaveas
      object txt1: TMenuItem
        Caption = 'txt'
        OnClick = txt1Click
      end
      object html1: TMenuItem
        Caption = 'html'
        OnClick = html1Click
      end
    end
    object addlink2fav: TMenuItem
      Caption = 'Add link to favorites'
      OnClick = addlink2favClick
    end
    object del1: TMenuItem
      Action = hAdelete
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object toantispam: TMenuItem
      Caption = 'To antispam'
      OnClick = toantispamClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Openchatwith1: TMenuItem
      Action = hAOpenChatWith
    end
    object ViewinfoM: TMenuItem
      Action = hAViewInfo
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object chtShowSmiles: TMenuItem
      Action = hAShowSmiles
      AutoCheck = True
    end
    object chatshowlsb1: TMenuItem
      Action = hAchatshowlsb
    end
    object chatpopuplsb1: TMenuItem
      Action = hAchatpopuplsb
    end
    object chatShowDevTools: TMenuItem
      Caption = 'Show Dev tools'
      OnClick = chatShowDevToolsClick
    end
  end
  object ActList1: TActionList
    Left = 68
    Top = 28
    object hAaddtoroaster: TAction
      Category = 'histMenu'
      Caption = 'Add to contact list'
      HelpKeyword = 'addedyou'
      OnExecute = ANothingExecute
    end
    object hAsaveas: TAction
      Category = 'histMenu'
      Caption = 'Save as'
      HelpKeyword = 'save'
      OnExecute = ANothingExecute
    end
    object hAdelete: TAction
      Category = 'histMenu'
      Caption = 'Delete selected'
      HelpKeyword = 'delete'
      OnExecute = hAdeleteExecute
    end
    object hACopy: TAction
      Category = 'histMenu'
      Caption = 'Copy'
      HelpKeyword = 'copy'
      OnExecute = hACopyExecute
    end
    object hASelectAll: TAction
      Category = 'histMenu'
      Caption = 'Select all'
      HelpKeyword = 'select.all'
      OnExecute = hASelectAllExecute
    end
    object hAchatshowlsb: TAction
      Category = 'histMenu'
      Caption = 'Show left scrollbar'
      OnExecute = hAchatshowlsbExecute
      OnUpdate = hAchatshowlsbUpdate
    end
    object hAchatpopuplsb: TAction
      Category = 'histMenu'
      Caption = 'Popup left scrollbar'
      OnExecute = hAchatpopuplsbExecute
      OnUpdate = hAchatpopuplsbUpdate
    end
    object hAViewInfo: TAction
      Category = 'histMenu'
      Caption = 'View info'
      OnExecute = hAViewInfoExecute
    end
    object hAShowSmiles: TAction
      Category = 'histMenu'
      AutoCheck = True
      Caption = 'Show graphic smiles'
      Checked = True
      HelpKeyword = 'smiles'
      OnExecute = hAShowSmilesExecute
      OnUpdate = hAShowSmilesUpdate
    end
    object ShowStickers: TAction
      Category = 'chatActions'
      Caption = 'ShowStickers'
      SecondaryShortCuts.Strings = (
        'Ctrl+Shift+S')
    end
    object hAShowDevTools: TAction
      Category = 'histMenu'
      Caption = 'hAShowDevTools'
      HelpKeyword = 'debug'
    end
    object hAOpenChatWith: TAction
      Category = 'histMenu'
      Caption = 'Open chat with...'
      HelpKeyword = 'msg'
      Visible = False
      OnExecute = hAOpenChatWithExecute
    end
  end
end
