unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  System.Generics.Collections;

type

  TMyThread = class(TThread)
  private
    FTempoMax: Integer;
    FMemo: TMemo;
    FProgressBar: TProgressBar;
  public
    constructor Create(TempoMax: Integer;var ProgressBar: TProgressBar;var Memo: TMemo);
    function Init: TMyThread;
    destructor Destroy; override;
    procedure Execute; override;
  end;

  TfThreads = class(TForm)
    edtNumeroThread: TEdit;
    edtTempoInteracao: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    ProgressBar: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FList: TList<TThread>;
    function EstaProcessando: Boolean;
  public
    { Public declarations }
  end;

var
  fThreads: TfThreads;

implementation

{$R *.dfm}

procedure TfThreads.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  if StrToIntDef(edtNumeroThread.Text, 0) <= 0 then
  begin
    MessageDlg('Informe o número de threads que deseja executar', mtInformation, [mbOk], 0);
    edtNumeroThread.SetFocus;
    Exit;
  end;

  if StrToIntDef(edtTempoInteracao.Text, 0) <= 0 then
  begin
    MessageDlg('Informe o tempo de interação máximo', mtInformation, [mbOk], 0);
    edtTempoInteracao.SetFocus;
    Exit;
  end;

  if EstaProcessando then
  begin
    MessageDlg('Já existe um processamento sendo executado', mtInformation, [mbOk], 0);
    Exit;
  end;

  // Ajusta os componentes antes do processamento
  ProgressBar.Max := 101 * StrToInt(edtNumeroThread.Text);
  ProgressBar.Step := 1;
  Memo1.Clear;


  // cria a quantidade de Thread informada e guarda o ponteiro para controle
  for I := 0 to StrToInt(edtNumeroThread.Text) -1 do
  begin
    FList.Add(
      TMyThread.Create(StrToInt(edtTempoInteracao.Text), ProgressBar, Memo1).Init
    );
  end;
end;

function TfThreads.EstaProcessando: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FList.Count -1 do
  begin
    if not FList.Items[I].Finished then
      Exit(True);
  end;
end;

procedure TfThreads.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if EstaProcessando then
  begin
    Vcl.Dialogs.MessageDlg('Aguarde o término do processamento.', mtInformation, [mbOk], 0);
    CanClose := False;
    Exit;
  end;
end;

procedure TfThreads.FormCreate(Sender: TObject);
begin
  FList := TList<TThread>.Create;
end;

procedure TfThreads.FormDestroy(Sender: TObject);
begin
  FList.DisposeOf;
end;

{ TMyThread }

constructor TMyThread.Create(TempoMax: Integer;var ProgressBar: TProgressBar;var Memo: TMemo);
begin
  inherited Create(True);

  FreeOnTerminate := True;
  Priority        := tpHigher;
  FTempoMax       := TempoMax;
  FProgressBar    := ProgressBar;
  FMemo           := Memo;
end;

destructor TMyThread.Destroy;
begin

  inherited;
end;

procedure TMyThread.Execute;
var
  I, Tempo: Integer;
begin
  inherited;

  for I := 0 to 100 do
  begin
    Randomize;
    Tempo := Random(FTempoMax);

    TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
      FMemo.Lines.Add(IntToStr(ThreadID) + ' - Iniciando processamento');
    end);

    TThread.Sleep(Tempo);

    TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
      FProgressBar.StepIt;
      FMemo.Lines.Add(IntToStr(ThreadID) + ' - Processamento finalizado');
    end);
  end;
end;

function TMyThread.Init: TMyThread;
begin
  Result := Self;
  Self.Start;
end;

end.
