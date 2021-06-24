# Script to generate an HTML Phone Book based on the ipPhone field in Active Directory.
# It pulls the name and extension for all users if they have an Office location listed, are enabled and have an ipPhone listed.
# It pulls the locations from a txt file located in the same folder as the script.
 
 
# This is where all HTML Header code goes. It currently contains CSS code to format the phone book.
# All style modifications such as color, font size, etc. should be done in this HTML Code
$header = @"
<style>

.flex-container {
   max-height: 1500px;              /* setting height to make column mode work correctly, adjust this for your target screen resolution to prevent verticle scrolling */
   max-width: 1980px;               /* setting width to work with target screen resolution and prevent scroll bars */
   display: -ms-flexbox;
   display: -webkit-flex;
   display: flex;
   -webkit-flex-direction: column; /* flex set to columns to generate horizontal layout when combined with max-height */
   -ms-flex-direction: column;
   flex-direction: column;
   -webkit-flex-wrap: wrap;        /* wrap allows the flex-items to go into multiple columns */
   -ms-flex-wrap: wrap;
   flex-wrap: wrap;
   -webkit-justify-content: flex-start;    /* making sure items snap to previous item */
   -ms-flex-pack: start;
   justify-content: flex-start;
   -webkit-align-content: space-around;    /* equalizing distance between columns */
   -ms-flex-line-pack: distribute;
   align-content: space-around;
   -webkit-align-items: flex-start;
   -ms-flex-align: start;
   align-items: flex-start;
   }
 
div.flex-item /* defining the items to be flexed on */ {
   -webkit-order: 1;
   -ms-flex-order: 1;
   order: 1;
   -webkit-flex: 0 1 auto;
   -ms-flex: 0 1 auto;
   flex: 0 1 auto;
   -webkit-align-self: auto;
   -ms-flex-item-align: auto;
   align-self: auto;
   margin: 5px;                    /* adjusting this will put space between items verticaly */
   }
 
h2 {
   font-size: 25px;                /* Reduce Location Font Size */
   margin-bottom: 5px;             /* Reduce Location margin before tables */
   margin-top: 5px;
   background-color: #b13f2e;
 
}
 
table {
   width: 420px;                   /* Set this to the width of the longest name in your phone book */
}
 
tbody tr:nth-child(even) {
       background: #acadac;        /* alternate line highlights in the tables */
   }

td {
    padding: 5px;
}

 
   
</style>
"@
 
# This exists to make the tables end themselves properly. Also if you want to append anything to all the sections include it here.
$postcontent = "</div>"
 
# If you need to add any numbers manually put the html table code in this variable.
#$GroupDial = @"
#<div class="flex-item"> <!-- Make sure to use this class --!>
#   <h2>Group Dials</h2>
#   <table>
#   <colgroup><col><col></colgroup>
#   <tbody><tr><td>IT Help</td><td>111</td></tr>
#   <tr><td>Example Department</td><td>112</td></tr>
#   </tbody></table>
#   </div>
#"@
 
# Load list of Office locations from the txt file. The order of Locations in this file will determine the order in the report. This sometimes needs to be tweaked to put smaller sections next to each other, otherwise you may have gaps. This usually only happens if headcount changes sinificantly at an office.
$Locations = (Get-Content .\locations.txt)
 
#Build the HTML tables for the locations.    | Get user info from AD                            | Include name, office | Filter out no office users and match                    | Sort results by  | Pick only name and ipPhone  | Begin exporting to HTML Fragments. Precontent puts each table in a Flex Object                           | Fix a bit of HTML/Variable issue by adding " | Strip column titles in the tables.
#                                                                                               | and ipPhone          | location.                                               | name             |                             |                                                                            PostContent closes the object |                                              |
$Body = @(foreach ($location in $locations) { get-aduser -filter {Enabled -eq $true} -Properties Displayname, office, telephoneNumber, userPrincipalName | Where-Object { $_.Office -and $_.Office -eq $location } | Sort-Object Displayname | Select-Object Displayname, telephoneNumber, userPrincipalName | ConvertTo-Html -Fragment -PreContent "<div class=flex-item><h2>$location</h2>" -PostContent $postcontent | % { $_ -replace 'flex-item', '"flex-item"' } | % { $_ -replace '<th>name</th>', '<th>Name</th>' } | % {$_ -replace '<th>telephoneNumber</th>', '<th>Phone #</th>'} | % {$_ -replace '<th>userPrincipalName</th>', '<th>Email</th>'} } )
 
# This adds the direct extensions to each Location with a line break. This lists their Branch Hunt Group number. Format as  .replace("<h2>Location</h2>","<h2>Location<br>####</h2>")
# Use this method to do any other heading replacements
$Bodyfix = $Body | % { $_.replace("<h2>Location</h2>","<h2>Location<br>####</h2>").replace("<h2>Other Location</h2>","<h2>Location<br>####</h2>").replace("<th>Displayname</th>", "<th>Name</th>")}
 
# Building the final page.                  | Adding the flex container to make     | Main Page | Manual numbers | Close                         | Export final report to this location and overwrite existing.
#                                           | the formatting work.                  | code.     | table.         | container.                    |
$Report = ConvertTo-Html -Head $header -Body (@('<div class="flex-container"</div>') + $Bodyfix + $GroupDial + @('</div>')) -Title "Phone Book"  | Out-File .\phonebookembed.aspx -Force
 