# WhatsApp Group Chat Analysis
Cleaning and analysing WhatsApp group chat data as well as report design in PowerBI
## Introduction
This project was one that resulted from a search for a pet project (passion project) that would involve working with data that was personal and which the insights would be interesting to see. The documentation includes:
- Data Gathering & Transformation
- Report Requirement
- Data Modeling
- Report Design
- Data & Report Limitation
- Conclusion

## Data Gathering & Transformation
To get the WhatsApp chat data, I simply exported the chat from the WhatsApp group by navigating to the ellipsis at the top right corner of the group chat and selecting "Export Chat". That exported the chat as a text file. However with this method, one is limited to only 40,000 messages (without media). 
The exported chats needed to be transformed for ease of analysis and it was done using Power Query. Here is the Power Query Script to [Clean the WhatsApp Text file](/CleanWhatsAppData.pq)

## Report Requirement
While planning for this project the initial purpose of creating the report was to see the overall trend of conversations on the group and identify what period of time the most conversations took place. However, during the report design I was also interested in creating a report that lets the individual members of the group see their level of activity on the group over time. In summary, the report requirement was provide an overall trend of group activity and let each group member see their activiity.

## Data Modeling
For the Data Model the key tables that needed to be created were:
| Table Name | Brief Description | Power Query Script |
| -- | -- | -- |
| Chats | This would contain the messages, when they were sent, what time and by who | [CleanWhatsAppData](/CleanWhatsAppData.pq) |
| Date | A standard date table | |
| Time | A time table to facilitate analysis across time; hourly, by minute, AM/PM) | [TimeTable](/TimeTable.pq) |
| Person | A table containing a unique list of the group members | |

After all the tables are created, the needed relationships are created and it looks like this:
![Model](https://user-images.githubusercontent.com/107071538/178270411-0e174101-b595-4bd2-91be-83faf47a0617.png)

## Report Design
The design layout was designed in PowerPoint to have an idea of what I wanted the final output to be in PowerBI.
[Download PowerPoint file](/DesignLayout.pptx)

![Sample Layout](https://user-images.githubusercontent.com/107071538/178272805-42860b35-3629-4f5c-b9e5-2cbb7b2d2a20.png)

Here is the final report design.

![WhatsApp Analytics](https://user-images.githubusercontent.com/107071538/178370641-23a50341-1e26-4caa-9169-67711fcb3622.png)

## Data & Report Limitations
- The exported data does not include all messages from the inception of the group chat.
- From the data there is no way to identify who a message was responding to except the person was directly tagged.
- The data transformation and report does not provide data on who a message was in response to.
- Parts of a message might be ommitted due to some needed fix in the Power Query Script.
- Report does not cover a thematic analysis of the chats.

## Conclusion
This was a fun project to work on. Hopefully, the Power Query Script and documentation would help you replicate on your own data.
In the future there might be possible improvements on the Power Query Scripts.

I do not provide the .pbix for privacy reasons. However you can explore the interactive version of the report to see the full functionality and User Experience.
[WhatsApp Analytics](https://app.powerbi.com/view?r=eyJrIjoiZDUyYzAyNTMtNzMxMy00MzY0LWJlYTgtMTFjZTlkNTA3NWYxIiwidCI6ImQ1Yjk0YzQ0LWU5YjMtNGY1ZC1iZmFiLTBhMjE5NDg2NWNmNCJ9&pageName=ReportSectionda69547f7666a0481064)
