let
    Source = List.Numbers( 0, 1440),
    ConvertedtoTable = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    RenamedTimeKey = Table.RenameColumns(ConvertedtoTable,{{"Column1", "TimeKey"}}),
    AddedTime = Table.AddColumn(RenamedTimeKey, "Time", each Time.From( [TimeKey] / 1440), type time ),
    InsertedHour = Table.AddColumn(AddedTime, "Hour", each Time.From( Time.Hour([Time]) / 24 ), type time),
    AddedAMPM = Table.AddColumn(InsertedHour, "AM/PM", each if [TimeKey] < 720 then "AM" else "PM", type text ),
    InsertedHourAsNum = Table.AddColumn(AddedAMPM, "HourNum", each Time.Hour([Time]), Int64.Type),
    ChangedType = Table.TransformColumnTypes(InsertedHourAsNum,{{"TimeKey", Int64.Type}})
in
    ChangedType
