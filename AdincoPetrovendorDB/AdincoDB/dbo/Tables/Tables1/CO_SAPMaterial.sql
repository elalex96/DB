CREATE TABLE [dbo].[CO_SAPMaterial] (
    [IdContrato]          INT           NOT NULL,
    [SAPMaterialNumber]   VARCHAR (20)  NOT NULL,
    [MaterialDescription] VARCHAR (150) NULL,
    [MaterialLongText]    VARCHAR (500) NULL,
    [Unit]                VARCHAR (50)  NULL,
    [CreadoEl]            DATETIME      NULL,
    [CreadoPor]           INT           NULL,
    [Plant]               VARCHAR (15)  NULL,
    [Activo]              BIT           NULL,
    [KeyLastImport]       VARCHAR (50)  NULL,
    CONSTRAINT [PK_CO_MapeoInterfazMaterial_1] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [SAPMaterialNumber] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_MapeoInterfazMaterial_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_MapeoInterfazMaterial_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

