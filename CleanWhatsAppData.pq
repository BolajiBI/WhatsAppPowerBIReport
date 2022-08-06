let
    fxCleanWhatsappText = (TextFilePath as text, MessageSeparator as text, PersonSeparator as text ) as table =>
        let
            Source = 
            Csv.Document(
                File.Contents(TextFilePath),
                [Delimiter="#(tab)"]
            ),
            ExtractDateAndTime = Table.AddColumn(Source, "Date,Time", each Text.BeforeDelimiter([Column1], " " &MessageSeparator&" "), type text),
            SplitDateAndTime = Table.SplitColumn(ExtractDateAndTime, "Date,Time", Splitter.SplitTextByEachDelimiter({", "}, QuoteStyle.Csv, false), {"Date", "Time"}),
            ChangedType = Table.TransformColumnTypes(SplitDateAndTime,{{"Column1", type text}, {"Date", type date}, {"Time", type time}}),
            ReplacedErrorDateTime = Table.ReplaceErrorValues(ChangedType, {{"Date", null}, {"Time", null}}),
            ExtractPerson = Table.AddColumn(ReplacedErrorDateTime, "Person", each Text.BetweenDelimiters([Column1], " " &MessageSeparator&" ", PersonSeparator), type text),
            ExtractStartMsg = Table.AddColumn(ExtractPerson, "Messages1", each Text.AfterDelimiter([Column1], [Person]&PersonSeparator), type text),
            ReplacedWithNull = Table.ReplaceValue(ExtractStartMsg,"",null,Replacer.ReplaceValue,{"Person"}),
            AddedEndMsg = Table.AddColumn(ReplacedWithNull, "Messages", each if [Messages1] = "" then [Column1] else [Messages1], type text),
            FilledDownDateTimePerson = Table.FillDown(AddedEndMsg,{"Date", "Time", "Person"}),
            GroupedRows = Table.Group(FilledDownDateTimePerson, {"Date", "Time", "Person"}, {{"Message", each Text.Combine(Table.SelectRows(_, each [Date] <> null)[Messages],"#(lf)"), type text}}),
            RemovedEmojisFromName = Table.TransformColumns(GroupedRows,{{"Person", each Text.Select(_, {"A".."z"," "}), type text}}),
            IdentifyMedia = Table.ReplaceValue(RemovedEmojisFromName,"<Media omitted>","Media",Replacer.ReplaceText,{"Message"}),
            AddedMessageType = Table.AddColumn(IdentifyMedia, "MessageType", each if [Message] = "Media" then "Media" else "Text", type text),
            SelectColumns = Table.SelectColumns(AddedMessageType,{"Date", "Time", "Person", "Message", "MessageType"}),
            TrimmedText = Table.TransformColumns(SelectColumns,{{"Person", Text.Trim, type text}, {"Message", Text.Trim, type text}})
        in
            TrimmedText,
    ParameterTypeAndMetadata = 
    type function( 
        TextFilePath as ( 
            type text meta [
                Documentation.FieldCaption = "Text File Path",
                Documentation.FieldDescription = "File path for text document",
                Documentation.SampleValues = {"C:\Users\Folder\FileName.txt"}
            ]
        ),
        MessageSeparator as (
            type text meta [
                Documentation.FieldCaption = "Message Separator",
                Documentation.FieldDescription = "Character separating date & time information from the Contact name and messages sent",
                Documentation.SampleValues = {" - "}
            ]
        ),
        PersonSeparator as (
            type text meta [
                Documentation.FieldCaption = "Contact Separator",
                Documentation.FieldDescription = "Character separating Contact's name from the messages sent",
                Documentation.SampleValues = {" : "}
            ]
        )
    ) as table meta[
        Documentation.Name = "CleanWhatsappText",
        Documentation.Description = "Clean and transforms Whatsapp chats exported as a text file into a properly formatted table",
        Documentation.Examples = {
            [
                Description = "Transform text structure like ""2/26/21, 9:32 PM - John Doe: Hi Everyone"" into a table",
                Code = "CleanWhatsappText( ""C:\Users\Folder\FileName.txt"", ""-"", "":"" )",
                Result = ""
            ]
        }
    ]
in
    Value.ReplaceType( fxCleanWhatsappText, ParameterTypeAndMetadata)
