//Skeleton Program code for the AQA A Level Paper 1 Summer 2019 examination
//this code should be used in conjunction with the Preliminary Material
//written by the AQA Programmer Team
//developed in the Delphi and Lazarus programming environments

// {$MODE OBJFPC} // Comment this line out for Delphi, uncomment it for
// Free Pascal

{$APPTYPE CONSOLE}

{$H+}

program Adventures;
  uses
    SysUtils;         // For Delphi
    //SysUtils, Crt;  // For Free Pascal

  const
    Inventory: Integer = 1001;
    MinimumIDForItem: Integer = 2001;
    IDDifferenceForObjectInTwoLocations: Integer = 10000;

  type
    TPlace = record
      Description: string;
      ID, North, East, South, West, Up, Down: integer
    end;

    TCharacter = record
      Name, Description: string;
      ID, CurrentLocation: integer
    end;

    TItem = record
      ID, Location: integer;
      Description, Status, Name, Commands, Results: string
    end;

    TCharacterArray = Array of TCharacter;
    TPlaceArray = Array of TPlace;
    TItemArray = Array of TItem;

  function GetInstruction(): string;
  var
    Instruction: string;
  begin
    writeln;
    write('> ');
    readln(Instruction);
    GetInstruction := lowercase(Instruction)
  end;

  function ExtractCommand(var Instruction: string): string;
  var
    Command: string;
  begin
    Command := '';
    if pos(' ', Instruction) = 0 then
      begin
        ExtractCommand := Instruction;
        exit;
      end
    else
      begin
        while (length(Instruction) > 0) and (Instruction[1] <> ' ') do
          begin
            Command := Command + Instruction[1];
            delete(Instruction, 1, 1);
          end;
        while (length(Instruction) > 0) and (Instruction[1] = ' ') do
          delete(Instruction, 1, 1);
      end;
    ExtractCommand := Command
  end;

  function Go(var You: TCharacter; Direction: string; CurrentPlace: TPlace): boolean;
  var
    Moved: boolean;
  begin
    Moved := true;
    if Direction = 'north' then
      if CurrentPlace.North = 0 then
        Moved := false
      else
        You.CurrentLocation := CurrentPlace.North

    else if Direction = 'east' then
      if CurrentPlace.East = 0 then
        Moved := false
      else
        You.CurrentLocation := CurrentPlace.East

    else if Direction = 'south' then
      if CurrentPlace.South = 0 then
        Moved := false
      else
        You.CurrentLocation := CurrentPlace.South

    else if Direction = 'west' then
      if CurrentPlace.West = 0 then
        Moved := false
      else
        You.CurrentLocation := CurrentPlace.West

    else if Direction = 'up' then
      if CurrentPlace.Up = 0 then
        Moved := false
      else
        You.CurrentLocation := CurrentPlace.Up

    else if Direction = 'down' then
      if CurrentPlace.Down = 0 then
        Moved := false
      else
        You.CurrentLocation := CurrentPlace.Down

    else
      Moved := false;
    if not Moved then
      writeln('You are not able to go in that direction.');
    Go := Moved
  end;

  procedure DisplayDoorStatus(Status: string);
  begin
    if Status = 'open' then
      writeln('The door is open.')
    else
      writeln('The door is closed.')
  end;

  procedure DisplayContentsOfContainerItem(Items: TItemArray; ContainerID: integer);
  var
    ContainsItem: boolean;
    Thing: TItem;
  begin
    ContainsItem := false;
    write('It contains: ');
    for Thing in Items do
      begin
        if Thing.location = ContainerID then
          begin
            if ContainsItem then
              write(', ');
            ContainsItem := true;
            write(Thing.name);
          end;
      end;
    if ContainsItem then
      writeln('.')
    else
      writeln('nothing.')
  end;

  procedure DisplayInventory(Items: TItemArray);
  var
    Thing: TItem;
  begin
    writeln;
    writeln('You are currently carrying the following items:');
    for Thing in Items  do
      if Thing.Location = Inventory then
        writeln(Thing.Name);
    writeln;
  end;

  function GetIndexOfItem(ItemNameToGet: string; ItemIDToGet: integer; Items: TItemArray): integer;
  var
    Count: integer;
    StopLoop: boolean;
  begin
    Count := 0;
    StopLoop := false;
    while (not StopLoop) and (Count < Length(Items)) do
      begin
        if ((ItemIDToGet = -1) and (Items[Count].Name = ItemNameToGet)) or (Items[Count].ID =
           ItemIDToGet) then
          StopLoop := true
        else
          inc(Count);
      end;
    if not StopLoop then
      GetIndexOfItem := -1
    else
      GetIndexOfItem := Count;
  end;

  procedure DisplayGettableItemsInLocation(Items: TItemArray; CurrentLocation: integer);
  var
    ContainsGettableItems: boolean;
    ListOfItems: string;
    Thing: TItem;
  begin
    ContainsGettableItems := false;
    ListOfItems := 'On the floor there is: ';
    for Thing in Items do
      begin
        if (Thing.Location = CurrentLocation) and (pos('gettable', Thing.Status) <> 0) then
          begin
            if ContainsGettableItems then
              ListOfItems := ListOfItems + ', ';
            ListOfItems := ListOfItems + Thing.Name;
            ContainsGettableItems := true;
          end;
      end;
    if ContainsGettableItems then
      writeln(ListOfItems, '.');
  end;
  
  procedure Examine(Items: TItemArray; Characters: TCharacterArray; ItemToExamine: string;
                    CurrentLocation: integer; Places: TPlaceArray);
  var
    Count: integer;
    IndexOfItem: integer;
  begin
    if ItemToExamine = 'inventory' then
      DisplayInventory(Items)
    else 
    begin
    if ItemToExamine = 'location' then begin
      writeln;
      writeln;
      writeln(Places[Characters[0].CurrentLocation - 1].Description);
      DisplayGettableItemsInLocation(Items, Characters[0].CurrentLocation);
    end
    else
      IndexOfItem := GetIndexOfItem(ItemToExamine, -1, Items);
      if IndexOfItem <> -1 then
        begin
          if (Items[IndexOfItem].Location =
             Inventory) or (Items[IndexOfItem].Location = CurrentLocation) then
            begin
              writeln(Items[IndexOfItem].Description);
              if pos('door', Items[IndexOfItem].Name) <> 0 then
                DisplayDoorStatus(Items[IndexOfItem].Status);
              if pos('container', Items[IndexOfItem].Status) <> 0 then
                DisplayContentsOfContainerItem(Items, Items[IndexOfItem].ID);
              Exit
            end;
        end;
      Count := 0;
      while Count < length(Characters) do
        begin
          if (Characters[Count].Name = ItemToExamine) and (Characters[Count].CurrentLocation =
             CurrentLocation) then
            begin
              writeln(Characters[Count].Description);
              exit;
            end;
          inc(Count);
        end;
      writeln('You cannot find ' + ItemToExamine + ' to look at.');
    end
  end;

  function GetPositionOfCommand(CommandList: string; Command: string): integer;
  var
    Position: integer;
    Count: integer;
  begin
    Position := 0;
    Count := 0;
    while Count <= (length(CommandList) - length(Command)) do
      begin
        if copy(CommandList, Count, length(Command)) = Command then
          begin
            GetPositionOfCommand := Position;
            exit;
          end
        else
          if CommandList[Count] = ',' then
            inc(Position);
        inc(Count);
      end;
    GetPositionOfCommand := Position;
  end;

  function GetResultForCommand(Results: string; Position: integer): string;
  var
    Count: integer;
    CurrentPosition: integer;
    ResultForCommand: string;
  begin
    Count := 1;
    CurrentPosition := 0;
    ResultForCommand := '';

    while (CurrentPosition < Position) and (Count <= length(Results)) do
      begin
        if Results[Count] = ';' then
          inc(CurrentPosition);
        inc(Count);
      end;

    while Count <= length(Results) do
      begin
        if Results[Count] = ';' then
          break;
        ResultForCommand := ResultForCommand + Results[Count];
        inc(Count);
      end;

    GetResultForCommand := ResultForCommand;
  end;

  procedure Say(Speech: string);
  begin
    writeln;
    writeln(Speech);
    writeln;
  end;

  //
  procedure ExtractResultForCommand(var SubCommand: string; var SubCommandParameter: string;
                                    ResultForCommand: string);
  var
    Count: integer;
  begin
    Count := 1;
    while (Count <= Length(ResultForCommand)) and (ResultForCommand[Count] <> ',') do
      begin
        SubCommand := SubCommand + ResultForCommand[Count];
        inc(Count);
      end;
    inc(Count);
    while Count <= Length(ResultForCommand) do
      begin
        if (ResultForCommand[Count] <> ',') and (ResultForCommand[Count] <> ';') then
          SubCommandParameter := SubCommandParameter + ResultForCommand[Count]
        else
          break;
        inc(Count);
      end;
  end;

  procedure ChangeLocationReference(Direction: string; NewLocationReference: integer;
                                    Places : TPlaceArray; IndexOfCurrentLocation: integer;
                                    Opposite: boolean);
  var
    ThisPlace: TPlace;
  begin
    ThisPlace := Places[IndexOfCurrentLocation];
    if ((Direction = 'north') and (not Opposite)) or ((Direction = 'south') and (Opposite)) then
      ThisPlace.North := NewLocationReference
    else if ((Direction = 'east') and (not Opposite)) or ((Direction = 'west') and (Opposite)) then
      ThisPlace.East := NewLocationReference
    else if ((Direction = 'south') and (not Opposite)) or ((Direction = 'north') and (Opposite))
           then
      ThisPlace.South := NewLocationReference
    else if ((Direction = 'west') and (not Opposite)) or ((Direction = 'east') and (Opposite)) then
      ThisPlace.West := NewLocationReference
    else if ((Direction = 'up') and (not Opposite)) or ((Direction = 'down') and (Opposite)) then
      ThisPlace.Up := NewLocationReference
    else if ((Direction = 'down') and (not Opposite)) or ((Direction = 'up') and (Opposite)) then
      ThisPlace.Down := NewLocationReference;
    Places[IndexOfCurrentLocation] := ThisPlace;
  end;

  procedure ChangeStatusOfItem(var Items: TItemArray; IndexOfItem: integer; NewStatus: string);
  var
    ThisItem: tItem;
  begin
    ThisItem := Items[IndexOfItem];
    ThisItem.Status := NewStatus;
    Items[IndexOfItem] := ThisItem;
  end;

  procedure ChangeLocationOfItem(var Items: TItemArray; IndexOfItem: integer; NewLocation: integer);
  var
    ThisItem: TItem;
  begin
    ThisItem := Items[IndexOfItem];
    ThisItem.Location := NewLocation;
    Items[IndexOfItem] := ThisItem;
  end;

  function OpenClose(Open: boolean; Items: TItemArray; Places: TPlaceArray; ItemToOpenClose: string;
                     CurrentLocation: integer): integer;
  var
    Command: string;
    ResultForCommand: string;
    Count: integer;
    Position: integer;
    Count2: integer;
    Direction: string;
    DirectionChange: string;
    ActionWorked: boolean;
    IndexOfOtherSideOfDoor: integer;
  begin
    Direction := '';
    DirectionChange := '';
    ActionWorked := false;
    if Open then
      Command := 'open'
    else
      Command := 'close';
    Count := 0;
    while (Count < length(Items)) and (not ActionWorked) do
      begin
        if Items[Count].Name = ItemToOpenClose then
          if Items[Count].Location = CurrentLocation then
            if length(Items[Count].Commands) >= 4 then
              if pos(Command, Items[Count].Commands) <> 0 then
                begin
                  if items[Count].status = Command then
                    begin
                      OpenClose := -2;
                      exit;
                    end
                  else
                    if Items[Count].Status = 'locked' then
                      begin
                        OpenClose := -3;
                        exit;
                      end;
                  Position := GetPositionOfCommand(Items[Count].Commands, Command);
                  ResultForCommand := GetResultForCommand(Items[Count].Results, Position);
                  ExtractResultForCommand(Direction, DirectionChange, ResultForCommand);
                  ChangeStatusOfItem(Items, Count, Command);
                  Count2 := 0;
                  ActionWorked := true;
                  while Count2 < length(Places) do
                    begin
                      if Places[Count2].ID = CurrentLocation then
                        ChangeLocationReference(Direction, strtoint(DirectionChange), Places, Count2
                        , false)
                      else
                        if Places[Count2].ID = strtoint(DirectionChange) then
                          ChangeLocationReference(Direction, CurrentLocation, Places, Count2, true);
                      inc(Count2);
                    end;
                  if Items[Count].ID > IDDifferenceForObjectInTwoLocations then
                    IndexOfOtherSideOfDoor := GetIndexOfItem('', Items[Count].ID -
                                              IDDifferenceForObjectInTwoLocations, Items)
                  else
                    IndexOfOtherSideOfDoor := GetIndexOfItem('', Items[Count].ID +
                                              IDDifferenceForObjectInTwoLocations, Items);
                  ChangeStatusOfItem(Items, IndexOfOtherSideOfDoor, Command);
                  Count := length(Items) + 1;
                end;
        inc(Count);
      end;
    if not ActionWorked then
      begin
        OpenClose := -1;
        exit;
      end;
    OpenClose := strtoint(DirectionChange);
  end;

  function GetRandomNumber(LowerLimitValue: integer; UpperLimitValue: integer): integer;
  begin
    GetRandomNumber := trunc(random * (UpperLimitValue - LowerLimitValue + 1)) + LowerLimitValue;
  end;

  function RollDie(Lower: string; Upper: string): integer;
  var
    LowerLimitValue: integer;
    UpperLimitValue: integer;
    ErrorCode: integer;
  begin
    LowerLimitValue := 0;
    UpperLimitValue := 0;
    val(Lower, LowerLimitValue, ErrorCode);
    if ErrorCode <> 0 then
      while (LowerLimitValue < 1) or (LowerLimitValue > 6) do
        begin
          write('Enter minimum: ');
          readln(LowerLimitValue);
        end;
    val(Upper, UpperLimitValue, ErrorCode);
    if ErrorCode <> 0 then
      while (UpperLimitValue < LowerLimitValue) or (UpperLimitValue > 6) do
        begin
          write('Enter maximum: ');
          readln(UpperLimitValue);
        end;
    RollDie := GetRandomNumber(LowerLimitValue, UpperLimitValue);
  end;

  procedure ChangeStatusOfDoor(Items: TItemArray; CurrentLocation: integer; IndexOfItemToLockUnlock:
                               integer; IndexOfOtherSideItemToLockUnlock: integer);
  var
    MessageToDisplay : string;
  begin
    if (CurrentLocation = Items[IndexOfItemToLockUnlock].Location) or (CurrentLocation = Items[
       IndexOfOtherSideItemToLockUnlock].Location) then
      begin
        if Items[IndexOfItemToLockUnlock].Status = 'locked' then
          begin
            ChangeStatusOfItem(Items, IndexOfItemToLockUnlock, 'close');
            ChangeStatusOfItem(Items, IndexOfOtherSideItemToLockUnlock, 'close');
            MessageToDisplay := Items[IndexOfItemToLockUnlock].Name + ' now unlocked.';
            Say(MessageToDisplay);
          end
        else
          if Items[IndexOfItemToLockUnlock].Status = 'close' then
            begin
              ChangeStatusOfItem(Items, IndexOfItemToLockUnlock, 'locked');
              ChangeStatusOfItem(Items, IndexOfOtherSideItemToLockUnlock, 'locked');
              MessageToDisplay := Items[IndexOfItemToLockUnlock].Name + ' now locked.';
              Say(MessageToDisplay);
            end
        else
          begin
            MessageToDisplay := Items[IndexOfItemToLockUnlock].Name + ' is open so can''t be locked.';
            Say(MessageToDisplay);
          end;
      end
    else
      Say('Can''t use that key in this location.');
  end;

  procedure UseItem(Items: TItemArray; ItemToUse: string; CurrentLocation: integer; var StopGame:
                    boolean; Places: TPlaceArray);
  var
    Position: integer;
    IndexOfItem: integer;
    ResultForCommand: string;
    SubCommand: string;
    SubCommandParameter: string;
    IndexOfItemToLockUnlock: integer;
    IndexOfOtherSideItemToLockUnlock: integer;
    MessageToDisplay: string;
  begin
    SubCommand := '';
    SubCommandParameter := '';
    IndexOfItem := GetIndexOfItem(ItemToUse, -1, Items);
    if IndexOfItem <> -1 then
      begin
        if (Items[IndexOfItem].Location = Inventory) or ((Items[IndexOfItem].Location =
           CurrentLocation) and (pos('usable',Items[IndexOfItem].Status) > 0)) then
          begin
            Position := GetPositionOfCommand(Items[IndexOfItem].Commands, 'use');
            ResultForCommand := GetResultForCommand(Items[IndexOfItem].Results, Position);
            ExtractResultForCommand(SubCommand, SubCommandParameter, ResultForCommand);
            if SubCommand = 'say' then
              Say(SubCommandParameter)
            else
              if SubCommand = 'lockunlock' then
                begin
                  IndexOfItemToLockUnlock := GetIndexOfItem('', strtoint(SubCommandParameter), Items
                                             );
                  IndexOfOtherSideItemToLockUnlock := GetIndexOfItem('', strtoint(
                                                      SubCommandParameter) +
                                                      IDDifferenceForObjectInTwoLocations, Items);
                  ChangeStatusOfDoor(Items, CurrentLocation, IndexOfItemToLockUnlock,
                                     IndexOfOtherSideItemToLockUnlock);
                end
            else
              if SubCommand = 'roll' then
                begin
                  MessageToDisplay := 'You have rolled a ' + inttostr(RollDie(ResultForCommand[6],
                             ResultForCommand[8]));
                  Say(MessageToDisplay);
                end;
            exit;
          end;
      end;
    writeln('You can''t use that!');
  end;

  procedure ReadItem(Items: TItemArray; ItemToRead: string; CurrentLocation: integer);
  var
    SubCommand: string;
    SubCommandParameter: string;
    IndexOfItem: integer;
    Position: integer;
    ResultForCommand: string;
  begin
    SubCommand := '';
    SubCommandParameter := '';
    IndexOfItem := GetIndexOfItem(ItemToRead, -1, Items);
    if IndexOfItem = -1 then
      writeln('You can''t find ', ItemToRead, '.')
    else
      if pos('read', Items[IndexOfItem].Commands) = 0 then
        writeln('You can''t read ', ItemToRead, '.')
    else
      if (Items[IndexOfItem].Location <> CurrentLocation) and (Items[IndexOfItem].Location <>
         Inventory) then
        writeln('You can''t find ', ItemToRead, '.')
    else
      begin
        Position := GetPositionOfCommand(Items[IndexOfItem].Commands, 'read');
        ResultForCommand := GetResultForCommand(Items[IndexOfItem].Results, Position);
        ExtractResultForCommand(SubCommand, SubCommandParameter, ResultForCommand);
        if SubCommand = 'say' then
          Say(SubCommandParameter);
      end;
  end;

  procedure GetItem(Items: TItemArray; ItemToGet: string; CurrentLocation: integer; var StopGame:
                    boolean);
  var
    ResultForCommand: string;
    SubCommand: string;
    SubCommandParameter: string;
    IndexOfItem: integer;
    Position: integer;
    CanGet: boolean;
  begin
    SubCommand := '';
    SubCommandParameter := '';
    CanGet := false;
    IndexOfItem := GetIndexOfItem(ItemToGet, -1, Items);
    if IndexOfItem = -1 then
      writeln('You can''t find ', ItemToGet, '.')
    else if Items[IndexOfItem].Location = Inventory then
      writeln('You have already got that!')
    else if pos('get', Items[IndexOfItem].Commands) = 0 then
      writeln('You can''t get ', ItemToGet, '.')
    else if (Items[IndexOfItem].Location >= MinimumIDForItem) and (Items[GetIndexOfItem('', Items[
            IndexOfItem].Location, Items)].Location <> CurrentLocation) then
      writeln('You can''t find ', ItemToGet, '.')
    else if (Items[IndexOfItem].Location < MinimumIDForItem) and (Items[IndexOfItem].Location <>
            CurrentLocation) then
      writeln('You can''t find ', ItemToGet, '.')
    else
      CanGet := true;
    if CanGet then
      begin
        Position := GetPositionOfCommand(Items[IndexOfItem].Commands, 'get');
        ResultForCommand := GetResultForCommand(Items[IndexOfItem].Results, Position);
        ExtractResultForCommand(SubCommand, SubCommandParameter, ResultForCommand);
        if SubCommand = 'say' then
          Say(SubCommandParameter)
        else if SubCommand = 'win' then
          begin
            say('You have won the game');
            StopGame := true;
            exit;
          end;
        if pos('gettable', Items[IndexOfItem].Status) <> 0 then
          begin
            ChangeLocationOfItem(Items, IndexOfItem, Inventory);
            writeln('You have got that now.');
          end;
      end;
  end;

  function CheckIfDiceGamePossible(Items: TItemArray; Characters: TCharacterArray; var
                                   IndexOfPlayerDie: integer; var IndexOfOtherCharacter: integer;
                                   var IndexOfOtherCharacterDie: Integer; OtherCharacterName: string
                                   ): boolean;
  var
    PlayerHasDie: boolean;
    PlayersInSameRoom: boolean;
    OtherCharacterHasDie: boolean;
    Count: Integer;
    Thing: TItem;
  begin
    PlayerHasDie := false;
    PlayersInSameRoom := false;
    OtherCharacterHasDie := false;
    for Thing in Items do
      begin
        if (Thing.Location = Inventory) and (pos('die', Thing.Name) <> 0) then
          begin
            PlayerHasDie := true;
            IndexOfPlayerDie := GetIndexOfItem('', Thing.ID, Items);
          end;
      end;
    Count := 1;
    while (Count < length(Characters)) and (not PlayersInSameRoom) do
      begin
        if (Characters[0].CurrentLocation = Characters[Count].CurrentLocation) and (Characters[Count
           ].Name = OtherCharacterName) then
          begin
            PlayersInSameRoom := true;
            for Thing in Items do
              begin
                if (Thing.Location = Characters[Count].ID) and (pos('die', Thing.Name) <> 0) then
                  begin
                    OtherCharacterHasDie := true;
                    IndexOfOtherCharacterDie := GetIndexOfItem('', Thing.ID, Items);
                    IndexOfOtherCharacter := Count;
                  end;
              end;
          end;
        inc(Count);
      end;
    if (PlayerHasDie) and ((PlayersInSameRoom) and (OtherCharacterHasDie)) then
      CheckIfDiceGamePossible := true
    else
      CheckIfDiceGamePossible := false;
  end;

  procedure TakeItemFromOtherCharacter(Items: TItemArray; OtherCharacterID: integer);
  var
    ListOfIndicesOfItemsInInventory: array of integer;
    ListOfNamesOfItemsInInventory: array of string;
    Count: integer;
    ChosenItem: string;
    Index: integer;
    ArrayLength: integer;
    ItemFound: boolean;
  begin
    ArrayLength := 0;
    Count := 0;
    while Count < length(Items) do
      begin
        //Search through the list of itemsID's for any that the gaurd owns
        if Items[Count].Location = OtherCharacterID then
          begin
            //Dynamic array with which items the guard has
            inc(ArrayLength);
            SetLength(ListOfIndicesOfItemsInInventory, ArrayLength);
            SetLength(ListOfNamesOfItemsInInventory, ArrayLength);
            ListOfIndicesOfItemsInInventory[ArrayLength - 1] := Count;
            ListOfNamesOfItemsInInventory[ArrayLength - 1] := Items[Count].Name;
          end;
        inc(Count);
      end;
    Count := 1;
    write('Which item do you want to take? They have: ');
    //WHY WHY WHY this a for loop!
    write(ListOfNamesOfItemsInInventory[0]);
    while Count < length(ListOfNamesOfItemsInInventory) - 1 do
      begin
        write(', ', ListOfNamesOfItemsInInventory[Count]);
        inc(Count);
      end;
      
    writeln('.');
    readln(ChosenItem);
    ItemFound := false;
    for index := 0 to length(ListOfNamesOfItemsInInventory) - 1 do
      if ListOfNamesOfItemsInInventory[index] = ChosenItem then
        begin
          ItemFound := true;
          break;
        end;

    if ItemFound then
      begin
        writeln('You have that now.');
        ChangeLocationOfItem(Items, ListOfIndicesOfItemsInInventory[index], Inventory);
      end
    else
      writeln('They don''t have that item, so you don''t take anything this time.');
  end;

  procedure TakeRandomItemFromPlayer(Items: TItemArray; OtherCharacterID: integer);
  var
    ListOfIndicesOfItemsInInventory: array of integer;
    Count: integer;
    rno: integer;
    ArrayLength: integer;
  begin
    ArrayLength := 0;
    Count := 0;
    while Count < length(Items) do
      begin
        if Items[Count].Location = Inventory then
          begin
            inc(ArrayLength);
            SetLength(ListOfIndicesOfItemsInInventory, ArrayLength);
            ListOfIndicesOfItemsInInventory[ArrayLength - 1] := Count;
          end;
        inc(Count);         
      end;
    rno := GetRandomNumber(0, length(ListOfIndicesOfItemsInInventory) - 1);
    writeln('They have taken your ', Items[ListOfIndicesOfItemsInInventory[rno]].Name, '.');
    ChangeLocationOfItem(Items, ListOfIndicesOfItemsInInventory[rno], OtherCharacterID);
  end;

  procedure PlayDiceGame(Characters: TCharacterArray; Items: TItemArray; OtherCharacterName: string);
  var
    PlayerScore: integer;
    OtherCharacterScore: integer;
    IndexOfPlayerDie: integer;
    IndexOfOtherCharacterDie: integer;
    Position: integer;
    IndexOfOtherCharacter: integer;
    ResultForCommand: string;
    DiceGamePossible: boolean;
  begin
    PlayerScore := 0;
    OtherCharacterScore := 0;
    
    DiceGamePossible := CheckIfDiceGamePossible(Items, Characters, IndexOfPlayerDie,
                        IndexOfOtherCharacter, IndexOfOtherCharacterDie, OtherCharacterName);

    if not DiceGamePossible then
      writeln('You can''t play a dice game.')
    else
      begin
        Position := GetPositionOfCommand(Items[IndexOfPlayerDie].Commands, 'use');
        ResultForCommand := GetResultForCommand(Items[IndexOfPlayerDie].Results, Position);
        PlayerScore := RollDie(ResultForCommand[6], ResultForCommand[8]);
        writeln('You rolled a ', inttostr(PlayerScore), '.');

        Position := GetPositionO  fCommand(Items[IndexOfOtherCharacterdie].Commands, 'use');
        ResultForCommand := GetResultForCommand(Items[IndexOfOtherCharacterDie].Results, Position);
        OtherCharacterScore := RollDie(ResultForCommand[6], ResultForCommand[8]);
        writeln('They rolled a ', inttostr(OtherCharacterScore), '.');

        if PlayerScore > OtherCharacterScore then
          begin
            writeln('You win!');
            TakeItemFromOtherCharacter(Items, Characters[IndexOfOtherCharacter].ID);
          end
        else if PlayerScore < OtherCharacterScore then
          begin
            writeln('You lose!');
            TakeRandomItemFromPlayer(Items, Characters[IndexOfOtherCharacter].ID);
          end
        else
          writeln('Draw!');
      end;
  end;

  procedure MoveItem(Items: TItemArray; ItemToMove: string; CurrentLocation: integer);
  var
    Position: integer;
    ResultForCommand: string;
    SubCommand: string;
    SubCommandParameter: string;
    IndexOfItem: integer;
  begin
    SubCommand := '';
    SubCommandParameter := '';
    IndexOfItem := GetIndexOfItem(ItemToMove, -1, Items);
    if IndexOfItem <> -1 then
      if Items[IndexOfItem].Location = CurrentLocation then
        begin
          if length(Items[IndexOfItem].Commands) >= 4 then
            if pos('move', items[IndexOfItem].Commands) <> 0 then
              begin
                Position := GetPositionOfCommand(Items[IndexOfItem].Commands, 'move');
                ResultForCommand := GetResultForCommand(Items[IndexOfItem].Results, Position);
                ExtractResultForCommand(SubCommand, SubCommandParameter, ResultForCommand);
                if SubCommand = 'say' then
                  Say(SubCommandParameter);
              end
            else
              writeln('You can''t move ', ItemToMove, '.')
          else
            writeln('You can''t move ', ItemToMove, '.');
          exit;
        end;
    writeln('You can''t find ', ItemToMove, '.');
  end;
  
  procedure DisplayOpenCloseMessage(ResultOfOpenClose: integer; OpenCommand: boolean);
  begin
    if ResultOfOpenClose >= 0 then
      begin
        if OpenCommand then
          say('You have opened it.')
        else
          say('You have closed it.');
      end
    else if ResultOfOpenClose = -3 then
      say('You can''t do that, it is locked.')
    else if ResultOfOpenClose = -2 then
      say('It already is.')
    else if ResultOfOpenClose = -1 then
      say('You can''t open that.');
  end;

  function ConfirmQuit(): Boolean;
  var 
    response: char;
  begin
    response := ' ';
    while True do begin
      write('Are you sure that you want to quit (Y/N)> ');
      readln(response);
      case response of
        'Y': 
          begin 
            Say('You decide to give up, try again another time');
            result := True;
            break
          end;
        'N': 
          begin
            Say('You decide not to give up!');
            result := False;
            break;
          end
      else
        Say('Unreconized, please enter Y or N');
      end;
    end;
  end;
  
  
  procedure PlayGame(Characters: TCharacterArray; Items: TItemArray; Places: TPlaceArray);
  var
    StopGame: boolean;
    Instruction: string;
    Command: string;
    Moved: boolean;
    ResultOfOpenClose: integer;
  begin
    StopGame := false;
    Moved := true;
    while not StopGame do
      begin
        if Moved then
          begin
            writeln;
            writeln;
            writeln(Places[Characters[0].CurrentLocation - 1].Description);
            DisplayGettableItemsInLocation(Items, Characters[0].CurrentLocation);
            Moved := false;
          end;
        Instruction := GetInstruction;
        Command := ExtractCommand(Instruction);
        if Command = 'get' then
          GetItem(Items, Instruction, Characters[0].CurrentLocation, StopGame)
        else if Command = 'use' then
          UseItem(Items, Instruction, Characters[0].CurrentLocation, StopGame, Places)
        else if Command = 'go' then
          Moved := Go(Characters[0], Instruction, Places[Characters[0].CurrentLocation - 1])
        else if Command = 'read' then
          ReadItem(Items, Instruction, Characters[0].CurrentLocation)
        else if Command = 'examine' then
          Examine(Items, Characters, Instruction, Characters[0].CurrentLocation, Places)
        else if Command = 'open' then
          begin
            ResultOfOpenClose := OpenClose(true, Items, Places, Instruction, Characters[0].CurrentLocation);
            DisplayOpenCloseMessage(ResultOfOpenClose, true);
          end
        else if Command = 'close' then
          begin
            ResultOfOpenClose := OpenClose(false, Items, Places, Instruction, Characters[0].CurrentLocation);
            DisplayOpenCloseMessage(ResultOfOpenClose, false);
          end
        else if Command = 'move' then
          MoveItem(Items, Instruction, Characters[0].CurrentLocation)
        else if Command = 'say' then
          Say(Instruction)
        else if Command = 'playdice' then
          PlayDiceGame(Characters, Items, Instruction)
        else if Command = 'quit' then
          StopGame := ConfirmQuit()
        else
          begin
            writeln('Sorry, you don''t know how to ', Command, '.')
          end;
      end;
    readln;
  end;

  function ReadInteger32(var FromFile: file): integer;
  var
    Value: integer;
  begin
    blockread(fromFile, Value, sizeof(Value));
    ReadInteger32 := Value;
  end;

  function ReadString(var FromFile: file): string;
  var
    l: integer;
    i: integer;
    aString: string;
    aCharacter: char;
  begin
    l := ReadInteger32(fromFile);
    SetLength(aString, l);
    for i := 1 to l do
      begin
        blockread(fromFile, aCharacter, 1);
        aString[i] := aCharacter;
      end;
    ReadString := aString
  end;

  function LoadGame(Filename: string; var Characters: TCharacterArray; var Items: TItemArray; var
                    Places: TPlaceArray): boolean;
  var
    NoOfCharacters: integer;
    NoOfPlaces: integer;
    Count: integer;
    NoOfItems: integer;
    TempCharacter: TCharacter;
    TempPlace: TPlace;
    TempItem: TItem;
    Reader: file;
  begin
    try
      Assign(Reader, Filename);
      Reset(Reader, 1);
      NoOfCharacters := ReadInteger32(Reader);
      SetLength(Characters, NoOfCharacters);
      for Count := 1 to NoOfCharacters do
        begin
          TempCharacter.ID := ReadInteger32(Reader);
          Tempcharacter.Name := ReadString(Reader);
          TempCharacter.Description := ReadString(Reader);
          TempCharacter.CurrentLocation := ReadInteger32(Reader);
          Characters[Count - 1] := TempCharacter;
        end;
      NoOfPlaces := ReadInteger32(Reader);
      SetLength(Places, NoOfPlaces);
      for Count := 1 to NoOfPlaces do
        begin
          TempPlace.ID := ReadInteger32(Reader);
          TempPlace.Description := ReadString(Reader);
          TempPlace.North := ReadInteger32(Reader);
          TempPlace.East := ReadInteger32(Reader);
          TempPlace.South := ReadInteger32(Reader);
          TempPlace.West := ReadInteger32(Reader);
          TempPlace.Up := ReadInteger32(Reader);
          TempPlace.Down := ReadInteger32(Reader);
          Places[Count - 1] := TempPlace;
        end;
      NoOfItems := ReadInteger32(Reader);
      SetLength(Items, NoOfItems);
      for Count := 1 to NoOfItems do
        begin
          TempItem.ID := ReadInteger32(Reader);
          TempItem.Description := ReadString(Reader);
          TempItem.Status := ReadString(Reader);
          TempItem.Location := ReadInteger32(Reader);
          TempItem.Name := ReadString(Reader);
          TempItem.Commands := ReadString(Reader);
          TempItem.Results := ReadString(Reader);
          Items[Count - 1] := TempItem;
        end;
      close(Reader);
      LoadGame := true;
    except
      LoadGame := false;
    end;
  end;

  procedure Main;
  var
    Filename: string;
    Items: TItemArray;
    Characters: TCharacterArray;
    Places: TPlaceArray;
  begin
    write('Enter filename> ');
    readln(Filename);
    Filename := Filename + '.gme';
    writeln;
    if LoadGame(Filename, Characters, Items, Places) then
      PlayGame(Characters, Items, Places)
    else
      begin
        writeln('Unable to load game.');
        readln;
      end;
  end;

  begin
    randomize;
    Main;
  end.