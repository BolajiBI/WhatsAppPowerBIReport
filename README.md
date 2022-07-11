# WhatsApp Group Chat Analysis
Cleaning and analysing WhatsApp group chat data as well as report design in PowerBI
## Introduction
This project was one that resulted from a search for a pet project (passion project) that would involve working with data that was personal and which the insights would be interesting to see. The documentation includes:
- Data Gathering & Transformation
- Report requirement
- Data Modelling
- Report Design
- User Feedback
- Report Limitation
- Conclusion

## Data Gathering & Transformation
To get the WhatsApp chat data, I simply exported the chat from the WhatsApp group by navigating to the ellipsis at the top right corner of the group chat and selecting "Export Chat". That exported the chat as a text file. However with this method, one is limited to only 40,000 messages (without media). 
The exported chats needed to be transformed for ease of analysis and it was done using Power Query. Here is the Power Query Script to [Clean the WhatsApp Text file](/CleanWhatsAppData.pq)

## Report Requirement
While planning for this project the initial purpose of creating the report was to see the overall trend of conversations on the group and identify what period of time the most conversations took place. However, during the report design I was also interested in creating a report that lets the individual members of the group see their level of activity on the group over time. In summary, the report requirement was provide an overall trend of group activity and let each group member see their activiity.

## Data Modelling
For the Data Model the key tables that needed to be created were:
| Table Name | Brief Description | Power Query Script |
| -- | -- | -- |
| Chats | This would contain the messages, when they were sent, what time and by who | [CleanWhatsAppData](\CleanWhatsAppData) |
| Date | A standard date table | |
| Time | A time table to facilitate analysis across time; hourly, by minute, AM/PM) | [Time Table](/TimeTable.pq) |
| Person | A table containing a unique list of the group members | |

After all the tables are created, the needed relationships are created and it looks like this:
![Model](https://user-images.githubusercontent.com/107071538/178270411-0e174101-b595-4bd2-91be-83faf47a0617.png)

## Report Design
The design layout was designed in PowerPoint to have an idea of the I wanted the final output to be in PowerBI. 
[Download PowerPoint file](/Visual Design WhatsApp Report.pptx)

![Sample Layout](https://user-images.githubusercontent.com/107071538/178272805-42860b35-3629-4f5c-b9e5-2cbb7b2d2a20.png)
