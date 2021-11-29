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
    procedure RollBack;
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
    procedure btEnviarParaleloClick(Sender: TObject);
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
  // Defeito 3: Ao realizar o envio dos arquivos ao servidor não havia tratamento
  // da exceção gerada, Para corrigir foi implementado um metodo de rollback que
  // lista e apaga todos os arquivos da pasta onde estavam salvos
  cds := InitDataset;
  try

    for i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      cds.Append;
      cds.FieldByName('Arquivo').AsString := FPath;
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

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
  myFile: file of Byte;
begin

  cds := InitDataset;
  try
    for i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      cds.Append;
      cds.FieldByName('Arquivo').Value := FPath;
      cds.Post;
    end;

    TThread.CreateAnonymousThread(procedure
    begin
      FServidor.SalvarArquivos(cds.Data, ProgressBar);
    end).Start;

    // gera um gargalo para não sobrecarregar com todas a threads ao mesmo tempo
    Sleep(400);
  finally
    FreeAndNil(cds);
  end;

end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  // Defeito 2: o Windows tem por padrão um limite de memoria em que permite
  // que a aplicação possa consumir, por conta desta rotina está carregando na
  // memoria todos os arquivos .pdf (e por sinal este pdf tem quase 50 mb) isto
  // isto está ultrapassando o limite permitido, A solução seria colocar apenas
  // o caminho do arquivo, e no momento do envio ao servidor, o arquivo é lido e
  // enviado individualmente. Mantendo assim o baixo consumo de memoria.
  cds := InitDataset;
  try
    for i := 0 to QTD_ARQUIVOS_ENVIAR do
    begin
      cds.Append;
      cds.FieldByName('Arquivo').Value := FPath;
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

procedure TServidor.RollBack;
var
  SR: TSearchRec;
  I: integer;
begin
  I := FindFirst(FPath +'*.*', faAnyFile, SR);
  while I = 0 do
  begin
    if ((SR.Attr and faDirectory) = 0) then
    begin
      if not DeleteFile(FPath + SR.Name) then
        raise Exception.Create('Não foi possível excluir ' + FPath + SR.Name);
    end;
    I := FindNext(SR);
  end;
end;

function TServidor.SalvarArquivos(AData: OleVariant; ProgressBar: TProgressBar): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  Result := False;
  try
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

        CopyFile(PChar(cds.FieldByName('Arquivo').AsString), PChar(FileName), True);
        ProgressBar.StepIt;
        cds.Next;
      end;
    finally
       FreeAndNil(cds);
    end;
  except
    RollBack;
    raise;
  end;

  Result := True;
end;

end.
