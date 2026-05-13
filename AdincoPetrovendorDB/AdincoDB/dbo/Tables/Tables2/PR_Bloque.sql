CREATE TABLE [dbo].[PR_Bloque] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [Clave]       NCHAR (10)      NOT NULL,
    [Nombre]      NVARCHAR (100)  NOT NULL,
    [Descripcion] NVARCHAR (1000) CONSTRAINT [DF_Bloque_Descripcion] DEFAULT (N'') NULL,
    [Estatus]     TINYINT         NOT NULL,
    [IdContrato]  INT             NULL,
    CONSTRAINT [PK_PR_Bloque] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

