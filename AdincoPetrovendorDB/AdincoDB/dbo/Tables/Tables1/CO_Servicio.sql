CREATE TABLE [dbo].[CO_Servicio] (
    [IdServicio]     INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato]     INT            NULL,
    [NombreServicio] VARCHAR (8000) NULL,
    [IdUnidad]       INT            NULL,
    [IdUsuario]      INT            NULL,
    [FecMovto]       DATETIME       NULL,
    [Activo]         BIT            NULL,
    [CreadoPor]      INT            NULL,   
    [ModificadoPor]  INT            NULL, 
    [ModificadoEl]   DATETIME       NULL,
    CONSTRAINT [PK_Servicios] PRIMARY KEY CLUSTERED ([IdServicio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Servicios_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_Servicios_Unidades] FOREIGN KEY ([IdUnidad]) REFERENCES [dbo].[CO_Unidad] ([IdUnidad]),
    CONSTRAINT [FK_Servicios_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

