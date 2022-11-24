CREATE TABLE [dbo].[PV_RelacionProveedorSubcotratista] (
    [IdRelacion]       INT IDENTITY (1, 1) NOT NULL,
    [IdProveedor]      INT NULL,
    [IdSubcontratista] INT NULL,
    PRIMARY KEY CLUSTERED ([IdRelacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

