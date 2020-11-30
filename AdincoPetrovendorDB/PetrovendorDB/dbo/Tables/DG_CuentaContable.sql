CREATE TABLE [dbo].[DG_CuentaContable] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion] NVARCHAR (200) NULL,
    [Numero]      VARCHAR (MAX)  NULL,
    [IdContrato]  INT            NULL,
    [Activo]      BIT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

