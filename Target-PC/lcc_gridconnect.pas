unit lcc_gridconnect;

{$I ..\lcc_compilers.inc}

{$IFDEF LCC_FPC}
{$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  Classes,
  SysUtils,
  lcc_defines;

const
  // :X19170640N0501010107015555;#0  Example.....
  // ^         ^                  ^
  // 0         10                28
  MAX_GRID_CONNECT_LEN = 29;
  GRID_CONNECT_HEADER_OFFSET_HI = 2;
  GRID_CONNECT_HEADER_OFFSET_LO = 4;
  GRID_CONNECT_DATA_OFFSET = 11;

type
  TGridConnectString = array[0..MAX_GRID_CONNECT_LEN-1] of Byte;
  PGridConnectString = ^TGridConnectString;

type

  { TGridConnectDecodeStateMachine }

  TGridConnectDecodeStateMachine = class
  private
    FGridConnectReceiveState: Word;
    FReceiveGridConnectBuffer: TGridConnectString;
    FReceiveGridConnectBufferIndex: Integer;
  protected
    function IsValidHexChar(AChar: Byte): Boolean;
    property ReceiveGridConnectBuffer: TGridConnectString read FReceiveGridConnectBuffer write FReceiveGridConnectBuffer;
    property ReceiveGridConnectBufferIndex: Integer read FReceiveGridConnectBufferIndex write FReceiveGridConnectBufferIndex;
    property GridConnectReceiveState: Word read FGridConnectReceiveState write FGridConnectReceiveState;
  public
    constructor Create;
    function GridConnect_DecodeMachine(NextChar: Byte; var GridConnectStrPtr: PGridConnectString): Boolean;
  end;

  procedure StringToGridConnectBuffer(GridConnectStr: String; var GridConnectBuffer: TGridConnectString);
  function GridConnectBufferToString(var GridConnectBuffer: TGridConnectString): String;
implementation

const
  GRIDCONNECT_STATE_SYNC_START = 0;
  GRIDCONNECT_STATE_SYNC_FIND_HEADER = 2;
  GRIDCONNECT_STATE_SYNC_FIND_DATA = 4;

function GridConnectBufferToString(var GridConnectBuffer: TGridConnectString): String;
var
  i: Integer;
begin
  Result := '';
  i := 0;
  while (GridConnectBuffer[i] <> Ord(#0)) and (GridConnectBuffer[i] <> Ord(#10)) and (GridConnectBuffer[i] <> Ord(#13)) do
  begin
    Result := Result + Char( GridConnectBuffer[i]);
    Inc(i);
    if i > MAX_GRID_CONNECT_LEN then
      Break
  end;
end;

procedure StringToGridConnectBuffer(GridConnectStr: String; var GridConnectBuffer: TGridConnectString);
var
  i, Len: Integer;
  GridConnectStrPtr: PChar;
begin
  {$IFDEF LCC_FPC}
  GridConnectStrPtr := @GridConnectStr[1];
  {$ELSE}
  GridConnectStrPtr := @GridConnectStr[Low(GridConnectStr)];
  {$ENDIF}
  Len := Length(GridConnectStr);
  for i := 0 to Len - 1 do
  begin
    GridConnectBuffer[i] := Ord(GridConnectStrPtr^);
    Inc(GridConnectStrPtr);
  end;
end;

{ TGridConnectDecodeStateMachine }

constructor TGridConnectDecodeStateMachine.Create;
begin
 inherited Create;
  FGridConnectReceiveState := 0;
  FReceiveGridConnectBufferIndex := 0;
end;

function TGridConnectDecodeStateMachine.GridConnect_DecodeMachine(NextChar: Byte; var GridConnectStrPtr: PGridConnectString): Boolean;
//
// Returns a null terminated ansii array of charaters
//
var
  HeaderArray: array[0..7] of Byte;
  i, j: Integer;
begin
 Result := False;
 case GridConnectReceiveState of
      GRIDCONNECT_STATE_SYNC_START :                                            // Find a starting ':'
        begin
          if (NextChar = Ord('X')) or (NextChar = Ord('x')) then
          begin
            ReceiveGridConnectBufferIndex := 0;
            FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex] := Ord(':');
            Inc(FReceiveGridConnectBufferIndex);
            FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex] := Ord('X');
            Inc(FReceiveGridConnectBufferIndex);
            GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_FIND_HEADER;
          end else
          if (NextChar = Ord('R')) or (NextChar = Ord('r')) then
          begin
            ReceiveGridConnectBufferIndex := 0;
            FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex] := Ord(':');
            Inc(FReceiveGridConnectBufferIndex);
            FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex] := Ord('R');
            Inc(FReceiveGridConnectBufferIndex);
            GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_FIND_HEADER;
          end
        end;
      GRIDCONNECT_STATE_SYNC_FIND_HEADER :
        begin
          if ReceiveGridConnectBufferIndex < 11 then
          begin
            if (NextChar = Ord('n')) or (NextChar = Ord('N')) then
            begin
              if ReceiveGridConnectBufferIndex = 10 then                        // Just right number of characters, all done
              begin
                FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex] := Ord('N');
                Inc(FReceiveGridConnectBufferIndex);                             // Skip over the "N"
                GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_FIND_DATA;
              end else
              begin
                for i := 0 to 7 do
                  HeaderArray[i] := Ord('0');
                j := 7;
                for i := ReceiveGridConnectBufferIndex - 1 downto (11 - ReceiveGridConnectBufferIndex) do
                begin
                  HeaderArray[j] := ReceiveGridConnectBuffer[i];
                  Dec(j);
                end;
                for i := 0 to 7 do
                  FReceiveGridConnectBuffer[2 + i] := HeaderArray[i];
                FReceiveGridConnectBuffer[10] := Ord('N');
                ReceiveGridConnectBufferIndex := 11;                             // Skip over the "N"
                GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_FIND_DATA;
              end;
            end else
            begin
              if IsValidHexChar(NextChar) then
              begin
                FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex] := NextChar;
                Inc(FReceiveGridConnectBufferIndex);
              end else
              GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_START         // Error start over
            end
          end else
            GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_START         // Error start over
        end;
      GRIDCONNECT_STATE_SYNC_FIND_DATA :
        begin
           if NextChar = Ord(';') then
           begin
             if (ReceiveGridConnectBufferIndex + 1) mod 2 = 0 then              // 0 index, add 1 for the actual character count, if not true the result is broken
             begin
               FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex] := Ord(';');
               FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex + 1] := Ord(#0);
               GridConnectStrPtr := @ReceiveGridConnectBuffer;
               Result := True;
             end;
             GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_START            // Done
           end else
           begin
             if IsValidHexChar(NextChar) then
             begin
               FReceiveGridConnectBuffer[ReceiveGridConnectBufferIndex] := NextChar;
               Inc(FReceiveGridConnectBufferIndex);
             end else
               GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_START;         // Error start over
           end
        end else
          GridConnectReceiveState := GRIDCONNECT_STATE_SYNC_START;              // Invalidate State Index
    end;  // Cas
end;

function TGridConnectDecodeStateMachine.IsValidHexChar(AChar: Byte): Boolean;
begin
  Result :=  ( (AChar >= Ord('0')) and (AChar <= Ord('9')) ) or
             ( (AChar >= Ord('A')) and (AChar <= Ord('F')) ) or
             ( (AChar >= Ord('a')) and (AChar <= Ord('f')) )
end;

end.

