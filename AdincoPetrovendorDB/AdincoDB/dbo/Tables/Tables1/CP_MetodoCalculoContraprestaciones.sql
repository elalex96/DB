CREATE TABLE [dbo].[CP_MetodoCalculoContraprestaciones] (
    [IdMetodoCalculoContraprestaciones] INT            IDENTITY (10000, 1) NOT NULL,
    [IdTipoContrato]                    INT            NULL,
    [MetodoCalculo]                     INT            NULL,
    [Metodo]                            NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CP_MetodoCalculoContraprestaciones] PRIMARY KEY CLUSTERED ([IdMetodoCalculoContraprestaciones] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

