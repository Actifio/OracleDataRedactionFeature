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

We can masking the last four digits with this policy:

```
BEGIN
DBMS_REDACT.ADD_POLICY(
object_schema       => 'act_rman_user',
object_name         => 'member',
column_name         => 'ssn',
policy_name         => 'redact_cust_ssns3',
function_type       => DBMS_REDACT.PARTIAL,
function_parameters => DBMS_REDACT.REDACT_US_SSN_L4,
expression          => '1=1',
policy_description  => 'Redacts last 4 numbers in SS numbers',
column_description  => 'SSN col contains social security number');
END
/
```
We now create a new user:
```
CREATE USER devuser3 IDENTIFIED BY password;
GRANT CONNECT TO devuser3;
GRANT CREATE SESSION TO devuser3;
GRANT SELECT ON act_rman_user.member TO devuser3;
```

When that user does the same select:

```
SQL> select ssn from act_rman_user.member where employee_nbr=167;
SSN
---------
433-04-XX
```

To remove the policy we can run this command:

```
BEGIN
DBMS_REDACT.DROP_POLICY (
  object_schema                => 'ACT_RMAN_USER',
  object_name                  => 'member',
  policy_name                  => 'redact_cust_ssns3');
END;
/
```

We can automate this process in a workflow by:

1)  Install redact.sh into /act/scripts and making it executable.
Edit the file as needed

2)  Install redact.sql into /act/scripts/
Edit the file as needed

3)  Have a workflow run the redact.sh script
