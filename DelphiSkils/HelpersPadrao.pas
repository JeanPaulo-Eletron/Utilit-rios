unit HelpersPadrao;

interface

uses Data.Win.ADODB, Winapi.OleDB, Winapi.ADOInt;

Type
  TADOConnectionHelper = Class Helper for TADOConnection
    published
      Function Attributes(Value: TXactAttributes):TADOConnection;
    public
      Function GetAttributes: TXactAttributes;
  End;
Const
  XactAttributeValues: array[TXactAttribute] of TOleEnum = (adXactCommitRetaining,
    adXactAbortRetaining);
implementation

  {$Region 'TADOConnectionHelper'}
    function TADOConnectionHelper.Attributes(
      Value: TXactAttributes): TADOConnection;
    var
      Attributes: LongWord;
      Xa: TXactAttribute;
    begin
      Attributes := 0;
      if Value <> [] then
        for Xa := Low(TXactAttribute) to High(TXactAttribute) do
          if Xa in Value then
            Attributes := Attributes + XactAttributeValues[Xa];

      ConnectionObject.Attributes := Attributes;

      Result := Self;
    end;

    function TADOConnectionHelper.GetAttributes: TXactAttributes;
    var
      Attributes: Integer;
      Xa: TXactAttribute;
    begin
      Result := [];
      Attributes := ConnectionObject.Attributes;
      if Attributes <> 0 then
        for Xa := Low(TXactAttribute) to High(TXactAttribute) do
          if (XactAttributeValues[Xa] and Attributes) <> 0 then
            Include(Result, Xa);
    end;
  {$EndRegion}

end.
