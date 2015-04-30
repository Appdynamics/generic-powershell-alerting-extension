<#
**
 * Copyright 2015 AppDynamics
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#>
#---------------------------------------------------------------------
# Sample script in PowerShell to parse AppDynamics alert parameters
# Parameter parsing logic is based on https://github.com/Appdynamics/snmptrap-alerting-extension/blob/master/src/main/java/com/appdynamics/snmp/SNMPTrapSender.java

#---------------------------------------------------------------------
# Script begins
$scriptFolderPath = Split-Path -Path $MyInvocation.MyCommand.Path

#---------------------------------------------------------------------
# Configure logging
$startTime = [System.DateTime]::Now.ToString("yyyyMMdd-HHmmss")
$logDirPath = $scriptFolderPath
$logFilePath = Join-Path -Path $logDirPath -ChildPath "GenericPowerShellAlerting.$startTime.ps1.log"

try
{
    #---------------------------------------------------------------------
    # Start logging
    Start-Transcript -Path $logFilePath -Append
    Write-Output "GenericPowerShellAlerting.ps1 has been started from '$scriptFolderPath'"
    Write-Output "Logging the script to '$logFilePath'"
    
    #---------------------------------------------------------------------
    # Define variables to hold parsed parameters
    
    # Health rule violation
    $healthRuleParameters = @{
        "APP_NAME" = "";
        "APP_ID" = "";
        "PVN_ALERT_TIME" = "";
        "PRIORITY" = "";
        "SEVERITY" = "";
        "TAG" = "";
        "HEALTH_RULE_NAME" = "";
        "HEALTH_RULE_ID" = "";
        "PVN_TIME_PERIOD_IN_MINUTES" = "";
        "AFFECTED_ENTITY_TYPE" = "";
        "AFFECTED_ENTITY_NAME" = "";
        "AFFECTED_ENTITY_ID" = "";
        "NUMBER_OF_EVALUATION_ENTITIES" = "";
        "NUMBER_OF_TRIGGERED_CONDITIONS_PER_EVALUATION_ENTITY" = "";
        "SUMMARY_MESSAGE" = "";
        "INCIDENT_ID" = "";
        "DEEP_LINK_URL" = "";
        "EVENT_TYPE" = "";
        "APP_DESCRIPTION" = ""
    }

    # Groups of parameters for health rule violation
    $evaluationEntityColl = @()
    $triggeredConditionColl = @()
    
    # Non-health rule violation
    $eventParameters = @{
        "APP_NAME" = "";
        "APP_ID" = "";
        "EN_TIME" = "";
        "PRIORITY" = "";
        "SEVERITY" = "";
        "TAG" = "";
        "EN_NAME" = "";
        "EN_ID" = "";
        "EN_INTERVAL_IN_MINUTES" = "";
        "NUMBER_OF_EVENT_TYPES" = "";
        "NUMBER_OF_EVENT_SUMMARIES" = "";
        "DEEP_LINK_URL" = ""
    }    

    # Groups of parameters for non-health rule violation
    $eventTypeColl = @()
    $eventSummaryColl = @()

    $isHealthRuleViolation = $false
    [int]$param = 0

    Write-Output "Arguments passed:"
    Write-Output $script:args
    
    #---------------------------------------------------------------------
    # Is this a health rule violation event or not?
    # This is done by checking whether the last parameter is DEEP_LINK_URL containing http:// or https://

    if ($script:args[$script:args.Length-1].StartsWith("http") -eq $true) 
    {
        #---------------------------------------------------------------------
        # Not a health rule violation
        $isHealthRuleViolation = $false
        
        # Parse parameter by their ordinal position
        $eventParameters["APP_NAME"] = $script:args[$param++]
        $eventParameters["APP_ID"] = $script:args[$param++]
        $eventParameters["EN_TIME"] = $script:args[$param++]
        $eventParameters["PRIORITY"] = $script:args[$param++]
        $eventParameters["SEVERITY"] = $script:args[$param++]
        $eventParameters["TAG"] = $script:args[$param++]
        $eventParameters["EN_NAME"] = $script:args[$param++]
        $eventParameters["EN_ID"] = $script:args[$param++]
        $eventParameters["EN_INTERVAL_IN_MINUTES"] = $script:args[$param++]

        # Parse groups of the repeating parameters based on number of NUMBER_OF_EVENT_TYPES
        $eventParameters["NUMBER_OF_EVENT_TYPES"] = $script:args[$param++]
        for ($i=0; $i -le $healthRuleParameters["NUMBER_OF_EVENT_TYPES"] - 1; $i++)
        {
            $eventType = @{
                "EVENT_TYPE" = "";
                "EVENT_TYPE_NUM" = ""
            }
        
            $eventType["EVENT_TYPE"] = $script:args[$param++]
            $eventType["EVENT_TYPE_NUM"] = $script:args[$param++]
            
            $eventTypeColl += $eventType
        }
        
        # Parse groups of the repeating parameters based on number of NUMBER_OF_EVENT_SUMMARIES
        $eventParameters["NUMBER_OF_EVENT_SUMMARIES"] = $script:args[$param++]
        for ($i=0; $i -le $healthRuleParameters["NUMBER_OF_EVENT_SUMMARIES"] - 1; $i++)
        {
            $eventSummary = @{
                "EVENT_SUMMARY_ID" = "";
                "EVENT_SUMMARY_TIME" = "";
                "EVENT_SUMMARY_TYPE" = "";
                "EVENT_SUMMARY_SEVERITY" = "";
                "EVENT_SUMMARY_STRING" = ""
            }
            
            $eventSummary["EVENT_SUMMARY_ID"] = $script:args[$param++]
            $eventSummary["EVENT_SUMMARY_TIME"] = $script:args[$param++]
            $eventSummary["EVENT_SUMMARY_TYPE"] = $script:args[$param++]
            $eventSummary["EVENT_SUMMARY_SEVERITY"] = $script:args[$param++]
            $eventSummary["EVENT_SUMMARY_STRING"] = $script:args[$param++]
            
            $eventSummaryColl += $eventSummary
        }
        
        $eventParameters["DEEP_LINK_URL"] = $script:args[$param++]

        Write-Output "eventParameters parsed:"
        $eventParameters
        Write-Output "eventTypeColl parsed $($eventTypeColl.Count) groups:"
        $eventTypeColl
        Write-Output "eventSummaryColl parsed $($eventSummaryColl.Count) groups:"
        $eventSummaryColl
    }
    else
    {
        #---------------------------------------------------------------------
        # Health rule violation
        $isHealthRuleViolation = $true
        
        # Parse parameter by their ordinal position
        $healthRuleParameters["APP_NAME"] = $script:args[$param++]
        $healthRuleParameters["APP_ID"] = $script:args[$param++]
        $healthRuleParameters["PVN_ALERT_TIME"] = $script:args[$param++]
        $healthRuleParameters["PRIORITY"] = $script:args[$param++]
        $healthRuleParameters["SEVERITY"] = $script:args[$param++]
        $healthRuleParameters["TAG"] = $script:args[$param++]
        $healthRuleParameters["HEALTH_RULE_NAME"] = $script:args[$param++]
        $healthRuleParameters["HEALTH_RULE_ID"] = $script:args[$param++]
        $healthRuleParameters["PVN_TIME_PERIOD_IN_MINUTES"] = $script:args[$param++]
        $healthRuleParameters["AFFECTED_ENTITY_TYPE"] = $script:args[$param++]
        $healthRuleParameters["AFFECTED_ENTITY_NAME"] = $script:args[$param++]
        $healthRuleParameters["AFFECTED_ENTITY_ID"] = $script:args[$param++]

        # Parse groups of the repeating parameters based on number of NUMBER_OF_EVALUATION_ENTITIES
        $healthRuleParameters["NUMBER_OF_EVALUATION_ENTITIES"] = $script:args[$param++]
        for ($i=0; $i -le $healthRuleParameters["NUMBER_OF_EVALUATION_ENTITIES"] - 1; $i++)
        {
            $evaluationEntity = @{
                "EVALUATION_ENTITY_TYPE" = "";
                "EVALUATION_ENTITY_NAME" = "";
                "EVALUATION_ENTITY_ID" = ""
            }
        
            $evaluationEntity["EVALUATION_ENTITY_TYPE"] = $script:args[$param++]
            $evaluationEntity["EVALUATION_ENTITY_NAME"] = $script:args[$param++]
            $evaluationEntity["EVALUATION_ENTITY_ID"] = $script:args[$param++]
            
            $evaluationEntityColl += $evaluationEntity
        }
                
        # Parse groups of the repeating parameters based on number of NUMBER_OF_TRIGGERED_CONDITIONS_PER_EVALUATION_ENTITY
        $healthRuleParameters["NUMBER_OF_TRIGGERED_CONDITIONS_PER_EVALUATION_ENTITY"] = $script:args[$param++]
        for ($i=0; $i -le $healthRuleParameters["NUMBER_OF_TRIGGERED_CONDITIONS_PER_EVALUATION_ENTITY"] - 1; $i++)
        {
            $triggeredCondition = @{
                "SCOPE_TYPE" = "";
                "SCOPE_NAME" = "";
                "SCOPE_ID" = "";
                "CONDITION_NAME" = "";
                "CONDITION_ID" = "";
                "OPERATOR" = "";
                "CONDITION_UNIT_TYPE" = "";
                "USE_DEFAULT_BASELINE" = "";
                "BASELINE_NAME" = "";
                "BASELINE_ID" = "";
                "THRESHOLD_VALUE" = "";
                "OBSERVED_VALUE" = "";
                "TIER_DESCRIPTION" = ""
            }
        
            $triggeredCondition["SCOPE_TYPE"] = $script:args[$param++]
            $triggeredCondition["SCOPE_NAME"] = $script:args[$param++]
            $triggeredCondition["SCOPE_ID"] = $script:args[$param++]
            $triggeredCondition["CONDITION_NAME"] = $script:args[$param++]
            $triggeredCondition["CONDITION_ID"] = $script:args[$param++]
            $triggeredCondition["OPERATOR"] = $script:args[$param++]
            $triggeredCondition["CONDITION_UNIT_TYPE"] = $script:args[$param++]
            if ($triggeredCondition["CONDITION_UNIT_TYPE"].StartsWith("BASELINE") -eq $true)
            {
                $triggeredCondition["USE_DEFAULT_BASELINE"] = $script:args[$param++]
                if ($triggeredCondition["USE_DEFAULT_BASELINE"].ToLower() -eq "false")
                {
                    $triggeredCondition["BASELINE_NAME"] = $script:args[$param++]
                    $triggeredCondition["BASELINE_ID"] = $script:args[$param++]
                }
            }
            $triggeredCondition["THRESHOLD_VALUE"] = $script:args[$param++]
            $triggeredCondition["OBSERVED_VALUE"] = $script:args[$param++]

            $triggeredConditionColl += $triggeredCondition
        }
        
        $healthRuleParameters["SUMMARY_MESSAGE"] = $script:args[$param++]
        $healthRuleParameters["INCIDENT_ID"] = $script:args[$param++]
        $healthRuleParameters["DEEP_LINK_URL"] = $script:args[$param++]
        $healthRuleParameters["EVENT_TYPE"] = $script:args[$param++]
        
        # Parse application description
        $restURL = $healthRuleParameters["DEEP_LINK_URL"].Split('#')[0] + "rest/applications/" + $healthRuleParameters["APP_ID"]
        $headers = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("singularity-agent@customer1:SJ5b2m7d1`$354"))}
        $headers
        Write-Output "Calling REST:"
        $restURL
        $restResults = Invoke-RestMethod -Uri $restURL -Method Get -Headers $headers
        Write-Output "Received from REST:"
        $restResults.InnerXml
        $healthRuleParameters["APP_DESCRIPTION"] = $restResults.applications.application.description
        
        foreach ($triggeredCondition in $triggeredConditionColl)
        {
            if($triggeredCondition["SCOPE_TYPE"] -eq "APPLICATION_COMPONENT")
            {
                $restURL = $healthRuleParameters["DEEP_LINK_URL"].Split('#')[0] + "rest/applications/" + $healthRuleParameters["APP_ID"] + "/tiers/" + $triggeredCondition["SCOPE_ID"]
                Write-Output "Calling REST:"
                $restURL
                $restResults = Invoke-RestMethod -Uri $restURL -Method Get -Headers $headers
                Write-Output "Received from REST:"
                $restResults.InnerXml
                $triggeredCondition["TIER_DESCRIPTION"] = $restResults.tiers.tier.description                
            } 
        }

        Write-Output "healthRuleParameters parsed:"
        $healthRuleParameters
        Write-Output "evaluationEntityColl parsed $($evaluationEntityColl.Count) groups:"
        $evaluationEntityColl
        Write-Output "triggeredConditionColl parsed $($triggeredConditionColl.Count) groups:"
        $triggeredConditionColl
    }

    Write-Output "isHealthRuleViolation=$isHealthRuleViolation"

    # At this point, following variables are now filled from the parameters passed to this script
    # $isHealthRuleViolation
    # $healthRuleParameters
    # $evaluationEntityColl
    # $triggeredConditionColl
    # $eventParameters
    # $eventTypeColl
    # $eventSummaryColl
    # You can turn around and use those variables to log an event in Event Log, post it to SCOM,
    # send it via email (although AppDynamics Controller could have done that for you), or redirect into 
    # some custom external system using web service call using Invoke-RestMethod 
    Write-Output "Now do something useful with these parsed parameters!"
    
}
finally
{
    #---------------------------------------------------------------------
    # End Logging
    Write-Output "GenericPowerShellAlerting.ps1 is done"

    #---------------------------------------------------------------------
    # Stop logging
    Stop-Transcript
}