program DualController;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, dualcontroller_unit, throttle_takeover_request_form,
  lcc_alias_server, FormEditConsistItem, lcc_train_server, form_logging,
form_visual_server
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormThrottleTakeover, FormThrottleTakeover);
  Application.CreateForm(TFormConsistEditor, FormConsistEditor);
  Application.CreateForm(TFormNetworkLogging, FormNetworkLogging);
  Application.CreateForm(TFormServerInfo, FormServerInfo);
  Application.Run;
end.

