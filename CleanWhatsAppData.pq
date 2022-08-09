let
    fxCleanWhatsappText = (TextFilePath as text, MessageSeparator as text, PersonSeparator as text, DateFormat as text, HasSquareBrackets as logical ) as table =>
        let
            Source = 
            Csv.Document(
                File.Contents(TextFilePath),
                [Delimiter="#(tab)"]
            ),
            RemoveBlanks = Table.SelectRows(Source, each ([Column1] <> "")),
            ExtractDateAndTime = Table.AddColumn(RemoveBlanks, "Date,Time", each Text.BeforeDelimiter([Column1], if HasSquareBrackets then "] " else " " &MessageSeparator&" "), type text),
            ReplaceOpeningBracket = Table.ReplaceValue(ExtractDateAndTime,"[","",Replacer.ReplaceText,{"Date,Time"}),
            SplitDateAndTime = Table.SplitColumn(ReplaceOpeningBracket, "Date,Time", Splitter.SplitTextByEachDelimiter({", "}, QuoteStyle.Csv, false), {"Date", "Time"}),
            ChangedType = Table.TransformColumnTypes(SplitDateAndTime,{{"Column1", type text}, {"Date", type date}, {"Time", type time}}, if DateFormat = "DD/MM/YYY" then "en-GB" else "en-US"),            
            ReplacedErrorDateTime = Table.ReplaceErrorValues(ChangedType, {{"Date", null}, {"Time", null}}),
            ExtractPerson = Table.AddColumn(ReplacedErrorDateTime, "Person", each if Text.Contains( Text.Start( [Column1], 10 ), "/" ) then Text.BetweenDelimiters([Column1], if HasSquareBrackets then "] " else " " &MessageSeparator&" ", PersonSeparator) else "", type text),
            
            ExtractStartMsg = Table.AddColumn(ExtractPerson, "Messages1", each Text.AfterDelimiter([Column1], [Person]&PersonSeparator), type text),
            ReplacedWithNull = Table.ReplaceValue(ExtractStartMsg,"",null,Replacer.ReplaceValue,{"Person"}),
            AddedEndMsg = Table.AddColumn(ReplacedWithNull, "Messages", each if [Messages1] = "" then [Column1] else [Messages1], type text),
            FilledDownDateTimePerson = Table.FillDown(AddedEndMsg,{"Date", "Time", "Person"}),
            GroupedRows = Table.Group(FilledDownDateTimePerson, {"Date", "Time", "Person"}, {{"Message", each Text.Combine(Table.SelectRows(_, each [Date] <> null)[Messages],"#(lf)"), type text}}),
            RemovedEmojisFromName = Table.TransformColumns(GroupedRows,{{"Person", each Text.Select(_, {"A".."z", " ", "0".."9","+"}), type text}}),
            RemoveErrorNames = Table.SelectRows(RemovedEmojisFromName, each not Text.Contains([Person], "joined") and not Text.Contains([Person], "left") and not Text.Contains([Person], "changed") and not Text.Contains([Person], "added")),
            IdentifyMedia = Table.ReplaceValue(RemoveErrorNames,"<Media omitted>","Media",Replacer.ReplaceText,{"Message"}),
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
        ),
        DateFormat as (
            type text meta [
                Documentation.FieldCaption = "Date Format",
                Documentation.FieldDescription = "Format of the date",
                Documentation.AllowedValues = {"DD/MM/YYY", "MM/DD/YYY"}
            ]
        ),
        HasSquareBrackets as (
            type logical meta [
                Documentation.FieldCaption = "Date Enclosed in [ ]",
                Documentation.FieldDescription = "Checks if the date time is enclosed in square brackets [ ]",
                Documentation.AllowedValues = {true, false}
            ]
        )
    ) as table meta[
        Documentation.Name = "CleanWhatsappText",
        Documentation.Description = "Clean and transforms Whatsapp chats exported as a text file into a properly formatted table",
        Documentation.Examples = {
            [
                Description = "Transform text structure like ""2/26/21, 9:32 PM - John Doe: Hi Everyone"" into a table",
                Code = "CleanWhatsappText( ""C:\Users\Folder\FileName.txt"", ""-"", "":"", ""MM/DD/YYY"", ""FALSE"" )",
                Result = ""
            ],
            [
                Description = "Transform text structure like ""[26/2/21, 9:32 PM] John Doe: Hi Everyone"" into a table",
                Code = "CleanWhatsappText( ""C:\Users\Folder\FileName.txt"", "" "", "":"", ""DD/MM/YYY"", ""TRUE"" )",
                Result = ""
            ]
        }
    ]
in
    Value.ReplaceType( fxCleanWhatsappText, ParameterTypeAndMetadata)
