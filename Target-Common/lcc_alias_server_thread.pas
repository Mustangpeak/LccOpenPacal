unit lcc_alias_server_thread;


{$I ..\lcc_compilers.inc}

{$IFDEF LCC_FPC}
{$mode objfpc}{$H+}
{$ENDIF}

{.$DEFINE LOG_MAPPING}

interface

uses

  Classes,
  SysUtils,
  {$IFNDEF LCC_FPC}
    System.Types,
    FMX.Types,
    System.Generics.Collections,
  {$ELSE}
  {$IFDEF LOG_MAPPING}lazlogger,{$ENDIF}
  {$ENDIF}

  {$IFDEF WEB_APP}
    generics.collections,
  {$ENDIF}
  lcc_defines,
  lcc_utilities,
  lcc_alias_server,
  lcc_node_messages;


const
  SLEEP_ALIAS_SERVER_THREAD_MS = 10;
  VERIFYNODE_RETRY_TIME_MS = 500;     // must be greater than SLEEP_ALIAS_SERVER_THREAD_MS
  VERIFYNODE_ABANDON_TIME_MS = 5000;  // must be greater than VERIFYNODE_RETRY_TIME_MS


type

TLccAliasServerDispatchProcessedMessageFunc = procedure(ALccMessage: TLccMessage) of object;

{ TReceiveMessageAliasServerThread }

TReceiveMessageAliasServerThread = class(TThread)
  private
    FMappingRequestMessageList: TThreadList;                                         // Storage for messages that still require Alias mapping of nodes referenced in the message (source, destination, payload NodeIDs, etc)
    FOutgoingProcessedMessageList: TThreadList;                                      // Holds the messages that are fully processed LCC messages ready to be sent via DispatchProcessedMessageCallback
    FIncomingMessageList: TThreadList;                                               // Incoming CAN messages that need to be processed to ensures all mappings are validated to the nodes it references (source, destination, payload NodeIDs, etc)                                    // Before the fully processed
    FReceiveMessageSource: TOnMessageEvent;
    FSendMessageCallback: TOnSendMessageEvent;
    FWaitingForMappingMessageList: TThreadList;
    FWorkerMessage: TLccMessage;
  protected
    // Messages coming in from the connections
    property IncomingMessageList: TThreadList read FIncomingMessageList write FIncomingMessageList;
    // Message waiting for the Mapping of any NodeID/AliasID that the message requires to be found in the AliasServer
    property WaitingForMappingMessageList: TThreadList read FWaitingForMappingMessageList write FWaitingForMappingMessageList;
    // Messages that have valid mappings and can be picked up by the Node Manager
    property OutgoingProcessedMessageList: TThreadList read FOutgoingProcessedMessageList;
    // Mapping Requests, TLccMessages filled in to request the mappings the Alias Server needs.. These need to picked up and sent by the Node Manager
    property MappingRequestMessageList: TThreadList read FMappingRequestMessageList write FMappingRequestMessageList;


    property WorkerMessage: TLccMessage read FWorkerMessage write FWorkerMessage;

    procedure Execute; override;
    procedure ClearThreadedObjectList(AThreadedList: TThreadList);
    procedure ProcessAliasAndNodeIDMappingMessages(AMessage: TLccMessage);
    procedure RequestMappingMessageSent(ANodeID: TNodeID; AnAliasID: Word);
    function MappingRequest(ANodeID: TNodeID; AnAliasID: Word): TLccMessage;
    procedure DispatchMessageThroughSyncronize;
    procedure SendMessageThroughSyncronize;

  public
    constructor Create(CreateSuspended: Boolean; const StackSize: SizeUInt = DefaultStackSize); reintroduce;
    destructor Destroy; override;

    // This property is set to a function that will send a Message to the network, current calls into TLccNodeManager.SendMessage so it can pickup a node as the source to send the message
    property SendMessageCallback: TOnSendMessageEvent read FSendMessageCallback write FSendMessageCallback;
    // Adds a message that is incoming from a connection.  This thread will validate that the Alias Server contains
    // any mappings necessary for the message and place them in the OutgoingProcessedMessageList when Node Manager can handle them
    property ReceiveMessageSource: TOnMessageEvent read FReceiveMessageSource write FReceiveMessageSource;
    procedure AddIncomingLccMessage(AMessage: TLccMessage; GridConnect: Boolean);
  end;

var
  AliasServerThread: TReceiveMessageAliasServerThread;

implementation

uses
  lcc_common_classes;


{ TReceiveMessageAliasServerThread }

procedure TReceiveMessageAliasServerThread.Execute;
var
  List: TList;
  i: Integer;
  LocalMessage: TLccMessage;
begin

  while not Terminated do
  begin
    // Any of this will ONLY run if in during the AddIncomingMessage call it was defined as a GridConnect so
    // the assumption here is ONLY gridconnect with Alias's are here.

    List := IncomingMessageList.LockList;
    try
      for i := 0 to List.Count -1 do
      begin
        LocalMessage := TLccMessage( List[i]);
        // Process any mapping definition messages.  If they are mapping messages then we know the mapping exisits and can skip any more checking.
        ProcessAliasAndNodeIDMappingMessages(LocalMessage);

        // If it is a CAN message send it on, we don't try to map CAN messages since during Alias
        // reconciliation they must go through because the Alias is not valid yet and a CAN message only delivers
        // NodeIDs it never requires them to be used

        if not LocalMessage.IsCAN then
        begin
          if LocalMessage.ValidateAndRequestIfNecessaryAliasMappings({$IFNDEF LCC_DELPHI}@{$ENDIF}RequestMappingMessageSent) then
            OutgoingProcessedMessageList.Add(LocalMessage)
          else
            WaitingForMappingMessageList.Add(LocalMessage)
        end else
          OutgoingProcessedMessageList.Add(LocalMessage)

      end;
    finally
      List.Clear;
      IncomingMessageList.UnlockList;
    end;

    // See if any mapping messages have come in that clears an incoming message that was
    // placed in the waiting list because it was missing a mapping
    List := WaitingForMappingMessageList.LockList;
    try
      for i := 0 to List.Count -1 do
      begin
        LocalMessage := TLccMessage( List[i]);
        if LocalMessage.ValidateAndRequestIfNecessaryAliasMappings({$IFNDEF LCC_DELPHI}@{$ENDIF}RequestMappingMessageSent) then
        begin
          List[i] := nil;
          OutgoingProcessedMessageList.Add(LocalMessage);
        end;
      end;
    finally
      for i := List.Count - 1 downto 0 do
      begin
        if List[i] = nil then
          List.Delete(i);
      end;
      WaitingForMappingMessageList.UnlockList;
    end;

    Synchronize({$IFNDEF LCC_DELPHI}@{$ENDIF}DispatchMessageThroughSyncronize);

    Sleep(SLEEP_ALIAS_SERVER_THREAD_MS);
  end;
end;

procedure TReceiveMessageAliasServerThread.ClearThreadedObjectList(
  AThreadedList: TThreadList);
var
  List: TList;
  i: Integer;
begin
  List := AThreadedList.LockList;
  try
    for i := 0 to List.Count - 1 do
      TObject( List[i]).Free;
  finally
    List.Clear;
    AThreadedList.UnlockList;
  end;
end;

procedure TReceiveMessageAliasServerThread.ProcessAliasAndNodeIDMappingMessages(
  AMessage: TLccMessage);
var
  DummyNodeID: TNodeID;
begin
  case AMessage.CAN_MTI of
    MTI_CAN_AMR :
      begin
        AliasServer.RemoveMapping(AMessage.SourceAlias, False);
      end;
    MTI_CAN_AMD :
      begin
        DummyNodeID := NULL_NODE_ID;
        AliasServer.AddMapping(AMessage.ExtractDataBytesAsNodeID(0, DummyNodeID), AMessage.SourceAlias, False);
      end;
    MTI_CAN_AME :
      begin
        if AMessage.DataCount = 0 then      // A global AME will repoplulate the entire database so this will flush invalid mappings as well since they won't respond anymore
          AliasServer.Clear(False);                // BUT be aware that the node sending this message will not be restored as it won't send out an AME message
      end;
  end;

  case AMessage.MTI of
    MTI_VERIFIED_NODE_ID_NUMBER,
    MTI_INITIALIZATION_COMPLETE :
      begin
        DummyNodeID := NULL_NODE_ID;
        AliasServer.AddMapping(AMessage.ExtractDataBytesAsNodeID(0, DummyNodeID), AMessage.SourceAlias, False);
      end;
    MTI_VERIFY_NODE_ID_NUMBER :
      begin
        if AMessage.DataCount = 0 then     // A global Verify Node ID will repoplulate the entire database so this will flush invalid mappings as well since they won't respond anymore
          AliasServer.Clear(False);               // BUT be aware that the node sending this message will not be restored as it won't send out an MTI_VERIFIED_NODE_ID_NUMBER message
      end;
  end;
end;

procedure TReceiveMessageAliasServerThread.RequestMappingMessageSent(ANodeID: TNodeID; AnAliasID: Word);
var
  LccMessage: TLccMessage;
  MappingRequestMessage: TLccMessage;
begin
  Assert(Assigned(SendMessageCallback), 'TReceiveMessageAliasServerThread,SendMessageCallback not assigned');

  // This mechinism does not work for trying to request mapping on internal virtual nodes as it
  // may be trying to send a message to itself to VerifyNode and we need to use the first Node as the source
  // The nodes Add and Removing mapping directly as they are created to simplify this


  // Don't send duplicate requests for mapping messages
  MappingRequestMessage := MappingRequest(ANodeID, AnAliasID);

  if AnAliasID <> 0 then   // If we have the Alias use the CAN messages to get the full Node ID
  begin
    if not Assigned(MappingRequestMessage) then
    begin
      LccMessage := TLccMessage.Create;
      LccMessage.LoadVerifyNodeIDAddressed(NULL_NODE_ID, 0, ANodeID, AnAliasID, NULL_NODE_ID);
      MappingRequestMessageList.Add(LccMessage);
      LccMessage.iTag := 1;
      LccMessage.CopyToTarget(WorkerMessage);
      Synchronize(@SendMessageThroughSyncronize);
    end else
    if MappingRequestMessage.iTag mod (VERIFYNODE_RETRY_TIME_MS div SLEEP_ALIAS_SERVER_THREAD_MS) = 0 then
    begin
      MappingRequestMessage.CopyToTarget(WorkerMessage);
      Synchronize(@SendMessageThroughSyncronize);
      MappingRequestMessage.iTag := MappingRequestMessage.iTag + 1;
    end else
    begin
      MappingRequestMessage.iTag := MappingRequestMessage.iTag + 1;
      if MappingRequestMessage.iTag > VERIFYNODE_ABANDON_TIME_MS then
      begin
        WaitingForMappingMessageList.Remove(MappingRequestMessage);
        MappingRequestMessage.Free;
      end;
    end;
  end else
  if not NullNodeID(ANodeID) then  // If we have the NodeID use it to send us the Alias
  begin
    if not Assigned(MappingRequestMessage) then
    begin
      LccMessage := TLccMessage.Create;
      LccMessage.LoadVerifyNodeID(NULL_NODE_ID, 0, ANodeID);
      MappingRequestMessageList.Add(LccMessage);
      LccMessage.iTag := 1;
      LccMessage.CopyToTarget(WorkerMessage);
      Synchronize(@SendMessageThroughSyncronize);
    end else
    if MappingRequestMessage.iTag mod VERIFYNODE_RETRY_TIME_MS div SLEEP_ALIAS_SERVER_THREAD_MS = 0 then
    begin
      MappingRequestMessage.CopyToTarget(WorkerMessage);
      Synchronize(@SendMessageThroughSyncronize);
      MappingRequestMessage.iTag := MappingRequestMessage.iTag + 1;
    end else
    begin
      MappingRequestMessage.iTag := MappingRequestMessage.iTag + 1;
      if MappingRequestMessage.iTag > VERIFYNODE_ABANDON_TIME_MS then
      begin
        WaitingForMappingMessageList.Remove(MappingRequestMessage);
        MappingRequestMessage.Free;
      end;
    end;
  end else
  begin
    {$IFDEF LOG_MAPPING}DebugLn('Mapping Request requsted but failed: 0x' + IntToHex(AnAliasID, 4) + '; ' + NodeIDToString(ANodeID, True));{$ENDIF}
  end;
end;

function TReceiveMessageAliasServerThread.MappingRequest(ANodeID: TNodeID;
  AnAliasID: Word): TLccMessage;
var
  List: TList;
  i: Integer;
  LccMessage: TLccMessage;
begin
  Result := nil;
  List := MappingRequestMessageList.LockList;
  try
    for i := 0 to List.Count - 1 do
    begin
      LccMessage := TLccMessage( List[i]);
      if (LccMessage.DestAlias = AnAliasID) or EqualNodeID(ANodeID, LccMessage.DestID, False) then
      begin
        Result := LccMessage;
        Break;
      end;
    end;
  finally
    MappingRequestMessageList.UnlockList;
  end;
end;

procedure TReceiveMessageAliasServerThread.DispatchMessageThroughSyncronize;
var
  List: TList;
  i: Integer;
begin
  Assert( Assigned(ReceiveMessageSource), 'TReceiveMessageAliasServerThread,ReceiveMessageSource is not assigned');

  List := OutgoingProcessedMessageList.LockList;
  try
    try
      for i := 0 to List.Count - 1 do
      begin
        ReceiveMessageSource(TLccMessage( List[i]));
        TObject( List[i]).Free;
      end;
    finally
      List.Clear
    end;
  finally
    OutgoingProcessedMessageList.UnlockList;
  end;
end;

procedure TReceiveMessageAliasServerThread.SendMessageThroughSyncronize;
begin
  if Assigned(SendMessageCallback) then
    SendMessageCallback(WorkerMessage, True);
  {$IFDEF LOG_MAPPING}DebugLn('Mapping Request Sent via LoadVerifyNodeIDAddressed: 0x' + IntToHex(WorkerMessage.SourceAlias, 4) + '; ' + NodeIDToString(WorkerMessage.SourceID, True));{$ENDIF}
end;

constructor TReceiveMessageAliasServerThread.Create(CreateSuspended: Boolean; const StackSize: SizeUInt);
begin
  inherited Create(CreateSuspended, StackSize);
  FOutgoingProcessedMessageList := TThreadList.Create;
  FIncomingMessageList := TThreadList.Create;
  FWaitingForMappingMessageList := TThreadList.Create;
  FMappingRequestMessageList := TThreadList.Create;
  FWorkerMessage := TLccMessage.Create;
end;

destructor TReceiveMessageAliasServerThread.Destroy;
begin
  ClearThreadedObjectList(WaitingForMappingMessageList);
  ClearThreadedObjectList(OutgoingProcessedMessageList);
  ClearThreadedObjectList(IncomingMessageList);
  ClearThreadedObjectList(MappingRequestMessageList);
  FreeAndNil(FOutgoingProcessedMessageList);
  FreeAndNil(FIncomingMessageList);
  FreeAndNil(FWaitingForMappingMessageList);
  FreeAndNil(FMappingRequestMessageList);
  FreeAndNil(FWorkerMessage);
  inherited Destroy;
end;

procedure TReceiveMessageAliasServerThread.AddIncomingLccMessage(
  AMessage: TLccMessage; GridConnect: Boolean);
begin
  // No such thing as an Alias if not dealing with GridConnect
  if GridConnect then
    IncomingMessageList.Add(AMessage.Clone)
  else
    OutgoingProcessedMessageList.Add(AMessage.Clone);
end;

initialization
  AliasServerThread := TReceiveMessageAliasServerThread.Create(False);
  AliasServerThread.FreeOnTerminate := True;
  if Assigned(ConnectionFactory) then
    AliasServerThread.ReceiveMessageSource := @ConnectionFactory.ReceiveMessageSink;

finalization
  AliasServerThread.Terminate;


end.

