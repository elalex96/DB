CREATE TYPE CO_Type_SAPMaterial AS TABLE
(
    [NumeroFila] INT NULL,
    [MaterialDescription] VARCHAR(150) NULL,
    [MaterialLongText] VARCHAR(500) NULL,
    [BaseUnitOfMeasure] VARCHAR(50) NULL,
    [SAPMaterialNumber] VARCHAR(20) NULL,
    [Plant] VARCHAR(15) NULL,
    [KeyLastImport] VARCHAR(50) NULL
);