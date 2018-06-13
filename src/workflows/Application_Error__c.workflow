<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Application_Error_Notify</fullName>
        <ccEmails>vheragu@opfocus.com</ccEmails>
        <description>Application Error Notify</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Application_Error_Notify</template>
    </alerts>
    <rules>
        <fullName>Application Error Notify</fullName>
        <actions>
            <name>Application_Error_Notify</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application_Error__c.Log_Level__c</field>
            <operation>equals</operation>
            <value>ERROR</value>
        </criteriaItems>
        <description>Send email when an application error is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
