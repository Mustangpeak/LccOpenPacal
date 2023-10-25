﻿unit FormLccThrottleApp;

// TODO:
// Still hang on shutdown once in a while

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Gestures, System.Actions, FMX.ActnList, FMX.MultiView, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Layouts,
  System.Math.Vectors, FMX.Objects, FMX.Edit, FMX.Controls3D, FMX.Layers3D, System.IOUtils,
  FMX.Menus, FMX.Platform, FMX.ListBox, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.Header, FMX.EditBox, FMX.SpinBox, System.ImageList, FMX.ImgList,
  FMX.TreeView, FMX.Colors, FMX.Effects, FMX.SearchBox,
  lcc_node_manager,
  lcc_ethernet_server,
  lcc_ethernet_client,
  lcc_connection_common,
  lcc_node_controller,
  lcc_ethernet_common,
  lcc_defines,
  lcc_xmlutilities,
  lcc_utilities,
  lcc_node,
  lcc_node_messages,
  lcc_alias_server,
  lcc_cdi_xml_reader,
  lcc_protocol_utilities,
  Frame_LccNodeEditorControl,
  Frame_LccNodeEditorGroup,
  Frame_LccNodeEditor;

const
  FILENAME_SETTINGS = 'settings.xml';
  FILENAME_MEMORY_CONFIG = 'memconfig.xml';
  FOLDERNAME_APP = 'LccThrottleApp';
  DEFAULT_IP_ADDRESS = '192.168.0.35';
  DEFAULT_PORT = 12021;
  DEFAULT_NODE_ID = '02.02.04.05.0A.0B';

type

  TLccThrottleAppForm = class(TForm)
    TabControlMain: TTabControl;
    TabItemTrains: TTabItem;
    TabItemLog: TTabItem;
    ToolBarMain: TToolBar;
    lblTitleMain: TLabel;
    TabItem3: TTabItem;
    ToolBar4: TToolBar;
    lblTitle4: TLabel;
    TabItemSettings: TTabItem;
    ToolBarSettingsTop: TToolBar;
    LabelSettingsHeader: TLabel;
    GestureManager1: TGestureManager;
    ActionList1: TActionList;
    ActionTabMainNext: TNextTabAction;
    ActionTabMainPrev: TPreviousTabAction;
    MultiViewRoster: TMultiView;
    ListViewTrainRoster: TListView;
    SpeedButtonTrainsRoster: TSpeedButton;
    LayoutSettingsTab: TLayout;
    ButtonSettingsResetConnection: TButton;
    Layout3D1: TLayout3D;
    CheckBoxSettingsRawTCP: TCheckBox;
    EditSettingsNodeID: TEdit;
    TextSettingsNodeID: TText;
    TextSettingsPort: TText;
    EditSettingsPort: TEdit;
    EditSettingsIP: TEdit;
    TextSettingsIpAddress: TText;
    TimerLogin: TTimer;
    LabelSystemDocumentsPath: TLabel;
    PopupMenuLabelPath: TPopupMenu;
    MenuItemSettingsLabelPath: TMenuItem;
    TextSettingsConnectionStatus: TText;
    ButtonSettingsDeleteSettingsFile: TButton;
    ButtonSettingsDeleteAppFolder: TButton;
    LabelSettingsSystemDocumentsPathHeader: TLabel;
    LabeSettingslApplicationDocumentsHeader: TLabel;
    LabelSettingsApplicationDocumentsPath: TLabel;
    TextSettingsDebugHeader: TText;
    LayoutTrains: TLayout;
    TabControlTrainRoster: TTabControl;
    TabItemTrainRosterSelect: TTabItem;
    TabItemTrainRosterDetails: TTabItem;
    ListBoxTrainRosterItem: TListBox;
    ToolBarTrainRosterDetails: TToolBar;
    LabelTrainRosterHeader: TLabel;
    SpeedButtonTrainRosterBack: TSpeedButton;
    TabItemTrainRosterEdit: TTabItem;
    ToolBarTrainRosterEdit: TToolBar;
    LabelTrainRosterEdit: TLabel;
    SpeedButtonTrainRosterEdit: TSpeedButton;
    ActionTabTrainRosterNext: TNextTabAction;
    ActionTabTrainRosterPrev: TPreviousTabAction;
    LayoutLog: TLayout;
    MemoLog: TMemo;
    ListBoxGroupHeaderTrainDetails: TListBoxGroupHeader;
    ListBoxItemTrainsDetailsManufacturer: TListBoxItem;
    ListBoxItemTrainsDetailsModel: TListBoxItem;
    ListBoxItemTrainsDetailsSofwareVersion: TListBoxItem;
    ListBoxItemTrainsDetailsHardwareVersion: TListBoxItem;
    ListBoxItemTrainsDetailsUserName: TListBoxItem;
    ListBoxItemTrainsDetailsUserDescription: TListBoxItem;
    TextSettingsNodeAlias: TText;
    TextSettingsNodeAliasID: TText;
    ListBoxGroupHeaderConsists: TListBoxGroupHeader;
    ListBoxItemTrainsDetailsConsists: TListBoxItem;
    MultiViewConsists: TMultiView;
    TabControlTrainConsists: TTabControl;
    TabItemTrainConsists: TTabItem;
    TabItem2: TTabItem;
    LayoutConsistConsists: TLayout;
    LabelConsistConsists: TLabel;
    ToolBarConsistConsists: TToolBar;
    TreeViewConsistConsists: TTreeView;
    SpeedButtonTrainsConsist: TSpeedButton;
    LayoutTrainsThrottle: TLayout;
    VertScrollBoxFunctions: TVertScrollBox;
    ButtonF0: TButton;
    ButtonF19: TButton;
    ButtonF18: TButton;
    ButtonF17: TButton;
    ButtonF16: TButton;
    ButtonF15: TButton;
    ButtonF14: TButton;
    ButtonF13: TButton;
    ButtonF12: TButton;
    ButtonF11: TButton;
    ButtonF10: TButton;
    ButtonF1: TButton;
    ButtonF2: TButton;
    ButtonF3: TButton;
    ButtonF4: TButton;
    ButtonF5: TButton;
    ButtonF6: TButton;
    ButtonF7: TButton;
    ButtonF8: TButton;
    ButtonF9: TButton;
    LayoutTrainsThrottleLever: TLayout;
    TrackBarTrainsThrottleLever: TTrackBar;
    ButtonF20: TButton;
    ButtonF21: TButton;
    ButtonF22: TButton;
    ButtonF23: TButton;
    ButtonF24: TButton;
    ButtonF25: TButton;
    ButtonF26: TButton;
    ButtonF27: TButton;
    Layout1: TLayout;
    SpeedButtonTrainsRev: TSpeedButton;
    SpeedButtonTrainsFwd: TSpeedButton;
    SpeedButtonTrainsStop: TSpeedButton;
    LayoutTrainsThrottleLeverBkgnd: TLayout;
    LayoutTrainsThrottleInfo: TLayout;
    LabelTrainsSpeedHeader: TLabel;
    LabelTrainsSpeed: TLabel;
    LabelTrainRosterEditContainer: TLabel;
    ToolBarLog: TToolBar;
    SpeedButtonLogClear: TSpeedButton;
    SpeedButtonLogEnable: TSpeedButton;
    LabelErrorMsg: TText;
    lbStatus: TLabel;
    procedure GestureDone(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure TimerLoginTimer(Sender: TObject);
    procedure ButtonSettingsResetConnectionClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItemSettingsLabelPathClick(Sender: TObject);
    procedure EditSettingsIPKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditSettingsPortKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditSettingsNodeIDKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditSettingsIPExit(Sender: TObject);
    procedure EditSettingsPortExit(Sender: TObject);
    procedure EditSettingsNodeIDExit(Sender: TObject);
    procedure ButtonSettingsDeleteSettingsFileClick(Sender: TObject);
    procedure ButtonSettingsDeleteAppFolderClick(Sender: TObject);
    procedure SpeedButtonTrainRosterBackClick(Sender: TObject);
    procedure ListViewTrainRosterItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure ListBoxItemTrainsDetailsUserNameClick(Sender: TObject);
    procedure ListBoxItemTrainsDetailsUserDescriptionClick(Sender: TObject);
    procedure ButtonFnClick(Sender: TObject);
    procedure SpeedButtonTrainsFwdClick(Sender: TObject);
    procedure SpeedButtonTrainsRevClick(Sender: TObject);
    procedure TrackBarTrainsThrottleLeverChange(Sender: TObject);
    procedure SpeedButtonTrainsStopClick(Sender: TObject);
    procedure SpeedButtonLogClearClick(Sender: TObject);
    procedure ListViewTrainRosterSearchChange(Sender: TObject);
    procedure MultiViewRosterStartShowing(Sender: TObject);
  private
    FNodeManager: TLccNodeManager;
    FEthernetClient: TLccEthernetClientThreadManager;
    FControllerNode: TLccTrainController;
    FConnectionState: TLccConnectionState;
    FShownOnce: Boolean;
    FClipboard: IFMXClipboardService;
    FCurrentNodeID: TNodeID;
    FCurrentPort: Word;
    FCurrentIpAddress: string;
    FPathSettingsFile: string;
    FPathApplicationFiles: string;
    FPathMemoryConfig: string;
    FCdiData: TLccCdiRoot;
    FNodeEditor: TFrameNodeEditorControl;
    FEmulateCanBus: Boolean;
    FTrainInfo: TTrainInfo;
    { Private declarations }

  protected

    property EmulateCanBus: Boolean read FEmulateCanBus write FEmulateCanBus;

    procedure XmlLoadSettingsFromFile;
    procedure XmlWriteDefaultFile;
    procedure BuildNodeEditor;

  public
    { Public declarations }
    property EthernetClient: TLccEthernetClientThreadManager read FEthernetClient write FEthernetClient;
    property NodeManager: TLccNodeManager read FNodeManager write FNodeManager;
    property Controller: TLccTrainController read FControllerNode write FControllerNode;
    property ConnectionState: TLccConnectionState read FConnectionState write FConnectionState;
    property ShownOnce: Boolean read FShownOnce;
    property Clipboard: IFMXClipboardService read FClipboard write FClipboard;
    property CurrentIpAddress: string read FCurrentIpAddress write FCurrentIpAddress;
    property CurrentPort: Word read FCurrentPort write FCurrentPort;
    property CurrentNodeID: TNodeID read FCurrentNodeID write FCurrentNodeID;
    property PathApplicationFiles: string read FPathApplicationFiles write FPathApplicationFiles;
    property PathSettingsFile: string read FPathSettingsFile write FPathSettingsFile;
    property PathMemoryConfig: string read FPathMemoryConfig write FPathMemoryConfig;
    property CdiData: TLccCdiRoot read FCdiData write FCdiData;
    property NodeEditor: TFrameNodeEditorControl read FNodeEditor write FNodeEditor;
    property TrainInfo: TTrainInfo read FTrainInfo write FTrainInfo;

    // Callbacks
    procedure OnNodeLogin(Sender: TObject; LccSourceNode: TLccNode);
    procedure OnAliasMappingChange(Sender: TObject; LccSourceNode: TLccNode; AnAliasMapping: TLccAliasMapping; IsMapped: Boolean);

    procedure CallbackSearchByDccAddress(ATask: TLccTaskBase); // TLccTaskSearchTrain
    procedure CallbackAssignToTrain(ATask: TLccTaskBase);      // TLccTaskControllerAttach
    procedure CallbackQueryTrain(ATask: TLccTaskBase);         // TLccTaskControllerQuery

    procedure CallbackSnip(ATask: TLccTaskBase);               // TTaskReadSNIP
    procedure CallbackPip(ATask: TLccTaskBase);                // TTaskReadPIP

    procedure CallbackQuerySpeedDir(ATask: TLccTaskBase);      // TLccTaskQuerySpeed
    procedure CallbackQueryFunction(ATask: TLccTaskBase);     // TLccTaskQueryFunction

    procedure CallbackTrainRosterNotify(ATask: TLccTaskBase);      // TLccTaskTrainRoster

     procedure CallbackCdi(ATask: TLccTaskBase);                // TLccTaskMemorySpaceAccess

    procedure OnConnectionConnectionState(Sender: TObject; Manager: TLccConnectionThreadManager; Thread: TLccConnectionThread; Info: TLccConnectionInfo);
    procedure OnConnectionErrorMessage(Sender: TObject; Manager: TLccConnectionThreadManager; Thread: TLccConnectionThread; Info: TLccConnectionInfo);
    procedure OnConnectionManagerReceiveMessage(Sender: TObject; ALccMessage: TLccMessage);
    procedure OnConnectionManagerSendMessage(Sender: TObject; ALccMessage: TLccMessage);

    procedure OnNodeIDChanged(Sender: TObject; ALccNode: TLccNode);
    procedure OnNodeAliasChanged(Sender: TObject; ALccNode: TLccNode);

    function ValidEditBoxKey(Key: Word): Boolean;
    function FindListviewItemByTagTractionObject(AListview: TListView; ATagObject: TObject): TListviewItem;
    function SelectedRosterEqualsTractionObject(ATrain: TTrainInfo): Boolean;
    procedure TrainTabDetailsClear;
    procedure TrainTabDetailsLoad(ATrainInfo: TTrainInfo);
    procedure TrainTabCDIClear;
    procedure TrainTabCDILoad(ATrainInfo: TTrainInfo);
    procedure TrainTabCDISelect;
    procedure RenderCDI(ATrainInfo: TTrainInfo);
    procedure SelectTrain(AnAddress: String; HideMultiView: Boolean);


    function IsTrainAssigned: Boolean;
  end;

var
  LccThrottleAppForm: TLccThrottleAppForm;

implementation

{$R *.fmx}

procedure TLccThrottleAppForm.EditSettingsIPExit(Sender: TObject);
begin
  if ValidateIPString(EditSettingsIp.Text) then
    XmlNodeSetFirstLevelTextContent(PathSettingsFile, 'settings', 'ipaddress', EditSettingsIp.Text, True);
end;

procedure TLccThrottleAppForm.EditSettingsIPKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if not( CharInSet(KeyChar, ['0'..'9', '.']) or ValidEditBoxKey(Key) ) then
  begin
    Key := 0;
    KeyChar := #0;
  end;
  if (Key = vkReturn) and ValidateIPString(EditSettingsIp.Text) then
    XmlNodeSetFirstLevelTextContent(PathSettingsFile, 'settings', 'ipaddress', EditSettingsIp.Text, True);
end;

procedure TLccThrottleAppForm.EditSettingsNodeIDExit(Sender: TObject);
begin
  if ValidateNodeIDString(EditSettingsNodeID.Text) then
    XmlNodeSetFirstLevelTextContent(PathSettingsFile, 'settings', 'nodeid', EditSettingsNodeID.Text, True);
end;

procedure TLccThrottleAppForm.EditSettingsNodeIDKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if CharInSet(KeyChar, ['a'..'f']) then
   KeyChar := UpCase(KeyChar);

  if not( CharInSet(KeyChar, ['0'..'9', 'A'..'F', '.']) or ValidEditBoxKey(Key) ) then
  begin
    Key := 0;
    KeyChar := #0;
  end;

  if (Key = vkReturn) and ValidateNodeIDString(EditSettingsNodeID.Text) then
    XmlNodeSetFirstLevelTextContent(PathSettingsFile, 'settings', 'nodeid', EditSettingsNodeID.Text, True);
end;

procedure TLccThrottleAppForm.EditSettingsPortExit(Sender: TObject);
begin
  if ValidatePort(EditSettingsPort.Text) then
    XmlNodeSetFirstLevelTextContent(PathSettingsFile, 'settings', 'port', EditSettingsPort.Text, True);
end;

procedure TLccThrottleAppForm.EditSettingsPortKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if not( CharInSet(KeyChar, ['0'..'9']) or ValidEditBoxKey(Key) ) then
  begin
    Key := 0;
    KeyChar := #0;
  end;
  if (Key = vkReturn) and ValidatePort(EditSettingsPort.Text) then
    XmlNodeSetFirstLevelTextContent(PathSettingsFile, 'settings', 'port', EditSettingsPort.Text, True);
end;

procedure TLccThrottleAppForm.BuildNodeEditor;
var
  i: Integer;
  ChildCdiNode: TLccCidCore;
  Group: TFrameLccNodeEditorGroup;
begin
  NodeEditor.Visible := True;
  for i := 0 to CdiData.ChildElementCount - 1 do
  begin
    ChildCdiNode := CdiData.ChildElement[i];
    if ChildCdiNode is TLccCdiSegment then
    begin
      Group := NodeEditor.RootGroup.AddSubGroup(NodeEditor, NodeEditor.RootGroup, ChildCdiNode.Name, ChildCdiNode.Description, True);
      Group.TagObject := ChildCdiNode;

   //   RunNode(CDI.ChildElement[i], 1);
    end else
    if ChildCdiNode is TLccCdiAcdi then
    begin
    end else
    if ChildCdiNode is TLccCdiIdentification then
    begin
    end;
  end;
end;

procedure TLccThrottleAppForm.ButtonFnClick(Sender: TObject);
begin
  if Assigned(Controller) and IsTrainAssigned then
    Controller.SetFunction(TrainInfo.NodeID, (Sender as TButton).Tag, Word( (Sender as TButton).IsPressed));
end;

procedure TLccThrottleAppForm.ButtonSettingsDeleteAppFolderClick(Sender: TObject);
var
  Files: TStringDynArray;
  i: Integer;
begin
  if TDirectory.Exists(PathApplicationFiles) then
  begin
    Files := TDirectory.GetFiles(PathApplicationFiles);
    for i  := 0 to Length(Files) - 1 do
      TFile.Delete(Files[i]);
    TDirectory.Delete(PathApplicationFiles)
  end;
end;

procedure TLccThrottleAppForm.ButtonSettingsDeleteSettingsFileClick(Sender: TObject);
begin
  if TFile.Exists(PathSettingsFile) then
    TFile.Delete(PathSettingsFile)
end;

procedure TLccThrottleAppForm.ButtonSettingsResetConnectionClick(Sender: TObject);
var
  ConnectionInfo: TLccEthernetConnectionInfo;
  LocalPort: LongInt;
  LocalPortStr: String;
  LocalIPStr: String;
  LocalNodeIDStr: String;
begin

  if EditSettingsNodeID.Text = '' then
    EditSettingsNodeID.Text := '08.09.0A.0B.0C.0D';

  LocalPortStr := EditSettingsPort.Text;
  LocalIPStr := EditSettingsIP.Text;
  LocalNodeIDStr := EditSettingsNodeID.Text;

  LabelErrorMsg.Text := '';

  if TryStrToInt(LocalPortStr, LocalPort) then
  begin
    if ValidateIPString(LocalIPStr) then
    begin
      if ValidateNodeIDString(LocalNodeIDStr) then
      begin
        ConnectionInfo := TLccEthernetConnectionInfo.Create;
        ConnectionFactory.DestroyConnection(EthernetClient);
        ConnectionInfo.ListenerIP := LocalIPStr;
        ConnectionInfo.ListenerPort := LocalPort;
        ConnectionInfo.SuppressErrorMessages := False;
        EthernetClient := ConnectionFactory.CreateLccMessageConnection(TLccEthernetClientThreadManager, ConnectionInfo, EmulateCanBus) as TLccEthernetClientThreadManager;
        EthernetClient.OpenConnection;
      end else
        LabelErrorMsg.Text := 'Invalid NodeID: ' + LocalNodeIDStr;
    end else
      LabelErrorMsg.Text := 'Invalid Ip address: ' + LocalIPStr;
  end else
    LabelErrorMsg.Text := 'Invalid Port number: ' + LocalPortStr;
end;

procedure TLccThrottleAppForm.CallbackAssignToTrain(ATask: TLccTaskBase);
var
  LocalTask: TLccTaskControllerAttach;
  Mapping: TLccAliasMapping;
  i: Integer;
begin
  LocalTask := ATask as TLccTaskControllerAttach;

  Mapping := AliasServer.FindMapping(LocalTask.Target);
  if Assigned(Mapping) then
  begin
    case ATask.TaskState of
      lesComplete :
        begin
          TrainInfo.NodeID := LocalTask.Target;

          // Do UI Updates

    //      EnableControls(True);

          lbStatus.Text := 'Requesting Train Info...';
          Controller.RequestSNIP(TrainInfo.NodeID, CallbackSnip);
          Controller.RequestPIP(TrainInfo.NodeID, CallbackPIP);
          Controller.QuerySpeedDir(TrainInfo.NodeID, CallbackQuerySpeedDir);
          for i := 0 to MAX_FUNCTIONS - 1 do
            Controller.QueryFunction(TrainInfo.NodeID, i, CallbackQueryFunction);
      //    Controller.RequestCDI(TrainInfo.NodeID, @CallbackCDI);


        end;
      lesAbort : ShowMessage('Assigned to Train: Aborted');
      lesRunning : ShowMessage('Assigned to Train: Running: (In progress updates here');
      lesTimeout : ShowMessage('Assigned to Train: Timed out unsuccessful (no reply?)');
      lesError : ShowMessage('Error: Code: ' + IntToStr(ATask.ErrorCode) + ' ' + ATask.ErrorMessage);
      lesIdle : ShowMessage('Idle: This should not have happended');
    end;
  end;
end;

procedure TLccThrottleAppForm.CallbackCdi(ATask: TLccTaskBase);
var
  CDI: TLccTaskMemorySpaceAccess;
  TrainInfo: TTrainInfo;
begin
  CDI := ATask as TLccTaskMemorySpaceAccess;

  case ATask.TaskState of
    lesComplete :
      begin
    //    CDI.CopyTo(TrainInfo.CDI);
        lbStatus.Text := IntToStr(CDI.AddressCurrent) + ' of ' + IntToStr(CDI.AddressHi-CDI.AddressLo) + ' bytes';
        if CDI.Valid then
        begin
          TrainInfo := ListViewTrainRoster.Selected.TagObject as TTrainInfo;
          CDI.CopyTo(TrainInfo.CDI);
          RenderCDI(TrainInfo);
        end;
      end;
    lesRunning :
      begin  // Update of progress
        lbStatus.Text := IntToStr(CDI.AddressCurrent) + ' of ' + IntToStr(CDI.AddressHi-CDI.AddressLo) + ' bytes';
      end;
    lesAbort,
    lesTimeout,
    lesError :
      begin
        Caption := 'CallbackCdi: Abort/Timeout/Error';
      end;
    lesIdle : ShowMessage('CallbackCdi Idle: This should not have happended');
  end;
end;

procedure TLccThrottleAppForm.CallbackPip(ATask: TLccTaskBase);
var
  PIP: TTaskReadPIP;
begin
  PIP := ATask as TTaskReadPIP;

  case ATask.TaskState of
    lesComplete :
      begin
        PIP.SupportedProtocols.CopyTo(TrainInfo.PIP);
      end;
    lesAbort : ShowMessage('CallbackSnip: Aborted');
    lesRunning : ShowMessage('CallbackSnip: Running: (In progress updates here');
    lesTimeout : ShowMessage('CallbackSnip: Timed out unsuccessful (no reply?)');
    lesError : ShowMessage('Error: Code: ' + IntToStr(ATask.ErrorCode) + ' ' + ATask.ErrorMessage);
    lesIdle : ShowMessage('CallbackSnip Idle: This should not have happended');
  end;
end;

procedure TLccThrottleAppForm.CallbackQueryFunction(ATask: TLccTaskBase);
var
  QueryFunction: TLccTaskQueryFunction;
  FunctionBox: TButton;
  OldOnChange: TNotifyEvent;
begin
  QueryFunction := ATask as TLccTaskQueryFunction;
  FunctionBox := FindComponent('ButtonF' + IntToStr(QueryFunction.Address)) as TButton;
  if Assigned(FunctionBox) then
  begin
    OldOnChange := FunctionBox.OnClick;
    FunctionBox.OnClick := nil;
    try
      if QueryFunction.ValueReply = 0 then
        FunctionBox.IsPressed := False
      else
        FunctionBox.IsPressed := True;
    finally
      FunctionBox.OnClick := OldOnChange;
    end;
  end;
end;

procedure TLccThrottleAppForm.CallbackQuerySpeedDir(ATask: TLccTaskBase);
var
  QuerySpeed: TLccTaskQuerySpeed;
  OldOnChange: TNotifyEvent;
begin
  QuerySpeed := ATask as TLccTaskQuerySpeed;

  // Trackbar is upside down
  OldOnChange := TrackBarTrainsThrottleLever.OnClick;
  TrackBarTrainsThrottleLever.OnClick := nil;
  try
  TrackBarTrainsThrottleLever.Value := 100 - Abs(QuerySpeed.SetSpeedReply);
  finally
    TrackBarTrainsThrottleLever.OnClick := OldOnChange;
  end;

  SpeedButtonTrainsRev.IsPressed := QuerySpeed.CommandedSpeedReply < 0;
end;

procedure TLccThrottleAppForm.CallbackQueryTrain(ATask: TLccTaskBase);
begin

end;

procedure TLccThrottleAppForm.CallbackSearchByDccAddress(ATask: TLccTaskBase);
var
  LocalTask: TLccTaskSearchTrain;
  Mapping: TLccAliasMapping;
begin
  LocalTask := ATask as TLccTaskSearchTrain;

  Mapping := AliasServer.FindMapping(LocalTAsk.TrainNodeIDReply);
  if Assigned(Mapping) then
  begin
    case ATask.TaskState of
      lesComplete :
        begin
          TrainInfo.NodeID := LocalTask.TrainNodeIDReply;
          Controller.ControllerAssign(TrainInfo.NodeID, CallbackAssignToTrain);
          lbStatus.Text := 'Assigning Controller to: ' + lblTitleMain.Text;
        end;
      lesAbort : ShowMessage('Search for Train: Aborted');
      lesRunning : ShowMessage('Search for Train: Running: (In progress updates here');
      lesTimeout : ShowMessage('Search for Train: Timed out unsuccessful (no reply?)');
      lesError : ShowMessage('Error: Code: ' + IntToStr(ATask.ErrorCode) + ' ' + ATask.ErrorMessage);
      lesIdle : ShowMessage('Idle: This should not have happended');
    end;
  end;
end;

procedure TLccThrottleAppForm.CallbackSnip(ATask: TLccTaskBase);
var
  SNIP: TTaskReadSNIP;
begin
  SNIP := ATask as TTaskReadSNIP;
  case ATask.TaskState of
    lesComplete :
      begin
        Caption := 'Train: ' + SNIP.SimpleNodeInfo.UserName;
        SNIP.SimpleNodeInfo.CopyTo(TrainInfo.SNIP);
      end;
    lesAbort : ShowMessage('CallbackSnip: Aborted');
    lesRunning : ShowMessage('CallbackSnip: Running: (In progress updates here');
    lesTimeout : ShowMessage('CallbackSnip: Timed out unsuccessful (no reply?)');
    lesIdle : ShowMessage('CallbackSnip Idle: This should not have happended');
    lesError : ShowMessage('Error: Code: ' + IntToStr(ATask.ErrorCode) + ' ' + ATask.ErrorMessage);
  end;
end;

procedure TLccThrottleAppForm.CallbackTrainRosterNotify(ATask: TLccTaskBase);



  function FindNode(ANodeID: TNodeID): TListViewItem;
  var
    i: Integer;
  begin
    Result := nil;
    for i := 0 to ListViewTrainRoster.Items.UnfilteredItems.Count - 1 do
    begin
      if EqualNodeID( TTrainInfo( ListViewTrainRoster.Items.UnfilteredItems[i].TagObject).NodeID, ANodeID, False) then
      begin
        Result := ListViewTrainRoster.Items[i];
        Break
      end;
    end;
  end;

var
  Roster: TLccTaskTrainRoster;
  i: Integer;
  TrainInfo: TTrainInfo;
  Node: TListviewItem;
begin
  Roster := ATask as TLccTaskTrainRoster;

  ListViewTrainRoster.BeginUpdate;
  try

    for i := 0 to Roster.Count - 1 do
    begin
      Node := FindNode( Roster.Train[i].NodeID);
      if not Assigned(Node) then
      begin
        Node := ListViewTrainRoster.Items.Add;
        TrainInfo := TTrainInfo.Create;
        TrainInfo.NodeID := Roster.Train[i].NodeID;
        Node.TagObject := TrainInfo;
      end else
        TrainInfo := Roster.Train[i];

      Roster.Train[i].SNIP.CopyTo(TrainInfo.SNIP);
      Roster.Train[i].PIP.CopyTo(TrainInfo.PIP);
      Node.Text := TrainInfo.SNIP.UserName;
    end;
  finally
    ListViewTrainRoster.EndUpdate
  end;
end;

function TLccThrottleAppForm.FindListviewItemByTagTractionObject(AListview: TListView; ATagObject: TObject): TListviewItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to AListview.Items.UnfilteredItems.Count - 1 do
  begin
    if AListview.Items.UnfilteredItems[i].TagObject = ATagObject then
    begin
      Result := AListview.Items.UnfilteredItems[i] as TListviewItem;
      Break
    end;
  end;
end;

procedure TLccThrottleAppForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  TrainTabCDIClear;
  TimerLogin.Enabled := False; // Stop trying to log in
  ConnectionFactory.DestroyConnection(EthernetClient);
  EthernetClient := nil;
  NodeManager.ReleaseAliasAll;
end;

procedure TLccThrottleAppForm.FormCreate(Sender: TObject);
begin
  // Local field setup
  EmulateCanBus := True;

  TrainInfo := TTrainInfo.Create;

  FCdiData := TLccCdiRoot.Create(nil);

  // Lcc library setup
  FNodeManager := TLccNodeManager.Create(nil);
  NodeManager.OnNodeAliasIDChanged := OnNodeAliasChanged;
  NodeManager.OnNodeIDChanged := OnNodeIdChanged;
  NodeManager.OnNodeLogin := OnNodeLogin;
  NodeManager.EmulateCanNetworkLogin := EmulateCanBus;

  FNodeEditor := TFrameNodeEditorControl.Create(Self);
  NodeEditor.Align := TAlignLayout.Client;
  NodeEditor.Parent := LabelTrainRosterEditContainer;
  NodeEditor.Visible := False;

  ConnectionFactory.OnStateChange := OnConnectionConnectionState;
  ConnectionFactory.OnError := OnConnectionErrorMessage;
  ConnectionFactory.OnLccMessageReceive := OnConnectionManagerReceiveMessage;
  ConnectionFactory.OnLccMessageSend := OnConnectionManagerSendMessage;


  // Default values to the settings
  CurrentIpAddress := DEFAULT_IP_ADDRESS;
  CurrentPort := DEFAULT_PORT;
  CurrentNodeID := StrToNodeID( DEFAULT_NODE_ID, True);

  // Default Paths for files

 {

 PathApplicationFiles := TPath.GetDocumentsPath;
 if DirectoryExists(PathApplicationFiles) then
 begin
   if CreateDir(TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP) then
   begin
     beep;
   end;
 end;

 if DirectoryExists(TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP) then
 begin
   beep;
 end;

 if FileExists(TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP + TPath.DirectorySeparatorChar + FILENAME_SETTINGS) then
 begin
   if DeleteFile(TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP + TPath.DirectorySeparatorChar + FILENAME_SETTINGS) then
   begin
     beep;
   end;
 end;

 if FileExists(TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP + TPath.DirectorySeparatorChar + FILENAME_MEMORY_CONFIG) then
 begin
   if DeleteFile(TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP + TPath.DirectorySeparatorChar + FILENAME_MEMORY_CONFIG) then
   begin
     beep;
   end;
 end;
           }

  PathApplicationFiles := TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP;
  PathSettingsFile := TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP + TPath.DirectorySeparatorChar + FILENAME_SETTINGS;
  PathMemoryConfig := TPath.GetDocumentsPath + TPath.DirectorySeparatorChar + FOLDERNAME_APP + TPath.DirectorySeparatorChar + FILENAME_MEMORY_CONFIG;
end;

procedure TLccThrottleAppForm.FormDestroy(Sender: TObject);
begin
  NodeManager.ReleaseAliasAll;
  FreeAndNil(FEthernetClient);
  FreeAndNil(FNodeManager);
  FreeAndNil(FCdiData);
  FreeAndNil(FTrainInfo);
end;

procedure TLccThrottleAppForm.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
 //   if (TabControl1.ActiveTab = TabItem1) and (TabControl2.ActiveTab = TabItem6) then
 //   begin
 //     TabControl2.Previous;
 //     Key := 0;
 //   end;
  end;
end;

procedure TLccThrottleAppForm.FormShow(Sender: TObject);
begin
  if not ShownOnce then
  begin
    FShownOnce := True;

    // Setup common variables to use
    TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, FClipboard);
    LabelSystemDocumentsPath.Text := TPath.GetDocumentsPath;
    LabelSettingsApplicationDocumentsPath.Text := PathApplicationFiles;

    // Setup components to a standard state in case forgotten in the designer
    TabControlMain.ActiveTab := TabItemTrains;    // This defines the default active tab at runtime
    MultiViewRoster.Mode := TMultiViewMode.Drawer;
    MultiViewRoster.Width := 300;
    MultiViewConsists.Mode := TMultiViewMode.Drawer;
    TabControlTrainRoster.ActiveTab := TabItemTrainRosterSelect;
    TimerLogin.Enabled := True; // Try to connect

    if FileExists(PathSettingsFile) then
      XmlLoadSettingsFromFile
    else
      XmlWriteDefaultFile;

    EditSettingsIp.Text := CurrentIpAddress;
    EditSettingsPort.Text := IntToStr( CurrentPort);
    EditSettingsNodeID.Text := NodeIDToString(CurrentNodeID, True);

    TabControlTrainRoster.TabPosition := TTabPosition.None;

    ButtonSettingsResetConnectionClick(Self)
  end;
end;

procedure TLccThrottleAppForm.GestureDone(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  case EventInfo.GestureID of
    sgiLeft:
      begin
        if TabControlMain.ActiveTab <> TabControlMain.Tabs[TabControlMain.TabCount - 1] then
          TabControlMain.ActiveTab := TabControlMain.Tabs[TabControlMain.TabIndex + 1];
        Handled := True;
      end;

    sgiRight:
      begin
        if TabControlMain.ActiveTab <> TabControlMain.Tabs[0] then
          TabControlMain.ActiveTab := TabControlMain.Tabs[TabControlMain.TabIndex - 1];
        Handled := True;
      end;
  end;
end;

function TLccThrottleAppForm.IsTrainAssigned: Boolean;
begin
  Result := not EqualNodeID(TrainInfo.NodeID, NULL_NODE_ID, False);
end;

procedure TLccThrottleAppForm.ListBoxItemTrainsDetailsUserDescriptionClick(Sender: TObject);
begin
  TrainTabCDISelect;
end;

procedure TLccThrottleAppForm.ListBoxItemTrainsDetailsUserNameClick(Sender: TObject);
begin
  TrainTabCDISelect;
end;


procedure TLccThrottleAppForm.ListViewTrainRosterItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
var
  TrainInfo: TTrainInfo;
begin
  TrainInfo := ListViewTrainRoster.Items[ItemIndex].TagObject as TTrainInfo;

  // Did we click on the Accessory to move to the Details tab?
  if ItemObject is TListItemAccessory then
  begin
    // Move to the Details tab
    ActionTabTrainRosterNext.Execute;

    // Reset the CDI Tab
    TrainTabCDIClear;

    // Need to load the information into that tab if we can.  If not we need to call for it
    if TrainInfo.SNIP.Valid then
    begin
      TrainTabDetailsLoad(TrainInfo);
    end else
    begin
      // Clear the details so they are not stale from a previous load
      TrainTabDetailsClear;
    //  Controller.SendSNIPRequest(TractionObject.NodeID, TractionObject.NodeAlias)
    end;

  //  if not TrainInfo.CDI then
    begin
      Controller.RequestCDI(TrainInfo.NodeID, CallbackCdi);
    end;

  end else
  begin
    SelectTrain(TrainInfo.SNIP.UserName, True);
  end;
end;

procedure TLccThrottleAppForm.ListViewTrainRosterSearchChange(Sender: TObject);
var
  I: Integer;
  SearchBox: TSearchBox;
  List: TListView;
begin
  SearchBox := nil;
  List := Sender as TListView;
  for I := 0 to List.Controls.Count-1 do
    if List.Controls[I].ClassType = TSearchBox then
    begin
      SearchBox := TSearchBox(List.Controls[I]);
      Break;
    end;

  if Assigned(Controller) and Assigned(SearchBox) then
  begin
    SelectTrain(SearchBox.Text, True);
    SearchBox.Text := '';
  end;
end;

procedure TLccThrottleAppForm.MenuItemSettingsLabelPathClick(Sender: TObject);
begin
  if Assigned(Clipboard) then
    Clipboard.SetClipboard(LabelSystemDocumentsPath.Text)
end;

procedure TLccThrottleAppForm.MultiViewRosterStartShowing(Sender: TObject);
begin
  MultiViewRoster.Width := ClientWidth
end;

procedure TLccThrottleAppForm.OnAliasMappingChange(Sender: TObject; LccSourceNode: TLccNode; AnAliasMapping: TLccAliasMapping; IsMapped: Boolean);
begin

end;

procedure TLccThrottleAppForm.OnConnectionConnectionState(Sender: TObject;
  Manager: TLccConnectionThreadManager; Thread: TLccConnectionThread;
  Info: TLccConnectionInfo);
begin
  if Manager = EthernetClient then
  begin

    case TLccEthernetConnectionInfo(Info).ConnectionState of
      lcsDisconnected :
        begin
          TextSettingsConnectionStatus.Text := 'Waiting for Connection';
        end;
      lcsConnecting :
        begin
          TextSettingsConnectionStatus.Text := 'Connecting';
        end;
      lcsConnected :
        begin
          TextSettingsConnectionStatus.Text := 'Connected';
          if NodeManager.Nodes.Count = 0 then
          begin
            Controller := NodeManager.AddNodeByClass('', TLccTrainController, True, NULL_NODE_ID) as TLccTrainController;
            Controller.TrainRoster.Callback := CallbackTrainRosterNotify;
            Controller.FindAllTrains;
          end;
        end;
      lcsDisconnecting :
        begin
          TextSettingsConnectionStatus.Text := 'Disconnecting';
        end;
    end;
  end;
end;

procedure TLccThrottleAppForm.OnConnectionErrorMessage(Sender: TObject;
  Manager: TLccConnectionThreadManager; Thread: TLccConnectionThread;
  Info: TLccConnectionInfo);
begin
  TextSettingsConnectionStatus.Text := Info.ErrorMessage;
  TimerLogin.Interval := 500;  // Fire immediatly once this Syncronize call returns
end;

procedure TLccThrottleAppForm.OnConnectionManagerReceiveMessage(Sender: TObject; ALccMessage: TLccMessage);
begin
   if SpeedButtonLogEnable.IsPressed then
  begin
    MemoLog.Lines.BeginUpdate;
    try
      MemoLog.Lines.Add('R: ' + MessageToDetailedMessage(ALccMessage))
    finally
      MemoLog.Lines.EndUpdate;
    end;
  end;
end;

procedure TLccThrottleAppForm.OnConnectionManagerSendMessage(Sender: TObject; ALccMessage: TLccMessage);
begin
  if SpeedButtonLogEnable.IsPressed then
  begin
    MemoLog.Lines.BeginUpdate;
    try
      MemoLog.Lines.Add('S: ' + MessageToDetailedMessage(ALccMessage))
    finally
      MemoLog.Lines.EndUpdate;
    end;
  end;
end;

procedure TLccThrottleAppForm.RenderCDI(ATrainInfo: TTrainInfo);
begin
  if ATrainInfo.CDI.Valid then
  begin
    CdiData.LoadFromCDI( ATrainInfo.CDI.StreamAsString);
    CdiData.SetTargetNode(ATrainInfo.NodeID, AliasServer.FindAlias(ATrainInfo.NodeID));
    CdiData.BuildTree(False);
    BuildNodeEditor;
  end;
end;

procedure TLccThrottleAppForm.OnNodeAliasChanged(Sender: TObject; ALccNode: TLccNode);
begin
  TextSettingsNodeAliasID.Text := ALccNode.AliasIDStr;
end;

procedure TLccThrottleAppForm.OnNodeIDChanged(Sender: TObject; ALccNode: TLccNode);
begin
  EditSettingsNodeID.Text := ALccNode.NodeIDStr[True]
end;

procedure TLccThrottleAppForm.OnNodeLogin(Sender: TObject; LccSourceNode: TLccNode);
begin

end;

function TLccThrottleAppForm.SelectedRosterEqualsTractionObject(ATrain: TTrainInfo): Boolean;
begin
  Result := False;
  if ListViewTrainRoster.Selected <> nil then
    Result := ListViewTrainRoster.Selected.TagObject = ATrain
end;

procedure TLccThrottleAppForm.SelectTrain(AnAddress: String; HideMultiView: Boolean);
begin
  Controller.SearchByDccAddress(AnAddress, True, TLccDccSpeedStep.ldssDefault, CallbackSearchByDccAddress);
  lbStatus.Text := 'Searching for Train: ' + QuotedStr(AnAddress) + '.';

  if HideMultiView then
    MultiViewRoster.HideMaster;
end;

procedure TLccThrottleAppForm.SpeedButtonLogClearClick(Sender: TObject);
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Clear;
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

procedure TLccThrottleAppForm.SpeedButtonTrainRosterBackClick(Sender: TObject);
begin
  ActionTabTrainRosterPrev.Execute;
  Controller.AbortCDI;
  TrainTabCDIClear;
  lbStatus.Text := '';
end;

procedure TLccThrottleAppForm.SpeedButtonTrainsFwdClick(Sender: TObject);
begin
  SpeedButtonTrainsRev.IsPressed := not SpeedButtonTrainsFwd.IsPressed;
  if Assigned(Controller) and IsTrainAssigned then
     Controller.SetSpeedDir(TrainInfo.NodeID, 100.0 - TrackBarTrainsThrottleLever.Value, SpeedButtonTrainsFwd.IsPressed);
end;

procedure TLccThrottleAppForm.SpeedButtonTrainsRevClick(Sender: TObject);
begin
  SpeedButtonTrainsFwd.IsPressed := not SpeedButtonTrainsRev.IsPressed;
  if Assigned(Controller) and IsTrainAssigned then
    Controller.SetSpeedDir(TrainInfo.NodeID, 100.0 - TrackBarTrainsThrottleLever.Value, SpeedButtonTrainsFwd.IsPressed);
end;

procedure TLccThrottleAppForm.SpeedButtonTrainsStopClick(Sender: TObject);
begin
  TrackBarTrainsThrottleLever.Value := 100;
end;

procedure TLccThrottleAppForm.TimerLoginTimer(Sender: TObject);
begin
  if TimerLogin.Interval <> 5000 then
    TimerLogin.Interval := 5000;

  if Assigned(EthernetClient) then
  begin
    if not (EthernetClient.Connected or EthernetClient.Connecting) then
      ButtonSettingsResetConnectionClick(Self)
  end
end;

procedure TLccThrottleAppForm.TrackBarTrainsThrottleLeverChange(Sender: TObject);
begin
  if Assigned(Controller) and IsTrainAssigned then
    Controller.SetSpeedDir(TrainInfo.NodeID, 100.0 - TrackBarTrainsThrottleLever.Value, SpeedButtonTrainsFwd.IsPressed);
  LabelTrainsSpeed.Text := FloatToStr(100.0 - TrackBarTrainsThrottleLever.Value)
end;

procedure TLccThrottleAppForm.TrainTabCDIClear;
begin
  NodeEditor.Clear;
  NodeEditor.Visible := False;
end;


procedure TLccThrottleAppForm.TrainTabCDILoad(ATrainInfo: TTrainInfo);
begin
  if SelectedRosterEqualsTractionObject(ATrainInfo) then
  begin
    TrainTabCDIClear;
    if ATrainInfo.CDI.Valid then
      RenderCDI(ATrainInfo);
  end;
end;

procedure TLccThrottleAppForm.TrainTabCDISelect;
begin
   if Assigned(ListViewTrainRoster.Selected) then
   begin
      ActionTabTrainRosterNext.Execute;
      TrainTabCDILoad(ListViewTrainRoster.Selected.TagObject as TTrainInfo)
   end;
end;

procedure TLccThrottleAppForm.TrainTabDetailsClear;
begin
  // Initialize Tab 1, Details
  ListBoxItemTrainsDetailsManufacturer.ItemData.Detail := 'loading...';
  ListBoxItemTrainsDetailsModel.ItemData.Detail := 'loading...';
  ListBoxItemTrainsDetailsSofwareVersion.ItemData.Detail := 'loading...';
  ListBoxItemTrainsDetailsHardwareVersion.ItemData.Detail := 'loading...';
  ListBoxItemTrainsDetailsUserName.ItemData.Detail := 'loading...';
  ListBoxItemTrainsDetailsUserDescription.ItemData.Detail := 'loading...';
  ListBoxItemTrainsDetailsConsists.ItemData.Detail := 'loading...';
end;



procedure TLccThrottleAppForm.TrainTabDetailsLoad(ATrainInfo: TTrainInfo);
begin
  if SelectedRosterEqualsTractionObject(ATrainInfo) then
  begin
    ListBoxItemTrainsDetailsManufacturer.ItemData.Detail := ATrainInfo.SNIP.Manufacturer;
    ListBoxItemTrainsDetailsModel.ItemData.Detail := ATrainInfo.SNIP.Model;
    ListBoxItemTrainsDetailsSofwareVersion.ItemData.Detail := ATrainInfo.SNIP.SoftwareVersion;
    ListBoxItemTrainsDetailsHardwareVersion.ItemData.Detail := ATrainInfo.SNIP.HardwareVersion;
    ListBoxItemTrainsDetailsUserName.ItemData.Detail := ATrainInfo.SNIP.UserName;
    ListBoxItemTrainsDetailsUserDescription.ItemData.Detail := ATrainInfo.SNIP.UserDescription;
    ListBoxItemTrainsDetailsConsists.ItemData.Detail := 'Bob';
  end;
end;


function TLccThrottleAppForm.ValidEditBoxKey(Key: Word): Boolean;
begin
  // HardwareBack is to handle Android
  Result := (Key = vkReturn) or (Key = vkHardwareBack) or (Key = vkBack) or (Key = vkDelete) or (Key = vkLeft) or (Key = vkRight)
end;

procedure TLccThrottleAppForm.XmlLoadSettingsFromFile;
var
  SettingsXML: TLccXmlDocument;
  RootNode, ChildNode: TLccXmlNode;
begin
  // Read in the Setting File
  SettingsXML := XmlLoadFromFile(PathSettingsFile);
  RootNode := XmlFindRootNode(SettingsXML, 'settings');
  if Assigned(RootNode) then
  begin
    ChildNode := XmlFindChildNode(RootNode, 'ipaddress');
    if Assigned(ChildNode) then
    begin
      if ValidateIPString( XmlNodeTextContent(ChildNode)) then
        CurrentIpAddress := XmlNodeTextContent(ChildNode);
    end;
    ChildNode := XmlFindChildNode(RootNode, 'port');
    if Assigned(ChildNode) then
    begin
      if ValidatePort( string( XmlNodeTextContent(ChildNode))) then
        CurrentPort := StrToInt( string( XmlNodeTextContent(ChildNode)));
    end;
    ChildNode := XmlFindChildNode(RootNode, 'nodeid');
    if Assigned(ChildNode) then
    begin
      if ValidateNodeIDString(XmlNodeTextContent(ChildNode)) then
        CurrentNodeID := StrToNodeID( XmlNodeTextContent(ChildNode), True);
    end;
  end;
end;

procedure TLccThrottleAppForm.XmlWriteDefaultFile;
var
  SettingsXML: TLccXmlDocument;
  RootNode, ChildNode: TLccXmlNode;
begin
  if not DirectoryExists(PathApplicationFiles) then
    ForceDirectories(PathApplicationFiles);

  if DirectoryExists(PathApplicationFiles) then
  begin
     SettingsXML := XmlCreateEmptyDocument;
     RootNode := XmlCreateRootNode(SettingsXML, 'settings', '');
     ChildNode := XmlCreateChildNode(SettingsXML, RootNode, 'ipaddress', CurrentIpAddress);
     ChildNode := XmlCreateChildNode(SettingsXML, RootNode, 'port', IntToStr(CurrentPort));
     ChildNode := XmlCreateChildNode(SettingsXML, RootNode, 'nodeid', NodeIDToString( CurrentNodeID, True));
     XmlWriteToFile(PathSettingsFile, SettingsXML);
     XmlFreeDocument(SettingsXML);
  end;
end;


end.

