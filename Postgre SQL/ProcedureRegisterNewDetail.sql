-- EntitySchemaName {VARCHAR(250)} Object Name
-- DetailSchemaName {VARCHAR(250)} Module JS Schema Detail
-- CardSchemaName {VARCHAR(250)} Module JS Edit Page Detail
-- SchemaName {VARCHAR(250)} Object Title
-- PageCaption {VARCHAR(250)} Caption Detail
CREATE OR REPLACE PROCEDURE public."UsrProcedureRegisterNewDetail" (
	EntitySchemaName VARCHAR(250), 
	DetailSchemaName VARCHAR(250), 
	CardSchemaName VARCHAR(250), 
	SchemaName VARCHAR(250), 
	PageCaption VARCHAR(250)
)
LANGUAGE plpgsql    
AS $$
DECLARE ContactId UUID;
BEGIN
	
	-- Get Supervisor ContactId
	ContactId = (
		SELECT "ContactId" 
		FROM public."SysAdminUnit"
		WHERE "Id" IN (
			SELECT
				UserInRole."SysUserId"
			FROM public."SysUserInRole" UserInRole
			LEFT JOIN public."SysAdminUnit" SysRole ON SysRole."Id" = UserInRole."SysRoleId"
			WHERE SysRole."Name" = 'System administrators'
		)
		ORDER BY "CreatedOn" ASC
		LIMIT 1
	);

	-- Insert SysDetail	
    INSERT INTO public."SysDetail" ("CreatedById", "ModifiedById", "ProcessListeners", "Caption", "DetailSchemaUId", "EntitySchemaUId")
	VALUES (
		ContactId,
		ContactId,
		0,
		SchemaName,
		(
			SELECT "UId" FROM public."SysSchema"
			WHERE "Name" = DetailSchemaName
			LIMIT 1
		),
		(
			SELECT "UId"
			FROM public."SysSchema"
			WHERE "Name" = EntitySchemaName
			LIMIT 1
		)
	);
	
	-- Insert SysModuleEntity	
	INSERT INTO public."SysModuleEntity" ("CreatedById", "ModifiedById", "ProcessListeners", "SysEntitySchemaUId")
	VALUES(
		ContactId,
		ContactId,
		0,
		(
			SELECT "UId"
			FROM public."SysSchema"
			WHERE "Name" = EntitySchemaName
			LIMIT 1
		)
	);
	
	-- Insert SysModuleEdit
	INSERT INTO public."SysModuleEdit" (
		"CreatedById", "ModifiedById", 
		"SysModuleEntityId", "UseModuleDetails", "Position", "HelpContextId", "ProcessListeners",
		"CardSchemaUId", "ActionKindCaption", "ActionKindName", "PageCaption"
	)
	VALUES (
		ContactId,
		ContactId,
		(
			SELECT "Id"
			FROM public."SysModuleEntity"
			WHERE "SysEntitySchemaUId" = (
				SELECT "UId"
				FROM public."SysSchema"
				WHERE "Name" = EntitySchemaName
				LIMIT 1
			)
			LIMIT 1
		),
		TRUE,
		0,
		'',
		0,
		(
			SELECT "UId"
			FROM public."SysSchema"
			WHERE "Name" = CardSchemaName
			LIMIT 1
		),
		'',
		'',
		PageCaption
	);
	
    COMMIT;
END;
$$;

-- EntitySchemaName {VARCHAR(250)} Object Detail
-- DetailSchemaName {VARCHAR(250)} Module JS Schema Detail
-- CardSchemaName {VARCHAR(250)} Module JS Edit Page Detail
-- DetailCaption {VARCHAR(250)} Caption Localizable String di Schema Detail
-- PageCaption {VARCHAR(250)} Caption Detail
-- CALL public."UsrProcedureRegisterNewDetail" ('UsrIbu', 'UsrIbuSchemaDetail', 'UsrIbuPage', 'Ibu Detail', 'Ibu Detail');