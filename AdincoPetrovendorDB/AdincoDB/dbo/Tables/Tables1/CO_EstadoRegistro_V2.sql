CREATE TABLE [dbo].[CO_EstadoRegistro_V2] (
    [IdEstado]      INT            IDENTITY (10000, 1) NOT NULL,
    [IdClvEstado]   INT            NULL,
    [NombreEstado]  NVARCHAR (MAX) NULL,
    [Descripcion]   NVARCHAR (MAX) NULL,
    [IdContrato]    INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    CONSTRAINT [PK_CO_EstadoRegistro_V2] PRIMARY KEY CLUSTERED ([IdEstado] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_EstadoRegistro_V2_AP_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_EstadoRegistro_V2_AP_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

