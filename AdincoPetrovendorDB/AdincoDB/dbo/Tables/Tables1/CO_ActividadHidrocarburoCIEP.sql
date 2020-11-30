CREATE TABLE [dbo].[CO_ActividadHidrocarburoCIEP] (
    [IdActividadHidrocarburo]     INT           IDENTITY (1, 1) NOT NULL,
    [ID_CATACTHC]                 INT           NULL,
    [NombreActividadHidrocarburo] NVARCHAR (50) NOT NULL,
    [IdUsuario]                   INT           NULL,
    [FecMovto]                    DATETIME      NULL,
    [IdContrato]                  INT           NULL,
    [CreadoPor]                   INT           NULL,
    CONSTRAINT [PK_ActividadesHidrocarburos] PRIMARY KEY CLUSTERED ([IdActividadHidrocarburo] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ActividadesHidrocarburos_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

