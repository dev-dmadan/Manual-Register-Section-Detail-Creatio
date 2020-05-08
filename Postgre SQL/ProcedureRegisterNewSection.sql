-- EntitySchemaName {VARCHAR(250)} Object Name
-- SchemaCaption {VARCHAR(250)} Object Title
-- SectionSchemaName {VARCHAR(250)} Module JS Section Page
-- CardSchemaName {VARCHAR(250)} Module JS Edit Page
-- PageCaption {VARCHAR(250)} Edit Page Section
CREATE OR REPLACE PROCEDURE public."UsrProcedureRegisterNewSection" (
	EntitySchemaName VARCHAR(250),
	SchemaCaption VARCHAR(250),
	SectionSchemaName VARCHAR(250), 
	CardSchemaName VARCHAR(250),
	PageCaption VARCHAR(250)
)
LANGUAGE plpgsql    
AS $$
DECLARE SysSchemaUId UUID;
DECLARE ContactId UUID;
BEGIN
	
	SysSchemaUId = (
		SELECT 
			"UId"
		FROM public."SysSchema"
		WHERE "Name" = EntitySchemaName
		LIMIT 1
	);

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
	
	-- Insert SysModuleEntity	
	INSERT INTO public."SysModuleEntity" (
		"CreatedById", "ModifiedById", "ProcessListeners", "SysEntitySchemaUId"
	)
	VALUES(
		ContactId, ContactId, 0, SysSchemaUId
	);
	
	-- Insert SysModuleEdit
	INSERT INTO public."SysModuleEdit" (
		"CreatedById", "ModifiedById", "ProcessListeners",
		"SysModuleEntityId", 
		"UseModuleDetails", "Position", "HelpContextId",
		"CardSchemaUId",
		"ActionKindCaption", "ActionKindName", "PageCaption", "MiniPageModes"
	)
	VALUES (
		ContactId, ContactId, 0,
		(SELECT "Id" FROM public."SysModuleEntity" WHERE "SysEntitySchemaUId" = SysSchemaUId),
		TRUE, 0, '',
		(SELECT "UId" FROM public."SysSchema" WHERE "Name" = CardSchemaName),
		'New', CardSchemaName, PageCaption, ';;'
	);

	-- Insert SysModule
	INSERT INTO public."SysModule" (
		"CreatedById", "ModifiedById", "ProcessListeners", "Caption",
		"SysModuleEntityId", "FolderModeId", "Code", 
		"HelpContextId", "ModuleHeader", "Attribute", "SectionModuleSchemaUId",
		"SectionSchemaUId", 
		"CardModuleUId", "Image32Id"
	)
	VALUES (
		ContactId, ContactId, 0, SchemaCaption,
		(SELECT "Id" FROM public."SysModuleEntity" WHERE "SysEntitySchemaUId" = SysSchemaUId),
		'b659d704-3955-e011-981f-00155d043204', EntitySchemaName, 
		'', '', '', 'df58589e-26a6-44d1-b8d4-edf1734d02b4',
		(SELECT "UId" FROM public."SysSchema" WHERE "Name" = SectionSchemaName),
		'4e1670dc-10db-4217-929a-669f906e5d75', '026742d9-390c-4778-bc46-9fa85c42677a'
	);
	
    COMMIT;
END;
$$;

-- EntitySchemaName {VARCHAR(250)} Object Name
-- SchemaCaption {VARCHAR(250)} Object Title
-- SectionSchemaName {VARCHAR(250)} Module JS Section Page
-- CardSchemaName {VARCHAR(250)} Module JS Edit Page
-- PageCaption {VARCHAR(250)} Edit Page Section
-- CALL public."UsrProcedureRegisterNewSection" ('UsrAnak', 'Anak', 'UsrAnakSection', 'UsrAnakPage', 'Edit page: "Anak"');