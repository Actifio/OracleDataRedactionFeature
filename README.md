# OracleDataRedactionFeature

Oracle 12c contains a data redaction feature that allows you to mask the output of select commands without changing the underlying data in the database.

It is documented here:

https://docs.oracle.com/database/121/ARPLS/d_redact.htm#ARPLS73800

This page is also useful:

http://www.dba-oracle.com/t_data_redaction.htm

Lets say we have a SSN in the member table of act_rman_user. We select and can see the data:

```
SQL> select ssn from act_rman_user.member where employee_nbr=167;
SSN
---------
433504465
```

We can mask four digits of the SSN with this policy:

```
DBMS_REDACT.ADD_POLICY(
object_schema       => 'act_rman_user',
object_name         => 'member',
column_name         => 'ssn',
policy_name         => 'redact_cust_ssns3',
function_type       => DBMS_REDACT.PARTIAL,
function_parameters => DBMS_REDACT.REDACT_US_SSN_L4,
expression          => '1=1',
policy_description  => 'Redacts 4 numbers in SS numbers',
column_description  => 'SSN col contains social security number');
END;
/
```
To test it we now create a new limited user:
```
CREATE USER devuser3 IDENTIFIED BY password;
GRANT CONNECT TO devuser3;
GRANT CREATE SESSION TO devuser3;
GRANT SELECT ON act_rman_user.member TO devuser3;
```

We log in as that same user and do the same select and confirm the data is partial redacted by policy:

```
SQL> select ssn from act_rman_user.member where employee_nbr=167;
SSN
---------
433-04-XX
```

Note to remove the policy we can run this command:

```
BEGIN
DBMS_REDACT.DROP_POLICY (
  object_schema                => 'ACT_RMAN_USER',
  object_name                  => 'member',
  policy_name                  => 'redact_cust_ssns3');
END;
/
```

We can automate the redaction of an Actifio Virtual Database by using a workflow:

1. Install workflow.sh into /act/scripts and make it executable.  You will find this here:    https://github.com/Actifio/OracleWorkflowScript/blob/master/workflow.sh

You should not need to edit this file at all.   All variables will be learned during run time.  This is different to the initial version of the script.
1. Install redact.sql into /act/scripts/    Edit the file as needed to create the policies needed.  The user creation section can be removed or retained as needed.
1. Create a workflow to run the workflow.sh script.  The workflow script box needs to contain both the script file and the SQL file, so state both scripts with no paths and a space in between like this:   workflow.sh redact.sql 

When the workflow is run, after creating the Virtual Database the Actifio Connector will run the script to:

1. Set the redaction policy
1. Create a user you can use to test the redaction policy.

To manually test outside a workflow (where the DB is already mounted) do the following as root user:

* Set the username variable, e.g.   export username=oracle
* Set the orahome variable, e.g. export orahome=/home/oracle/app/oracle/product/12.2.0/dbhome_1
* Set databasesid variable (the SID of the Oracle DB), e.g. export databasesid=demodb
* Run the sh script using this syntax (change .sh script and .sql script names to suit): ./workflow.sh test redact.sql
