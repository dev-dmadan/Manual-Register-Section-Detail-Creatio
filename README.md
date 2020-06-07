# Manual-Register-Section-Detail-Creatio

## Introduction

Mengunakan tool wizard Creatio sangatlah membantu, dan mempercepat proses pembuatan suatu object (section, detail, edit page, dll).

Kekurangan dari tool wizard adalah masalah penamaan yang kurang friendly terutama untuk penamaan schema detail. Selain itu masalah muncul saat melakukan pengembangan lebih dari 1 developer, kadang kali saat melakukan commit/push sering terjadi bentrok karena penamaan dari tool wizard yang sama (biasanya hal ini terjadi di oracle/mssql, karena sistem penamaan menggunakan increment)

Solusi untuk hal tersebut adalah melakukan register object secara manual, berikut tutorialnya. Bahasa SQL yang digunakan adalah **SQL Server (MSSQL DBMS)**, **harap sesuaikan ulang jika menggunakan DBMS yang berbeda seperti Oracle/Postgre**

## Register New Detail

Langkah-langkahnya adalah:
1. Buat "Object" detail, parent object "Base object ( Base )"
2. Buat "Schema" detail, parent object "Base schema - Detail with list ( NUI )"
3. Buat "Edit Page" detail, parent object "BaseModulePageV2 ( NUI )"
4. Tambahkan data baru di "SysDetail"
```sql
-- ContactId            : Contact Id user yang ingin dipakai (Gunakan Contact Id user Supervisor)
-- DetailSchemaCaption  : Title schema detail (Detail schema: "Detail Order")
-- DetailSchemaName     : Nama schema detail (UsrDetailOrderSchemaDetail)
-- EntitySchemaName     : Nama object detail (UsrDetailOrder)

INSERT INTO dbo.SysDetail (
    CreatedById, ModifiedById, ProcessListeners, 
    Caption, DetailSchemaUId, EntitySchemaUId
)
VALUES (
    ContactId,
    ContactId,
    0,
    SchemaCaption,
    (
        SELECT 
            TOP 1 UId 
        FROM dbo.SysSchema
        WHERE 
            Name = DetailSchemaName
    ),
    (
        SELECT 
            TOP 1 UId
        FROM dbo.SysSchema
        WHERE 
            Name = EntitySchemaName
    )
);
```
5. Tambahkan data baru di "SysModuleEntity"
```sql
-- ContactId        : Contact Id user yang ingin dipakai (Gunakan Contact Id user Supervisor)
-- EntitySchemaName : Nama object detail (UsrDetailOrder)

INSERT INTO dbo.SysModuleEntity (
    CreatedById, ModifiedById, ProcessListeners, 
    SysEntitySchemaUId
)
VALUES(
    ContactId,
    ContactId,
    0,
    (
        SELECT 
            TOP 1 UId
        FROM dbo.SysSchema
        WHERE 
            Name = EntitySchemaName
    )
);
```
6. Tambahkan data baru di "SysModuleEdit"
```sql
-- ContactId            : Contact Id user yang ingin dipakai (Gunakan Contact Id user Supervisor)
-- EntitySchemaName     : Nama object detail (UsrDetailOrder)
-- CardSchemaName       : Nama schema open edit page detail (UsrDetailOrder1Page)
-- CardSchemaCaption    : Title schema open edit page detail (Edit page: "Detail Order")

INSERT INTO dbo.SysModuleEdit (
    CreatedById, ModifiedById, ProcessListeners,
    SysModuleEntityId, UseModuleDetails, Position, HelpContextId,
    CardSchemaUId, ActionKindCaption, ActionKindName, PageCaption, MiniPageModes
)
VALUES (
    ContactId,
    ContactId,
    0,
    (
        SELECT 
            TOP 1 Id
        FROM dbo.SysModuleEntity
        WHERE SysEntitySchemaUId = (
            SELECT 
                TOP 1 UId
            FROM dbo.SysSchema
            WHERE 
                Name = EntitySchemaName
        )
    ),
    1,
    0,
    '',
    (
        SELECT 
            TOP 1 UId
        FROM dbo.SysSchema
        WHERE 
            Name = CardSchemaName
    ),
    'New',
    CardSchemaName,
    CardSchemaCaption,
    ';;'
);
```
7. Binding data Id "SysDetail", Id "SysModuleEntity", dan Id "SysModuleEdit" yang baru saja ditambahkan

## Register New Detail from Section

Jika sebuah object sudah berbentuk section saat pertama kali, dan ingin dijadikan sebuah detail, maka hanya cukup melakukan penambahan data di "SysDetail" saja.

```sql
-- ContactId            : Contact Id user yang ingin dipakai (Gunakan Contact Id user Supervisor)
-- DetailSchemaCaption  : Title schema detail (Detail schema: "Detail Order")
-- DetailSchemaName     : Nama schema detail (UsrDetailOrderSchemaDetail)
-- EntitySchemaName     : Nama object detail (UsrDetailOrder)

INSERT INTO dbo.SysDetail (
    CreatedById, ModifiedById, ProcessListeners, 
    Caption, DetailSchemaUId, EntitySchemaUId
)
VALUES (
    ContactId,
    ContactId,
    0,
    DetailSchemaCaption,
    (
        SELECT 
            TOP 1 UId 
        FROM dbo.SysSchema
        WHERE 
            Name = DetailSchemaName
    ),
    (
        SELECT 
            TOP 1 UId
        FROM dbo.SysSchema
        WHERE 
            Name = EntitySchemaName
    )
);
```
Setelah itu lakukan binding data Id "SysDetail".

## Get Binding Data

Untuk mendapatkan Id "SysDetail", Id "SysModuleEntity", Id "SysModuleEdit", dan Id "SysModule" untuk keperluan binding data dapat dilakukan dengan cara berikut:

1. Tentukan object yang ingin dibinding, contoh: UsrDetailOrder
2. Dapatkan nilai Id, dan UId "SysSchema" dari object yang ingin di binding. Kedua data ini dibutuhkan untuk mendapatkan Id "SysDetail", Id "SysModuleEntity", Id "SysModuleEdit", dan Id "SysModule"
```sql
-- EntitySchemaName : Nama object (UsrDetailOrder)

-- Get Id
SELECT 
    TOP 1 Id, UId
FROM dbo.SysSchema
WHERE 
    Name = EntitySchemaName
```
3. Dapatkan nilai Id "SysDetail"
```sql
-- SysSchemaUId : UId SysSchema

SELECT 
    TOP 1 Id
FROM dbo.SysDetail
WHERE 
    EntitySchemaUId = SysSchemaUId

```
4. Dapatkan nilai Id "SysModuleEntity"
```sql
-- SysSchemaUId : UId SysSchema

SELECT 
    TOP 1 Id 
FROM dbo.SysModuleEntity 
WHERE 
    SysEntitySchemaUId = SysSchemaUId
```
5. Dapatkan nilai Id "SysModuleEdit"
```sql
-- SysModuleEntityId : Id SysModuleEntity yang ada di No. 4

SELECT 
    TOP 1 Id 
FROM dbo.SysModuleEdit 
WHERE 
    SysModuleEntityId = SysModuleEntityId
```
6. Dapatkan nilai Id "SysModule"
```sql
-- EntitySchemaName : Nama object (UsrDetailOrder)

SELECT 
    TOP 1 Id 
FROM dbo.SysModule 
WHERE 
    Code = EntitySchemaName
```

## Register detail menggunakan Procedure

Penjelasan diatas adalah konsep atau hal-hal dasar yang harus dilakukan untuk melakukan registrati detail, disini saya membuat sebuah procedure untuk mempermudah melakukan hal-hal diatas menjadi sangat simple.

Pada repository ini terdapat folder yang namanya sesuai dengan DBMS yang akan digunakan, didalamnya terdapat beberapa procedure dan function yaitu:
- Procedure registrati detail   : ProcedureRegisterNewDetail.sql
- Function get Id Binding data  : FunctionGetIdForBindObject.sql

### Procedure registrasi detail

> Coming soon

<!-- Procedure ini berfungsi untuk melakukan registrasi detail secara otomatis, cukup memasukan beberapa data ke parameter yang disediakan, maka detail akan langsung terdaftar ke Creatio, dan dapat digunakan.
**Pastikan Object detail, Schema detail, dan Edit Page detail sudah dibuat terlebih dahulu (Step No. 1 s.d 3 pada sesi Register New Detail)**

Berikut cara penggunaannya:
```sql
EXECUTE dbo.UsrProcedureRegisterNewDetail;
``` -->

### Function get Id Binding data

> Coming soon