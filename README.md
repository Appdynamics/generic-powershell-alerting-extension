# AppDynamics Generic PowerShell Alerting Extension for Controllers on Windows

##Use Case
The Generic PowerShell alerting extension allows administrators running AppDynamics controller on Windows to use the familiar and powerful
PowerShell language to extend alerting capabilities of AppDynamics platform.

##Description
AppDynamics extension framework documented [Build an Alerting Extension](https://docs.appdynamics.com/display/PRO40/Build+an+Alerting+Extension)
provides ability to surface AppDynamics-generated alerts into external systems. For users that run controller on Windows, the most logical 
and flexible choice of extensions is using PowerShell scripts. However, AppDynamics alerting extensions on Windows call Windows batch files only.

This extension is designed to provide a starting point to build your own extension. It does so by showing how to pass the call from Windows 
command-line processor to PowerShell and how to parse potentially very long list and variable list of parameters passed to the script.

With this work done, doing something useful like posting event to System Center Operation Manager (SCOM) is left up to you. You can use
Invoke-RestMethod or Invoke-WebRequest to invoke the web service endpoints, or use any other PowerShell commands to forward the event on.

**NOTE:** Because this extension is written in PowerShell, it will work on AppDynamics Controller running on Windows systems only. 
Do not try to run this on Linux systems.

##Installation

1. Download the GenericPowerShellAlerting.zip from the Releases section of this repository 

2. Unzip the GenericPowerShellAlerting.zip file into <CONTROLLER_HOME_DIR>\custom\actions\ . You should have <CONTROLLER_HOME_DIR>\custom\actions\GenericPowerShellAlerting created. 

3. Check if you have custom.xml file in <CONTROLLER_HOME_DIR>\custom\actions\ directory. If yes, add the following xml to the <custom-actions> element.

        ```
            <action>
                 <type>GenericPowerShellAlerting</type>
                 <!-- For windows must invoke .bat files -->
                 <executable>GenericPowerShellAlerting.bat</executable>
            </action>    
        ```
     If you don't have custom.xml already, create one with the below xml content. 
     
     ```
            <custom-actions>
                <action>
                     <type>GenericPowerShellAlerting</type>
                     <!-- For windows must invoke .bat files -->
                     <executable>GenericPowerShellAlerting.bat</executable>
                </action>    
            </custom-actions>
     ```
##Using 
The extension becomes available in AppDynamics controller UI immediately. You can then use it to create Custom Action that can be associated
with health rule violations.

##Debugging
Both GenericPowerShellAlerting.bat and GenericPowerShellAlerting.ps1 produce log files of their execution in the folder they exist. 
The parameters of the event will be logged there too

GenericPowerShellAlerting.ps1 also produces transcript of its execution and parsing.

You can create a health rule with some artificially low threshold of violation, assign this custom action to it, cause violation, and see
the event fire.

To debug without using controller, invoke the batch file or PowerShell file directly with the parameters that simulate your event. 

For example, you can invoke this kind of command:
     ```
     <CONTROLLER_HOME_DIR>\custom\actions\GenericPowerShellAlerting\GenericPowerShellAlerting.bat "Wingtip Toys" "22" "Tue Mar 17 22:58:55 PDT 2015" "1" "ERROR" "GenericPowerShellAlerting" "OnlineStoreGlobal Traffic Is High" "116" "5" "BUSINESS_TRANSACTION" "All Traffic" "419" "1" "APPLICATION_COMPONENT_NODE" "APPDAPPSWIN-OnlineStoreGlobal-WingtipToysWeb" "53" "1" "APPLICATION_COMPONENT_NODE" "APPDAPPSWIN-OnlineStoreGlobal-WingtipToysWeb" "53" "condition 1" "422" "GREATER_THAN" "ABSOLUTE" "3.0" "7.0" "OnlineStoreGlobal Traffic Is High triggered at Tue Mar 17 22:58:55 PDT 2015. This policy was violated because the following conditions were met for the All Traffic Business Transaction for the last 5 minute(s):   For Evaluation Entity: APPDAPPSWIN-OnlineStoreGlobal-WingtipToysWeb Node - condition 1 is greater than 3.0. Observed value = 7.0" "316" "http://APPDCNTR40WIN:8090/controller/#location=APP_INCIDENT_DETAIL&incident=" "POLICY_OPEN_CRITICAL" 
     ```

To construct your own, carefully study [Build an Alerting Extension](https://docs.appdynamics.com/display/PRO40/Build+an+Alerting+Extension) to construct right set of parameters with proper values (some are integers like NUMBER_OF_TRIGGERED_CONDITIONS_PER_EVALUATION_ENTITY that drive 
how many times the loop repeats to parse the other events). 
