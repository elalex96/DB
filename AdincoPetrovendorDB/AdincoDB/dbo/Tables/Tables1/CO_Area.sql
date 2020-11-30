CREATE TABLE [dbo].[CO_Area] (
    [IdArea]        INT            IDENTITY (1, 1) NOT NULL,
    [NombreArea]    NVARCHAR (MAX) NULL,
    [IdResponsable] INT            NULL,
    [IdUsuario]     INT            NULL,
    [FecMovto]      DATETIME       NULL,
    [IdContrato]    INT            NULL,
    [CreadoPor]     INT            NULL,
    CONSTRAINT [PK_Areas] PRIMARY KEY CLUSTERED ([IdArea] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Areas_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_Areas_Responsables] FOREIGN KEY ([IdResponsable]) REFERENCES [dbo].[CO_Responsable] ([IdResponsable])
);

