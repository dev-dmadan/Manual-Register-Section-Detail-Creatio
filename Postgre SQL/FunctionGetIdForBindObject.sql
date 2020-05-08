CREATE OR REPLACE FUNCTION public."UsrFunctionGetIdForBindObject"(SchemaName VARCHAR(250)) 
RETURNS TABLE(SysDetailId UUID, SysModuleEntityId UUID, SysModuleEditId UUID, SysModule UUID)
AS $$
DECLARE SysSchemaId UUID;
DECLARE SysSchemaUId UUID;
DECLARE SysDetailId_ UUID;
DECLARE SysModuleEntityId_ UUID;
DECLARE SysModuleEditId_ UUID;
DECLARE SysModule_ UUID;
BEGIN
	
	SysSchemaId = (
		SELECT 
			"Id"
		FROM public."SysSchema"
		WHERE "Name" = SchemaName
		LIMIT 1
	);

	SysSchemaUId = (
		SELECT 
			"UId"
		FROM public."SysSchema"
		WHERE "Name" = SchemaName
		LIMIT 1
	);

	SysDetailId_ = (
		SELECT "Id" FROM public."SysDetail" WHERE "EntitySchemaUId" = SysSchemaUId LIMIT 1
	);

	SysModuleEntityId_ = (
		SELECT "Id" FROM public."SysModuleEntity" WHERE "SysEntitySchemaUId" = SysSchemaUId LIMIT 1
	);

	SysModuleEditId_ = (
		SELECT "Id" FROM public."SysModuleEdit" WHERE "SysModuleEntityId" = SysModuleEntityId_ LIMIT 1
	);

	SysModule_ = (
		SELECT "Id" FROM public."SysModule" WHERE "Code" = SchemaName LIMIT 1
	);

	RETURN QUERY
	SELECT SysDetailId_, SysModuleEntityId_, SysModuleEditId_, SysModule_;
END;
$$
LANGUAGE plpgsql;