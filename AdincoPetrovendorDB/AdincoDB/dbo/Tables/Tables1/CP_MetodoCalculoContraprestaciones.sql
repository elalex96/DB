CREATE TABLE [dbo].[CP_MetodoCalculoContraprestaciones] (
    [IdMetodoCalculoContraprestaciones] INT            IDENTITY (10000, 1) NOT NULL,
    [IdTipoContrato]                    INT            NULL,
    [MetodoCalculo]                     INT            NULL,
    [Metodo]                            NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CP_MetodoCalculoContraprestaciones] PRIMARY KEY CLUSTERED ([IdMetodoCalculoContraprestaciones] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

