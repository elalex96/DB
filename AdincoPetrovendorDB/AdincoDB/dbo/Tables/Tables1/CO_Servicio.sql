CREATE TABLE [dbo].[CO_Servicio] (
    [IdServicio]     INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato]     INT            NULL,
    [NombreServicio] NVARCHAR (MAX) NULL,
    [IdUnidad]       INT            NULL,
    [IdUsuario]      INT            NULL,
    [FecMovto]       DATETIME       NULL,
    [Activo]         BIT            NULL,
    [CreadoPor]      INT            NULL,
    CONSTRAINT [PK_Servicios] PRIMARY KEY CLUSTERED ([IdServicio] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Servicios_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_Servicios_Unidades] FOREIGN KEY ([IdUnidad]) REFERENCES [dbo].[CO_Unidad] ([IdUnidad])
);

