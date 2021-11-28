unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TException = class
  private
    FLogFile : String;
  public
    constructor Create;
    procedure TrataException(Sender: TObject; E : Exception);
    procedure GravarLog(Value : String);
  end;

  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
  private
  public
  end;

var
  fMain: TfMain;
  Exception1 : TException;

implementation

uses
  DatasetLoop, ClienteServidor, System.UITypes;

{$R *.dfm}

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  fDatasetLoop.Show;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  fClienteServidor.Show;
end;

{ TException }

constructor TException.Create;
begin
  FLogFile := ChangeFileExt(ParamStr(0), '.log');
  Application.OnException := TrataException;
end;

procedure TException.GravarLog(Value: String);
var
  txtLog : TextFile;
begin
  AssignFile(txtLog, FLogFile);
  if FileExists(FLogFile) then
    Append(txtLog)
  else
    Rewrite(txtLog);
  Writeln(txtLog, FormatDateTime('dd/mm/YY hh:nn:ss - ', Now) + Value);
  CloseFile(txtLog);
end;

procedure TException.TrataException(Sender: TObject; E: Exception);
begin
  GravarLog('===========================================');
  if TComponent(Sender) is TForm then
  begin
    GravarLog('Form: '    + TForm(Sender).Name);
    GravarLog('Caption: ' + TForm(Sender).Caption);
    GravarLog('Erro:'     + E.ClassName);
    GravarLog('Erro:'     + E.Message);
  end
  else
  begin
    GravarLog('Form: ' + TForm(TComponent(Sender).Owner).Name);
    GravarLog('Caption: ' + TForm(TComponent(Sender).Owner).Caption);
    GravarLog('Erro:' + E.ClassName);
    GravarLog('Erro:' + E.Message);
  end;

  Vcl.Dialogs.MessageDlg('Erro: '+ E.Message, mtError, [mbOk], 0);
end;

initialization
  Exception1 := TException.Create;

finalization
  Exception1.Free;

end.
