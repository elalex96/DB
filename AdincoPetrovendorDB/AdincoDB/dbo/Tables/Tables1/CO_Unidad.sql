CREATE TABLE [dbo].[CO_Unidad] (
    [IdUnidad]   INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato] INT            NULL,
    [Unidad]     NVARCHAR (MAX) NULL,
    [CreadoPor]  INT            NULL,
    CONSTRAINT [PK_CO_Unidad] PRIMARY KEY CLUSTERED ([IdUnidad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Unidad_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

