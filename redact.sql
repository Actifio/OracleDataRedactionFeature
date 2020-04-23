WHENEVER OSERROR EXIT FAILURE
WHENEVER SQLERROR EXIT SQL.SQLCODE
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
END;
/
CREATE USER devuser3 IDENTIFIED BY password;
GRANT CONNECT TO devuser3;
GRANT CREATE SESSION TO devuser3;
GRANT SELECT ON act_rman_user.member TO devuser3;
exit;
