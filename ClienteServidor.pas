unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB;

type
  TServidor = class
  private
    FPath: String;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant; ProgressBar: TProgressBar): Boolean;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPath: String;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  try

    for i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      cds.Append;
      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
      cds.Post;

      {$REGION Simulação de erro, não alterar}
      if i = (QTD_ARQUIVOS_ENVIAR/2) then
        FServidor.SalvarArquivos(NULL, ProgressBar);
      {$ENDREGION}
    end;

    FServidor.SalvarArquivos(cds.Data, ProgressBar);
  finally
    FreeAndNil(cds);
  end;
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  try
    for i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      cds.Append;
      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
      cds.Post;
    end;

    FServidor.SalvarArquivos(cds.Data, ProgressBar);
  finally
    FreeAndNil(cds);
  end;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;
end;

procedure TfClienteServidor.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FServidor);
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

function TServidor.SalvarArquivos(AData: OleVariant; ProgressBar: TProgressBar): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  Result := False;
  cds := TClientDataset.Create(nil);
  try
    cds.Data := AData;
    ProgressBar.Max := cds.RecordCount;

    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

    cds.First;
    ProgressBar.Step := 1;

    while not cds.Eof do
    begin
      FileName := FPath + cds.RecNo.ToString + '.pdf';
      if TFile.Exists(FileName) then
        TFile.Delete(FileName);

      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      ProgressBar.StepIt;
      cds.Next;
    end;
  finally
     FreeAndNil(cds);
  end;

  Result := True;
end;

end.
