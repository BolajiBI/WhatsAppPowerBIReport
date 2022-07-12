(TextDocumentFilePath as text ) =>

let
    Source = 
        Csv.Document(
            File.Contents(TextDocumentFilePath),
            [Encoding=65001, QuoteStyle=QuoteStyle.None]
        ),
    RenameDateColumn = Table.RenameColumns(Source, {{"Column1", "Date"}, {"Column2","Column1"}}),
    ExtractTimeText = Table.AddColumn(RenameDateColumn, "Time", each Text.BeforeDelimiter([Column1], " - ")),
    ChangedType = Table.TransformColumnTypes(ExtractTimeText,{{"Date", type date}, {"Time", type time}}),
    ReplacedErrors = Table.ReplaceErrorValues(ChangedType, {{"Date", null}, {"Time", null}}),
    ExtractPerson = Table.AddColumn(ReplacedErrors, "Person", each if [Date] <> null then Text.BetweenDelimiters([Column1], "M - ", ":") else null, type text),
    ExtractRepeatMsg = Table.AddColumn(ExtractPerson, "Message", each if [Date] <> null then Text.AfterDelimiter([Column1], ": ") else [Column1], type text),
    FilledDown = Table.FillDown(ExtractRepeatMsg,{"Date", "Time", "Person"}),
    RemovedEmojisFromName = Table.TransformColumns(FilledDown,{{"Person", each Text.Select(_, {"A".."z"," "}), type text}}),
    GroupedRows = Table.Group(RemovedEmojisFromName, {"Date", "Time", "Person"}, {{"Message", each Text.Combine( _[Message], " ") , type text}}),
    IdentifyMedia = Table.ReplaceValue(GroupedRows,"<Media omitted>","Media",Replacer.ReplaceText,{"Message"}),
    RemovedDeletedMessages = Table.ReplaceValue(IdentifyMedia,"You deleted this message",null,Replacer.ReplaceValue,{"Message"}),
    InsertedTimeKey = Table.AddColumn(RemovedDeletedMessages, "TimeKey", each Time.Hour([Time]) * 60 + Time.Minute([Time]), Int64.Type),
    FilteredRows = Table.SelectRows(InsertedTimeKey, each ([Message] <> null and [Message] <> "")),
    AddedMessageType = Table.AddColumn(FilteredRows, "MessageType", each if [Message] = "Media" then "Media" else "Text", type text),
    TrimmedText = Table.TransformColumns(AddedMessageType,{{"Person", Text.Trim, type text}})
in
    TrimmedText
