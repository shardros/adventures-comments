// Skeleton Program code for the AQA A Level Paper 1 Summer 2019 examination
// this code should be used in conjunction with the Preliminary Material
// written by the AQA Programmer Team
// developed in the Delphi and Lazarus programming environments

// {$MODE OBJFPC} // Comment this line out for Delphi, uncomment it for
// Free Pascal

{$APPTYPE CONSOLE}
{$H+}
program Adventures;

uses
  SysUtils; // For Delphi
// SysUtils, Crt;  // For Free Pascal

const
  Inventory: Integer = 1001;
  MinimumIDForItem: Integer = 2001;
  IDDifferenceForObjectInTwoLocations: Integer = 10000;

type
  TPlace = record
    Description: string;
    ID, North, East, South, West, Up, Down: Integer end;

    TCharacter = record Name, Description: string;
    ID, CurrentLocation: Integer end;

    TItem = record ID, Location: Integer;
    Description, Status, Name, Commands, Results: string end;

    TCharacterArray = Array of TCharacter;
    TPlaceArray = Array of TPlace;
    TItemArray = Array of TItem;

  //Prompts and waits for a response and converts to lowercase
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
    //If the command has a leading space then ignore it ?!?!?!?!?!?!?!?!?
    if pos(' ', Instruction) = 0 then
    begin
      ExtractCommand := Instruction;
      exit;
    end
    else
    begin
      //Pops items from the front of the queue untill the end or a space is
      //reached
      while (length(Instruction) > 0) and (Instruction[1] <> ' ') do
      begin
        Command := Command + Instruction[1];
        delete(Instruction, 1, 1);
        //Makes the command act like a queue by poping the leading items of the
        //Front of it
      end;
      //This does nothing???????
      while (length(Instruction) > 0) and (Instruction[1] = ' ') do
        delete(Instruction, 1, 1);
    end;
    ExtractCommand := Command
  end;

  //Allows the player to move locations
  function Go(var You: TCharacter; Direction: string;
    CurrentPlace: TPlace): boolean;
  var
    Moved: boolean;
  begin
    Moved := true;
    if Direction = 'north' then
      if CurrentPlace.North = 0 then
      //Zero is the null value which means that you can't move in that direction
        Moved := false
      else
      //You is a record storing data about you
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

  //Displays door status
  procedure DisplayDoorStatus(Status: string);

  begin
    if Status = 'open' then
      writeln('The door is open.')
    else
      writeln('The door is closed.')
  end;

  //Perform a linner search through all of the items to find the ones that are
  //in the container
  procedure DisplayContentsOfContainerItem(Items: TItemArray;
    ContainerID: Integer);
  var
    ContainsItem: boolean;
    Thing: TItem;
  begin
    ContainsItem := false;
    write('It contains: ');
    for Thing in Items do
    begin
      if Thing.Location = ContainerID then
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

  //Linner search accross all of the items for the ones in the inventory
  procedure DisplayInventory(Items: TItemArray);
  var
    Thing: TItem;
  begin
    writeln;
    writeln('You are currently carrying the following items:');
    for Thing in Items do
      if Thing.Location = Inventory then
        writeln(Thing.name);
    writeln;
  end;

  //Gets index of an item in the item array:
  //Passing ItemIDToGet = -1 means that itemNameToGet will be compared
  //Passing ItemIDToGet as a valid ID will return the itemID
  //Increment the while loop with a counter, and exit the loop when the ItemID
  //is reached.
  //Returns -1 if the item was not found
  function GetIndexOfItem(ItemNameToGet: string; ItemIDToGet: Integer;
    Items: TItemArray): Integer;
  var
    Count: Integer;
    StopLoop: boolean;
  begin
    Count := 0;
    StopLoop := false;
    while (not StopLoop) and (Count < length(Items)) do
    begin
      if ((ItemIDToGet = -1) and (Items[Count].name = ItemNameToGet))
       or (Items[Count].ID = ItemIDToGet)
      then
        StopLoop := true
      else
        inc(Count);
    end;
    if not StopLoop then
      GetIndexOfItem := -1
    else
      GetIndexOfItem := Count;
  end;

  //Returns infomation about the ItemToExamine
  //Items: All of the items in the game
  //Characters: All of the characters that the item can belong to
  //ItemToExamine: What is the item that we are interested in
  //CurrentLocation: The room number
  procedure Examine(Items: TItemArray; Characters: TCharacterArray;
    ItemToExamine: string; CurrentLocation: Integer);
  var
    Count: Integer;
    IndexOfItem: Integer;
  begin
    //Special case for the inventory
    if ItemToExamine = 'inventory' then
      DisplayInventory(Items)
    else
    begin
      IndexOfItem := GetIndexOfItem(ItemToExamine, -1, Items);
      //check if the thing to examine is an item in the item array
      if IndexOfItem <> -1 then
      begin
        //Can only examine items in inventory or in the current location
        if (Items[IndexOfItem].Location = Inventory) or
          (Items[IndexOfItem].Location = CurrentLocation) then
        begin
          writeln(Items[IndexOfItem].Description);
          if pos('door', Items[IndexOfItem].name) <> 0 then
            DisplayDoorStatus(Items[IndexOfItem].Status);
          if pos('container', Items[IndexOfItem].Status) <> 0 then
            DisplayContentsOfContainerItem(Items, Items[IndexOfItem].ID);
          exit;
        end;
      end;
      //ELSE it isn't an item in the item array
      //Perform a linner search through the cahracters array so that we can give
      //a description of any cahracters that we might find
      Count := 0;
      while Count < length(Characters) do
      begin
        if (Characters[Count].name = ItemToExamine) and
          (Characters[Count].CurrentLocation = CurrentLocation) then
        begin
          writeln(Characters[Count].Description);
          exit;
        end;
        inc(Count);
      end;
      //ELSE we have no idea what we are looking for and so
      writeln('You cannot find ' + ItemToExamine + ' to look at.');
    end
  end;

  //Every item has a string of commands with operands
  //This searches for the position of the command in the string
  //For example a door might have
  function GetPositionOfCommand(CommandList: string; Command: string): Integer;
  var
    Position: Integer;
    Count: Integer;
  begin
    Position := 0;
    Count := 0;

    (*Checks each position in the string for weather the command is there
     *This litterally seems like an implementation of pos() function so who
     *knows what AQA are thinking
     *)
    while Count <= (length(CommandList) - length(Command)) do
    begin
      //equivilent to CommandList[Count:len(Command)] == Command in python
      //Checks if the command is the section of the string begin at index
      //Count and ending at command length. If not increment the pointer.
      if copy(CommandList, Count, length(Command)) = Command then
      begin
        GetPositionOfCommand := Position;
        exit;
      end
      (*The function returns the count of which command it is not the position
        in the string, so we need to increment everytime we see a , as that
        signifies a new command*)
      else if CommandList[Count] = ',' then
        inc(Position);

      inc(Count);
    end;
    (*If we have gotten here without already exiting the command must be the
      last one in the string and so we can just return the position with out
      checking it as this function will never get called with an incorrect
      command*)
    GetPositionOfCommand := Position;

  end;

  (*
  Every command has an associated output for each "object" in the game for
  example the rug record looks like this:
  Item 2004 rug
  Description: It is a large colourful rug
  Location: 1
  Status: large
  *COMANDS:* move, get
  *RESULTS:* say,You can see a trapdoor underneath;say,You can't get that it is
      too big
  There are
  if a command is used on an item it looks up the result for what it should do
  in this case to say two different things. It is passed the index of the
  command.

  The comands "list" is comma seperated and the result "list" is semi-colon
  seperated
  *)
  function GetResultForCommand(Results: string; Position: Integer): string;
  var
    Count: Integer;
    CurrentPosition: Integer;
    ResultForCommand: string;
  begin
    Count := 1;
    CurrentPosition := 0;
    ResultForCommand := '';
    (*Move forwards through the list untill a semi-colon is reached, at this
    point we know that we have a new item in the list*)
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

  (*A wrapper for writeln, used internally so that AQA could have a common file
  for each of the games I imagine as they contain commands like say.
  *)
  procedure Say(Speech: string);

  begin
    writeln;
    writeln(Speech);
    writeln;
  end;

  (*
  Once we have the result we need to work out what is the operator and the
  operand, they are comma seperated and so cycle through the string untill a
  comma is reached at which point we can return the value.
  *)
  procedure ExtractResultForCommand(var SubCommand: string;
    var SubCommandParameter: string; ResultForCommand: string);

  var
    Count: Integer;

  begin
    Count := 1;
    while (Count <= length(ResultForCommand)) and
      (ResultForCommand[Count] <> ',') do
    begin
      SubCommand := SubCommand + ResultForCommand[Count];
      inc(Count);
    end;
    inc(Count);
    while Count <= length(ResultForCommand) do
    begin
      if (ResultForCommand[Count] <> ',') and (ResultForCommand[Count] <> ';')
      then
        SubCommandParameter := SubCommandParameter + ResultForCommand[Count]
      else
        break;
      inc(Count);
    end;
  end;

  (*
    Change where going goes. Used to close doors as the location is set to be
    the null locaiton (0) or the location that the door item says that it should
    point to. The oposite check inverts everything and is used by the door
    method to close the other side of the door, in the other room.
  *)
  procedure ChangeLocationReference(Direction: string;
    NewLocationReference: Integer; Places: TPlaceArray;
    IndexOfCurrentLocation: Integer; Opposite: boolean);
  var
    ThisPlace: TPlace;
  begin
    ThisPlace := Places[IndexOfCurrentLocation];
    if ((Direction = 'north') and (not Opposite)) or
      ((Direction = 'south') and (Opposite)) then
      ThisPlace.North := NewLocationReference
    else if ((Direction = 'east') and (not Opposite)) or
      ((Direction = 'west') and (Opposite)) then
      ThisPlace.East := NewLocationReference
    else if ((Direction = 'south') and (not Opposite)) or
      ((Direction = 'north') and (Opposite)) then
      ThisPlace.South := NewLocationReference
    else if ((Direction = 'west') and (not Opposite)) or
      ((Direction = 'east') and (Opposite)) then
      ThisPlace.West := NewLocationReference
    else if ((Direction = 'up') and (not Opposite)) or
      ((Direction = 'down') and (Opposite)) then
      ThisPlace.Up := NewLocationReference
    else if ((Direction = 'down') and (not Opposite)) or
      ((Direction = 'up') and (Opposite)) then
      ThisPlace.Down := NewLocationReference;
    Places[IndexOfCurrentLocation] := ThisPlace;
  end;

  //Changes the status of an item, e.g. for a door if it is open or closed
  procedure ChangeStatusOfItem(var Items: TItemArray; IndexOfItem: Integer;
    NewStatus: string);
  var
    ThisItem: TItem;
  begin
    ThisItem := Items[IndexOfItem];
    ThisItem.Status := NewStatus;
    Items[IndexOfItem] := ThisItem;
  end;

  //Updates the location property of an item
  procedure ChangeLocationOfItem(var Items: TItemArray; IndexOfItem: Integer;
    NewLocation: Integer);
  var
    ThisItem: TItem;
  begin
    ThisItem := Items[IndexOfItem];
    ThisItem.Location := NewLocation;
    Items[IndexOfItem] := ThisItem;
  end;

  //Opens or closes doors
  function OpenClose(Open: boolean; Items: TItemArray; Places: TPlaceArray;
    ItemToOpenClose: string; CurrentLocation: Integer): Integer;
  var
    Command: string;
    ResultForCommand: string;
    Count: Integer;
    Position: Integer;
    Count2: Integer;
    Direction: string;
    DirectionChange: string;
    ActionWorked: boolean;
    IndexOfOtherSideOfDoor: Integer;
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
      if Items[Count].name = ItemToOpenClose then
        if Items[Count].Location = CurrentLocation then
          (*Verify if the length of the commands is longer than 'open' and it is
          possible open could be one of the commands seems pointsless*)
          if length(Items[Count].Commands) >= 4 then
            if pos(Command, Items[Count].Commands) <> 0 then
            begin
              if Items[Count].Status = Command then
              begin //Already open/closed
                OpenClose := -2;
                exit;
              end
              else if Items[Count].Status = 'locked' then
              begin
                OpenClose := -3;
                exit;
              end;

              //Get command from the door record
              Position := GetPositionOfCommand(Items[Count].Commands, Command);
              ResultForCommand := GetResultForCommand(Items[Count].Results,
                Position);
              ExtractResultForCommand(Direction, DirectionChange,
                ResultForCommand);

              //Open or close the door item
              ChangeStatusOfItem(Items, Count, Command);

              (*
                Cycle through the places and make it possible or not for the
                player to move through a door way. Direction change is used
                because the door is actually two doors, one in each room,
                and so the door in the other room (the other side of the door)
                is facing 180 degrees from the direction of the other side of
                the door relative to the player
              *)
              Count2 := 0;
              ActionWorked := true;
              while Count2 < length(Places) do
              begin
                if Places[Count2].ID = CurrentLocation then
                  ChangeLocationReference(Direction, strtoint(DirectionChange),
                    Places, Count2, false)
                else if Places[Count2].ID = strtoint(DirectionChange) then
                  ChangeLocationReference(Direction, CurrentLocation, Places,
                    Count2, true);
                inc(Count2);
              end;

            (* Find the other door item to close. There is a standard offset
               between the two items and so depeding on if this is the greater
               or less of the ofsets then a + or a - is needed

               The status of the item is then changed once the ID of the item
               has been calculated. For once no linner search.
            *)
              if Items[Count].ID > IDDifferenceForObjectInTwoLocations then
                IndexOfOtherSideOfDoor :=
                  GetIndexOfItem('', Items[Count].ID -
                  IDDifferenceForObjectInTwoLocations, Items)
              else
                IndexOfOtherSideOfDoor :=
                  GetIndexOfItem('', Items[Count].ID +
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
    //The state was changed what state is the door in now
    OpenClose := strtoint(DirectionChange);
  end;

  //Gets a random integer between two values
  function GetRandomNumber(LowerLimitValue: Integer;
    UpperLimitValue: Integer): Integer;
  begin
    GetRandomNumber := trunc(random * (UpperLimitValue - LowerLimitValue + 1)) +
      LowerLimitValue;
  end;

  //Rolls the die
  function RollDie(Lower: string; Upper: string): Integer;
  var
    LowerLimitValue: Integer;
    UpperLimitValue: Integer;
    ErrorCode: Integer;
  begin
    (*
      val is an older Delphi procedure to convert from a string to an, int or a
      float, val(string_to_convert, varible_to_return_the_value_in, error_pos)
      the procedure "returns" the varible in the type of the second parameter
      Error Code should really be called error pos, if it errors then the value
      that was passed to it by the function is invalid and it asks the user.
    *)
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

    //Now that we have our limits we can now get our random number
    RollDie := GetRandomNumber(LowerLimitValue, UpperLimitValue);
  end;

  //Unlocks and locks a door, updates the status of the door
  procedure ChangeStatusOfDoor(Items: TItemArray; CurrentLocation: Integer;
    IndexOfItemToLockUnlock: Integer;
    IndexOfOtherSideItemToLockUnlock: Integer);
  var
    MessageToDisplay: string;
  begin
    if (CurrentLocation = Items[IndexOfItemToLockUnlock].Location) or
      (CurrentLocation = Items[IndexOfOtherSideItemToLockUnlock].Location) then
    begin
      if Items[IndexOfItemToLockUnlock].Status = 'locked' then
      begin
        ChangeStatusOfItem(Items, IndexOfItemToLockUnlock, 'close');
        ChangeStatusOfItem(Items, IndexOfOtherSideItemToLockUnlock, 'close');
        MessageToDisplay := Items[IndexOfItemToLockUnlock].name +
          ' now unlocked.';
        Say(MessageToDisplay);
      end
      else if Items[IndexOfItemToLockUnlock].Status = 'close' then
      begin
        ChangeStatusOfItem(Items, IndexOfItemToLockUnlock, 'locked');
        ChangeStatusOfItem(Items, IndexOfOtherSideItemToLockUnlock, 'locked');
        MessageToDisplay := Items[IndexOfItemToLockUnlock].name +
          ' now locked.';
        Say(MessageToDisplay);
      end
      else
      begin
        MessageToDisplay := Items[IndexOfItemToLockUnlock].name +
          ' is open so can''t be locked.';
        Say(MessageToDisplay);
      end;
    end
    else
      Say('Can''t use that key in this location.');
  end;


  procedure UseItem(Items: TItemArray; ItemToUse: string;
    CurrentLocation: Integer; var StopGame: boolean; Places: TPlaceArray);

  var
    Position: Integer;
    IndexOfItem: Integer;
    ResultForCommand: string;
    SubCommand: string;
    SubCommandParameter: string;
    IndexOfItemToLockUnlock: Integer;
    IndexOfOtherSideItemToLockUnlock: Integer;
    MessageToDisplay: string;

  begin
    SubCommand := '';
    SubCommandParameter := '';
    IndexOfItem := GetIndexOfItem(ItemToUse, -1, Items);
    if IndexOfItem <> -1 then
    begin
      if (Items[IndexOfItem].Location = Inventory) or
        ((Items[IndexOfItem].Location = CurrentLocation) and
        (pos('usable', Items[IndexOfItem].Status) > 0)) then
      begin
        (*Gets the command, broken into the "SubCommand" and the
          "SubCommandParameter"
        *)
        Position := GetPositionOfCommand(Items[IndexOfItem].Commands, 'use');
        ResultForCommand := GetResultForCommand(Items[IndexOfItem].Results,
          Position);
        ExtractResultForCommand(SubCommand, SubCommandParameter,
          ResultForCommand);

        //Says the thing
        if SubCommand = 'say' then
          Say(SubCommandParameter)

        //Locks/Unlocks a door
        else if SubCommand = 'lockunlock' then
        begin
          IndexOfItemToLockUnlock :=
            GetIndexOfItem('', strtoint(SubCommandParameter), Items);
          IndexOfOtherSideItemToLockUnlock :=
            GetIndexOfItem('', strtoint(SubCommandParameter) +
            IDDifferenceForObjectInTwoLocations, Items);
          ChangeStatusOfDoor(Items, CurrentLocation, IndexOfItemToLockUnlock,
            IndexOfOtherSideItemToLockUnlock);
        end

        //Starts a dice roll game with the gaurd
        else if SubCommand = 'roll' then
        begin
          MessageToDisplay := 'You have rolled a ' +
            inttostr(RollDie(ResultForCommand[6], ResultForCommand[8]));
          Say(MessageToDisplay);
        end;
        exit;
      end;
    end;
    writeln('You can''t use that!');
  end;

  (*Reads (if avalible) a book to the character*)
  procedure ReadItem(Items: TItemArray; ItemToRead: string;
    CurrentLocation: Integer);

  var
    SubCommand: string;
    SubCommandParameter: string;
    IndexOfItem: Integer;
    Position: Integer;
    ResultForCommand: string;

  begin
    SubCommand := '';
    SubCommandParameter := '';
    IndexOfItem := GetIndexOfItem(ItemToRead, -1, Items);
    if IndexOfItem = -1 then
      writeln('You can''t find ', ItemToRead, '.')
    else if pos('read', Items[IndexOfItem].Commands) = 0 then
      writeln('You can''t read ', ItemToRead, '.')
    else if (Items[IndexOfItem].Location <> CurrentLocation) and
      (Items[IndexOfItem].Location <> Inventory) then
      writeln('You can''t find ', ItemToRead, '.')
    else
    begin
      Position := GetPositionOfCommand(Items[IndexOfItem].Commands, 'read');
      ResultForCommand := GetResultForCommand(Items[IndexOfItem].Results,
        Position);
      ExtractResultForCommand(SubCommand, SubCommandParameter,
        ResultForCommand);
      if SubCommand = 'say' then
        Say(SubCommandParameter);
    end;
  end;

  (*Gets an item and checks if it is the flag*)
  procedure GetItem(Items: TItemArray; ItemToGet: string;
    CurrentLocation: Integer; StopGame: boolean);

  var
    ResultForCommand: string;
    SubCommand: string;
    SubCommandParameter: string;
    IndexOfItem: Integer;
    Position: Integer;
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
    else if (Items[IndexOfItem].Location >= MinimumIDForItem) and
      (Items[GetIndexOfItem('', Items[IndexOfItem].Location, Items)].Location <>
      CurrentLocation) then
      writeln('You can''t find ', ItemToGet, '.')
    else if (Items[IndexOfItem].Location < MinimumIDForItem) and
      (Items[IndexOfItem].Location <> CurrentLocation) then
      writeln('You can''t find ', ItemToGet, '.')
    else
      CanGet := true;
    if CanGet then
    begin
      Position := GetPositionOfCommand(Items[IndexOfItem].Commands, 'get');
      ResultForCommand := GetResultForCommand(Items[IndexOfItem].Results,
        Position);
      ExtractResultForCommand(SubCommand, SubCommandParameter,
        ResultForCommand);
      if SubCommand = 'say' then
        Say(SubCommandParameter)
      else if SubCommand = 'win' then
      begin
        Say('You have won the game');
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

  (*Checks if a die game is possible*)
  function CheckIfDiceGamePossible(Items: TItemArray;
    Characters: TCharacterArray; var IndexOfPlayerDie: Integer;
    var IndexOfOtherCharacter: Integer; var IndexOfOtherCharacterDie: Integer;
    OtherCharacterName: string): boolean;
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
      (*Gets the index of the FIRST die the linner search finds in the players
      inventory *)
      if (Thing.Location = Inventory) and (pos('die', Thing.name) <> 0) then
      begin
        PlayerHasDie := true;
        IndexOfPlayerDie := GetIndexOfItem('', Thing.ID, Items);
      end;
    end;

    (*Cycle through a list of all of the cahracters to see if they:
     1. Are in the same room
     2. have a die
     If so returns true
    *)
    Count := 1;
    while (Count < length(Characters)) and (not PlayersInSameRoom) do
    begin
      if (Characters[0].CurrentLocation = Characters[Count].CurrentLocation) and
        (Characters[Count].name = OtherCharacterName) then
      begin
        PlayersInSameRoom := true;
        for Thing in Items do
        begin
          if (Thing.Location = Characters[Count].ID) and
            (pos('die', Thing.name) <> 0) then
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

  //Bunch of linner searches to find and move the item from the other player.
  procedure TakeItemFromOtherCharacter(Items: TItemArray;
    OtherCharacterID: Integer);
  var
    ListOfIndicesOfItemsInInventory: array of Integer;
    ListOfNamesOfItemsInInventory: array of string;
    Count: Integer;
    ChosenItem: string;
    Index: Integer;
    ArrayLength: Integer;
    ItemFound: boolean;
  begin
    ArrayLength := 0;
    Count := 0;

    (*Creates two arrays:
      - The items the other character has
      - The index of those items
    *)
    while Count < length(Items) do
    begin
      if Items[Count].Location = OtherCharacterID then
      begin

        inc(ArrayLength); //Expand the dynamic array
        SetLength(ListOfIndicesOfItemsInInventory, ArrayLength);
        SetLength(ListOfNamesOfItemsInInventory, ArrayLength);

        ListOfIndicesOfItemsInInventory[ArrayLength - 1] := Count;
        ListOfNamesOfItemsInInventory[ArrayLength - 1] := Items[Count].name;
      end;
      inc(Count);
    end;
    Count := 1;
    write('Which item do you want to take? They have: ');

    //prints all of the items that they have.
    write(ListOfNamesOfItemsInInventory[0]);
    while Count < length(ListOfNamesOfItemsInInventory) - 1 do
    begin
      write(', ', ListOfNamesOfItemsInInventory[Count]);
      inc(Count);
    end;
    writeln('.');

    readln(ChosenItem);
    ItemFound := false;

    //Linner search for item through list to find the index of the item
    for index := 0 to length(ListOfNamesOfItemsInInventory) - 1 do
      if ListOfNamesOfItemsInInventory[index] = ChosenItem then
      begin
        ItemFound := true;
        break;
      end;

    //Change the location of the item
    if ItemFound then
    begin
      writeln('You have that now.');
      ChangeLocationOfItem(Items, ListOfIndicesOfItemsInInventory[index],
        Inventory);
    end
    else
      writeln('They don''t have that item, so you don''t take anything this time.');
  end;

  (*Takes a random item from a charater*)
  procedure TakeRandomItemFromPlayer(Items: TItemArray;
    OtherCharacterID: Integer);
  var
    ListOfIndicesOfItemsInInventory: array of Integer;
    Count: Integer;
    rno: Integer;
    ArrayLength: Integer;
  begin
    ArrayLength := 0;
    Count := 0;

    //Linner search to find out what items the character has.
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
    writeln('They have taken your ', Items[ListOfIndicesOfItemsInInventory[rno]]
      .name, '.');
    ChangeLocationOfItem(Items, ListOfIndicesOfItemsInInventory[rno],
      OtherCharacterID);
  end;

  procedure PlayDiceGame(Characters: TCharacterArray; Items: TItemArray;
    OtherCharacterName: string);

  var
    PlayerScore: Integer;
    OtherCharacterScore: Integer;
    IndexOfPlayerDie: Integer;
    IndexOfOtherCharacterDie: Integer;
    Position: Integer;
    IndexOfOtherCharacter: Integer;
    ResultForCommand: string;
    DiceGamePossible: boolean;

  begin
    PlayerScore := 0;
    OtherCharacterScore := 0;
    DiceGamePossible := CheckIfDiceGamePossible(Items, Characters,
      IndexOfPlayerDie, IndexOfOtherCharacter, IndexOfOtherCharacterDie,
      OtherCharacterName);
    if not DiceGamePossible then
      writeln('You can''t play a dice game.')
    else
    begin
      Position := GetPositionOfCommand(Items[IndexOfPlayerDie].Commands, 'use');
      ResultForCommand := GetResultForCommand(Items[IndexOfPlayerDie].Results,
        Position);
      PlayerScore := RollDie(ResultForCommand[6], ResultForCommand[8]);
      writeln('You rolled a ', inttostr(PlayerScore), '.');
      Position := GetPositionOfCommand(Items[IndexOfOtherCharacterDie]
        .Commands, 'use');
      ResultForCommand := GetResultForCommand(Items[IndexOfOtherCharacterDie]
        .Results, Position);
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

  procedure MoveItem(Items: TItemArray; ItemToMove: string;
    CurrentLocation: Integer);

  var
    Position: Integer;
    ResultForCommand: string;
    SubCommand: string;
    SubCommandParameter: string;
    IndexOfItem: Integer;

  begin
    SubCommand := '';
    SubCommandParameter := '';
    IndexOfItem := GetIndexOfItem(ItemToMove, -1, Items);
    if IndexOfItem <> -1 then
      if Items[IndexOfItem].Location = CurrentLocation then
      begin
        if length(Items[IndexOfItem].Commands) >= 4 then
          if pos('move', Items[IndexOfItem].Commands) <> 0 then
          begin
            Position := GetPositionOfCommand
              (Items[IndexOfItem].Commands, 'move');
            ResultForCommand := GetResultForCommand(Items[IndexOfItem].Results,
              Position);
            ExtractResultForCommand(SubCommand, SubCommandParameter,
              ResultForCommand);
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

  procedure DisplayGettableItemsInLocation(Items: TItemArray;
    CurrentLocation: Integer);

  var
    ContainsGettableItems: boolean;
    ListOfItems: string;
    Thing: TItem;

  begin
    ContainsGettableItems := false;
    ListOfItems := 'On the floor there is: ';
    for Thing in Items do
    begin
      if (Thing.Location = CurrentLocation) and
        (pos('gettable', Thing.Status) <> 0) then
      begin
        if ContainsGettableItems then
          ListOfItems := ListOfItems + ', ';
        ListOfItems := ListOfItems + Thing.name;
        ContainsGettableItems := true;
      end;
    end;
    if ContainsGettableItems then
      writeln(ListOfItems, '.');
  end;

  procedure DisplayOpenCloseMessage(ResultOfOpenClose: Integer;
    OpenCommand: boolean);

  begin
    if ResultOfOpenClose >= 0 then
    begin
      if OpenCommand then
        Say('You have opened it.')
      else
        Say('You have closed it.');
    end
    else if ResultOfOpenClose = -3 then
      Say('You can''t do that, it is locked.')
    else if ResultOfOpenClose = -2 then
      Say('It already is.')
    else if ResultOfOpenClose = -1 then
      Say('You can''t open that.');
  end;

  // The main procedure
  procedure PlayGame(Characters: TCharacterArray; Items: TItemArray;
    Places: TPlaceArray);

  var
    StopGame: boolean;
    Instruction: string;
    Command: string;
    Moved: boolean;
    ResultOfOpenClose: Integer;

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
        UseItem(Items, Instruction, Characters[0].CurrentLocation,
          StopGame, Places)
      else if Command = 'go' then
        Moved := Go(Characters[0], Instruction,
          Places[Characters[0].CurrentLocation - 1])
      else if Command = 'read' then
        ReadItem(Items, Instruction, Characters[0].CurrentLocation)
      else if Command = 'examine' then
        Examine(Items, Characters, Instruction, Characters[0].CurrentLocation)
      else if Command = 'open' then
      begin
        ResultOfOpenClose := OpenClose(true, Items, Places, Instruction,
          Characters[0].CurrentLocation);
        DisplayOpenCloseMessage(ResultOfOpenClose, true);
      end
      else if Command = 'close' then
      begin
        ResultOfOpenClose := OpenClose(false, Items, Places, Instruction,
          Characters[0].CurrentLocation);
        DisplayOpenCloseMessage(ResultOfOpenClose, false);
      end
      else if Command = 'move' then
        MoveItem(Items, Instruction, Characters[0].CurrentLocation)
      else if Command = 'say' then
        Say(Instruction)
      else if Command = 'playdice' then
        PlayDiceGame(Characters, Items, Instruction)
      else if Command = 'quit' then
      begin
        Say('You decide to give up, try again another time');
        StopGame := true;
      end
      else
      begin
        writeln('Sorry, you don''t know how to ', Command, '.')
      end;
    end;
    readln;
  end;

  function ReadInteger32(var FromFile: file): Integer;

  var
    Value: Integer;

  begin
    blockread(FromFile, Value, sizeof(Value));
    ReadInteger32 := Value;
  end;

  function ReadString(var FromFile: file): string;

  var
    l: Integer;
    i: Integer;
    aString: string;
    aCharacter: char;

  begin
    l := ReadInteger32(FromFile);
    SetLength(aString, l);
    for i := 1 to l do
    begin
      blockread(FromFile, aCharacter, 1);
      aString[i] := aCharacter;
    end;
    ReadString := aString
  end;

  function LoadGame(Filename: string; var Characters: TCharacterArray;
    var Items: TItemArray; var Places: TPlaceArray): boolean;

  var
    NoOfCharacters: Integer;
    NoOfPlaces: Integer;
    Count: Integer;
    NoOfItems: Integer;
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
        TempCharacter.name := ReadString(Reader);
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
        TempItem.name := ReadString(Reader);
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
