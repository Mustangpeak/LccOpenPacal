unit lcc_ethernet_server;

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF}

interface

{$I ../../lcc_compilers.inc}

uses
  Classes,
  SysUtils,
  {$IFDEF FPC}
    {$IFNDEF FPC_CONSOLE_APP}
      Forms,
    {$ENDIF}
  {$ELSE}
    FMX.Forms,
    Types,
    System.Generics.Collections,
  {$ENDIF}

  IdBaseComponent,
  IdCustomTCPServer,
  IdTCPConnection,
  IdTCPServer,
  IdContext,
  IdComponent,
  IdGlobal,
  IdException,
  lcc_threaded_circulararray,
  lcc_utilities,
  lcc_defines,
  lcc_node_messages_can_assembler_disassembler,
  lcc_common_classes,
  lcc_node_messages,
  lcc_node_manager,
  lcc_ethernet_common,
  lcc_gridconnect,
  lcc_node,
  lcc_alias_server;

type

  TLccEthernetListener = class;

  { TLccServerContexts }

  TLccServerContexts = class
  private
    FCircularArray: TCircularArray;
    FContext: TIdContext;
    FGridConnectHelper: TGridConnectHelper;
    FGridConnectMessageAssembler: TLccGridConnectMessageAssembler;
    FStringList: TStringList;
  public
    property Context: TIdContext read FContext write FContext;
    property StringList: TStringList read FStringList write FStringList;
    property CircularArray: TCircularArray read FCircularArray write FCircularArray;
    property GridConnectHelper: TGridConnectHelper read FGridConnectHelper;
    property GridConnectMessageAssembler: TLccGridConnectMessageAssembler read FGridConnectMessageAssembler write FGridConnectMessageAssembler;

    constructor Create(AContext: TIdContext);
    destructor Destroy; override;
  end;

  { TLccContextsList }

  TLccContextsList = class(TThreadList)
  private
    FOwner: TLccEthernetListener;
    FWorkerMessage: TLccMessage;
    function GetCount: Integer;
    function GetGridConnectContext(Index: Integer): TLccServerContexts;
  protected
    property WorkerMessage: TLccMessage read FWorkerMessage write FWorkerMessage;
  public
    property Count: Integer read GetCount;
    property GridConnectContext[Index: Integer]: TLccServerContexts read GetGridConnectContext;
    property Owner: TLccEthernetListener read FOwner;

    constructor Create(AnOwner: TLccEthernetListener);
    destructor Destroy; override;
    function AddContext(AContext: TIdContext): TLccServerContexts;
    procedure AddGridConnectStringByContext(AContext: TIdContext; AString: string; NodeManager: TLccNodeManager);
    procedure Clear;
    function RemoveContext(AContext: TIdContext): Boolean;
  end;

  { TLccEthernetListener }

  TLccEthernetListener = class(TLccBaseEthernetThread)
  private
    FGridConnectContextList: TLccContextsList;
    FIdTCPServer: TIdTCPServer;
  protected
    property Running: Boolean read FRunning;
    property IdTCPServer: TIdTCPServer read FIdTCPServer write FIdTCPServer;
    // List that contains the contexts (threads) the server is serviceing.
    // Allows us to keep the data coming in/going out associated with each context
    property GridConnectContextList: TLccContextsList read FGridConnectContextList write FGridConnectContextList;

    procedure IdTCPServerConnect(AContext: TIdContext);
    procedure IdTCPServerDisconnect(AContext: TIdContext);
    procedure IdTCPServerExecute(AContext: TIdContext);
    procedure IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);

    procedure ReceiveMessage;  // For Syncronize

    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean; AnOwner: TLccHardwareConnectionManager; AConnectionInfo: TLccHardwareConnectionInfo); override;
    destructor Destroy; override;
  end;

  { TLccEthernetServer }

  TLccEthernetServer = class(TLccEthernetHardwareConnectionManager)
  private
    FListenerThread: TLccEthernetListener;
    { Private declarations }
  protected
    { Protected declarations }
    function CreateListenerObject(AConnectionInfo: TLccEthernetConnectionInfo): TLccEthernetListener; virtual;
    function IsLccLink: Boolean; override;
    function GetConnected: Boolean; override;

    procedure DoReceiveMessage(LccMessage: TLccMessage); override;
  public
    { Public declarations }
    property ListenerThread: TLccEthernetListener read FListenerThread write FListenerThread;

    function OpenConnection(AConnectionInfo: TLccHardwareConnectionInfo): TLccConnectionThread; override;
    procedure CloseConnection;  override;
    procedure SendMessage(ALccMessage: TLccMessage); override;
  end;


implementation

{ TLccContextsList }

function TLccContextsList.GetGridConnectContext(Index: Integer): TLccServerContexts;
var
  List: TList;
begin
  List := LockList;
  try
    Result := TLccServerContexts(List[Index]);
  finally
    UnlockList;
  end;
end;

constructor TLccContextsList.Create(AnOwner: TLccEthernetListener);
begin
  inherited Create;
  FOwner := AnOwner;
  FWorkerMessage := TLccMessage.Create;
end;

function TLccContextsList.GetCount: Integer;
var
  List: TList;
begin
  List := LockList;
  try
    Result := List.Count
  finally
    UnlockList;
  end;
end;

destructor TLccContextsList.Destroy;
begin
  Clear;
  FreeAndNil(FWorkerMessage);
  inherited Destroy;
end;

function TLccContextsList.AddContext(AContext: TIdContext): TLccServerContexts;
var
  List: TList;
  i: Integer;
  Found: Boolean;
begin
  Found := False;
  Result := nil;
  List := LockList;
  try
    for i := 0 to List.Count - 1 do
    begin
      if TLccServerContexts(List[i]).Context = AContext then
      begin
        Found := True;
        Result := TLccServerContexts(List[i]);
        Break;
      end;
    end;
    if not Found then
    begin
      Result := TLccServerContexts.Create(AContext);
      List.Add(Result);
    end;
  finally
    UnlockList;
  end;
end;

procedure TLccContextsList.Clear;
var
  List: TList;
  i: Integer;
begin
  List := LockList;
  try
    for i := 0 to List.Count - 1 do
      TObject(List[i]).Free;
  finally
    List.Clear;
    UnlockList;
  end;
end;

function TLccContextsList.RemoveContext(AContext: TIdContext): Boolean;
var
  List: TList;
  i: Integer;
begin
  Result := False;
  List := LockList;
  try
    for i := 0 to List.Count - 1 do
    begin
      if TLccServerContexts(List[i]).Context = AContext then
      begin
        List.Delete(i);
        Result := True;
        Break;
      end;
    end;
  finally
    UnlockList;
  end;
end;

procedure TLccContextsList.AddGridConnectStringByContext(AContext: TIdContext; AString: string; NodeManager: TLccNodeManager);
var
  ContextList, NodeList, MessageStackList:  TList;
  ThreadedNode: TLccNode;
  iContext, iString, iNode: Integer;
  ServerContext: TLccServerContexts;
  GridConnectStrPtr: PGridConnectString;
  MessageStr: String;
  ANodeID: TNodeID;
begin
  ContextList := LockList;
  try
    // Contexts are adding/removed in IdTCPServerConnect/IdTCPServerDisconnectConnect
    for iContext := 0 to ContextList.Count - 1 do
    begin
      ServerContext := TLccServerContexts(ContextList[iContext]);
      if ServerContext.Context = AContext then
      begin
        for iString := 1 to Length(AString) do
        begin
          // Take the incoming characters and try to make a valid gridconnect message
          GridConnectStrPtr := nil;
          if ServerContext.GridConnectHelper.GridConnect_DecodeMachine(Ord(AString[iString]), GridConnectStrPtr) then
          begin
            // Have a valid gridconnect message
            MessageStr := GridConnectBufferToString(GridConnectStrPtr^);
            WorkerMessage.LoadByGridConnectStr(MessageStr);

            // Message may only be part of a larger string of messages to make up a full LCC message.
            // This call will concatinate these partial Lcc message and return with a fully qualified
            // Lcc message.
            case ServerContext.GridConnectMessageAssembler.IncomingMessageGridConnect(WorkerMessage) of
              imgcr_True :
                begin
                  case WorkerMessage.CAN.MTI of
                    MTI_CAN_AMR :
                      begin
                        AliasServer.MarkForRemovalByAlias(WorkerMessage.CAN.SourceAlias);
                      end;
                    MTI_CAN_AMD :
                      begin
                        ANodeID := NULL_NODE_ID;
                        AliasServer.AddMapping(WorkerMessage.CAN.SourceAlias, WorkerMessage.ExtractDataBytesAsNodeID(0, ANodeID));
                      end;
                  end;

                  case WorkerMessage.MTI of
                    MTI_VERIFIED_NODE_ID_NUMBER,
                    MTI_INITIALIZATION_COMPLETE :
                      begin
                        ANodeID := NULL_NODE_ID;
                        AliasServer.AddMapping(WorkerMessage.CAN.SourceAlias, WorkerMessage.ExtractDataBytesAsNodeID(0, ANodeID));
                      end;
                  end;

                  NodeManager.MessageServerThread.AddMessage(WorkerMessage);

                  try
                    Owner.Synchronize({$IFDEF FPC}@{$ENDIF}Owner.ReceiveMessage);  // WorkerMessage contains the message
                  except
                  end;
                end;
              imgcr_ErrorToSend :
                begin
         //         ConnectionInfo.LccMessage.CopyToTarget(WorkerMessage);
         //         Synchronize({$IFDEF FPC}@{$ENDIF}RequestErrorMessageSent);
                end;
              imgcr_False,
              imgcr_UnknownError :
                begin

                end;
            end;
          end;
        end;

        Break;
      end;
    end;
  finally
    UnlockList;
  end;
end;

{ TLccServerContexts }

constructor TLccServerContexts.Create(AContext: TIdContext);
begin
  FContext := AContext;
  FStringList := TStringList.Create;
  FCircularArray := TCircularArray.Create;
  FGridConnectHelper := TGridConnectHelper.Create;
  FGridConnectMessageAssembler := TLccGridConnectMessageAssembler.Create;
end;

destructor TLccServerContexts.Destroy;
begin
  inherited;
  FreeAndNil(FStringList);
  FreeAndNil(FCircularArray);
  FreeAndNil(FGridConnectHelper);
  FreeAndNil(FGridConnectMessageAssembler);
end;

{ TLccEthernetListener }

procedure TLccEthernetListener.Execute;
var
  i: Integer;
  ContextList: TList;
begin
  FRunning := True;
  try
    try
      try
        IdTCPServer.Active          := False;
        IdTCPServer.MaxConnections  := 255;
          // ... assign a new context class (if you need)
       // IdTCPServer.ContextClass    := TYourContext;

        // add some callback functions
        IdTCPServer.OnConnect := {$IFDEF FPC}@{$ENDIF}IdTCPServerConnect;
        IdTCPServer.OnDisconnect := {$IFDEF FPC}@{$ENDIF}IdTCPServerDisconnect;
        IdTCPServer.OnExecute := {$IFDEF FPC}@{$ENDIF}IdTCPServerExecute;
        IdTCPServer.OnStatus := {$IFDEF FPC}@{$ENDIF}IdTCPServerStatus;
        IdTCPServer.TerminateWaitTime := 2;

        HandleSendConnectionNotification(lcsConnecting);

        if (ConnectionInfo as TLccEthernetConnectionInfo).AutoResolveIP then
        begin
          {$IFDEF LCC_WINDOWS}
          (ConnectionInfo as TLccEthernetConnectionInfo).ListenerIP := ResolveWindowsIp
          {$ELSE}
          (ConnectionInfo as TLccEthernetConnectionInfo).ListenerIP := ResolveUnixIp;
          {$ENDIF}
        end;

        IdTCPServer.Bindings.Clear;
        IdTCPServer.Bindings.Add.Port := 12021;
        IdTCPServer.Bindings.Add.IP := (ConnectionInfo as TLccEthernetConnectionInfo).ListenerIP;

        IdTCPServer.Active := True;

        if IdTCPServer.Active then
        begin
          HandleSendConnectionNotification(lcsConnected);
          while not Terminated do
          begin

            // Receiving messages are handled IdTCPServerExecute handler and dispatched
            // directly to each LccNode

            // Sending out what need to be sent to the connections
            ContextList := IdTCPServer.Contexts.LockList;
            try
              for i := 0 to IdTCPServer.Contexts.Count - 1 do
              begin
                if TIdContext( ContextList[i]).Connection.Connected then
                begin
                  if (ConnectionInfo as TLccEthernetConnectionInfo).GridConnect then
                    TryTransmitGridConnect(TIdContext( ContextList[i]).Connection.IOHandler)
                  else
                    TryTransmitTCPProtocol(TIdContext( ContextList[i]).Connection.IOHandler);
                end;
              end;
            finally
              IdTCPServer.Contexts.UnlockList;
            end;

            IndySleep(50);
          end
        end;
      finally
        HandleSendConnectionNotification(lcsDisconnecting);
        try
          IdTCPServer.Active := False;
        finally
          // Can I poll the contexts looking for Connected to be false?

          HandleSendConnectionNotification(lcsDisconnected);
        end;
      end;
    except  // idTCPServer uses exceptions to throw faults, trap them so the users does not see them
      on E: EIdException do
      begin
        ConnectionInfo.ErrorMessage := E.Message;
        Synchronize({$IFDEF FPC}@{$ENDIF}ErrorMessage);
      end;
    end;
  finally
    FRunning := False;
  end;
end;

constructor TLccEthernetListener.Create(CreateSuspended: Boolean; AnOwner: TLccHardwareConnectionManager; AConnectionInfo: TLccHardwareConnectionInfo);
begin
  inherited Create(CreateSuspended, AnOwner, AConnectionInfo);
  IdTCPServer := TIdTCPServer.Create(nil);
  FGridConnectContextList := TLccContextsList.Create(Self);
  FreeOnTerminate := False;
end;

destructor TLccEthernetListener.Destroy;
begin

  IdTCPServer.Free;
  GridConnectContextList.Free;
  inherited Destroy;
end;

procedure TLccEthernetListener.IdTCPServerConnect(AContext: TIdContext);
begin
  GridConnectContextList.AddContext(AContext);

  (ConnectionInfo as TLccEthernetConnectionInfo).ClientIP := AContext.Binding.PeerIP;
  (ConnectionInfo as TLccEthernetConnectionInfo).ClientPort := AContext.Binding.PeerPort;
  HandleSendConnectionNotification(lcsClientConnected);
end;

procedure TLccEthernetListener.IdTCPServerDisconnect(AContext: TIdContext);
begin
  GridConnectContextList.RemoveContext(AContext);

  (ConnectionInfo as TLccEthernetConnectionInfo).ClientIP := AContext.Binding.PeerIP;
  (ConnectionInfo as TLccEthernetConnectionInfo).ClientPort := AContext.Binding.PeerPort;
  HandleSendConnectionNotification(lcsClientDisconnected);
end;

procedure TLccEthernetListener.IdTCPServerExecute(AContext: TIdContext);
var
  AString: string;
  AChar: AnsiChar;
  List: TList;
  iContext, iByte: Integer;
  OtherContext: TIdContext;
begin
  // Messages sent to the Listener from all the Connections (Contexts)

  // Well well this just got more complicated... Need to have a separate buffer for each Context...
  AString := '';
  while not AContext.Connection.IOHandler.InputBufferIsEmpty and AContext.Connection.IOHandler.Connected do
  begin
    AChar := AnsiChar(AContext.Connection.IOHandler.ReadByte);
    AString := AString + string(AChar);
  end;

  // Put the string in the correct context (each context is a connection to the server so keep the messages sorted per context)... do I need to do this?  Unsure.
  // the main Execute method will pick this up and pass them along... another reason is to allow this thread to be a hub and relay the messages from one context
  // to another...
  if AString <> '' then
  begin
    if Owner.NodeManager.GridConnect then
      GridConnectContextList.AddGridConnectStringByContext(AContext, AString, Owner.NodeManager)
    else begin
      // TCP Here
    end;

    if Owner.Hub then
    begin
      List := IdTCPServer.Contexts.LockList;
      try
        for iContext := 0 to List.Count - 1 do
        begin
          OtherContext := TIdContext(List[iContext]);
          if OtherContext <> AContext then
            if OtherContext.Connection.Connected then
            begin
              for iByte := 1 to Length(AString) do
                OtherContext.Connection.IOHandler.Write(Ord( AString[iByte]));
            end;
        end;
      finally
        IdTCPServer.Contexts.UnlockList;
      end;
    end;
  end;

     // https://stackoverflow.com/questions/64593756/delphi-rio-indy-tcpserver-high-cpu-usage
    // There is another way to do this but with this simple program this is fine
  IndySleep(50);
end;

procedure TLccEthernetListener.IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin   {
  case AStatus of
    hsConnecting    : HandleSendConnectionNotification(lcsConnecting);
    hsConnected     : HandleSendConnectionNotification(lcsConnected);
    hsDisconnecting : HandleSendConnectionNotification(lcsDisconnecting);
    hsDisconnected  : HandleSendConnectionNotification(lcsDisconnected);
  end;     }
end;

procedure TLccEthernetListener.ReceiveMessage;
begin
  (Owner as TLccEthernetServer).DoReceiveMessage(GridConnectContextList.WorkerMessage);
end;

{ TLccEthernetServer }

procedure TLccEthernetServer.CloseConnection;
var
  TimeCount: Integer;
begin
  NodeManager.Clear;

  inherited CloseConnection;
  if Assigned(ListenerThread) then
  begin
    TimeCount := 0;
    ListenerThread.Terminate;
    while ListenerThread.Running do
    begin
      {$IFNDEF FPC_CONSOLE_APP}Application.ProcessMessages;{$ELSE}CheckSynchronize();{$ENDIF}  // Pump the timers
      Inc(TimeCount);
      Sleep(500);
      if TimeCount = 10 then Break // Something went really wrong
    end;
    FreeAndNil(FListenerThread);
  end;
end;

function TLccEthernetServer.IsLccLink: Boolean;
begin
  Result := True;
end;

function TLccEthernetServer.GetConnected: Boolean;
begin
  Result := False;
  if Assigned(ListenerThread) and Assigned(ListenerThread.IdTCPServer) then
    Result := ListenerThread.IdTCPServer.Active;
end;

procedure TLccEthernetServer.DoReceiveMessage(LccMessage: TLccMessage);
begin
  inherited DoReceiveMessage(LccMessage);
end;

procedure TLccEthernetServer.SendMessage(ALccMessage: TLccMessage);
begin
  if Assigned(ListenerThread) then
    ListenerThread.AddToOutgoingBuffer(ALccMessage);
  inherited SendMessage(ALccMessage);
end;

function TLccEthernetServer.OpenConnection(AConnectionInfo: TLccHardwareConnectionInfo): TLccConnectionThread;
begin
  inherited OpenConnection(AConnectionInfo);
  Result := CreateListenerObject(AConnectionInfo.Clone as TLccEthernetConnectionInfo);
  ListenerThread := Result as TLccEthernetListener;
  ListenerThread.FreeOnTerminate := False;
  ListenerThread.Suspended := False;
end;

function TLccEthernetServer.CreateListenerObject(AConnectionInfo: TLccEthernetConnectionInfo): TLccEthernetListener;
begin
  Result := TLccEthernetListener.Create(True, Self, AConnectionInfo);
end;

end.

