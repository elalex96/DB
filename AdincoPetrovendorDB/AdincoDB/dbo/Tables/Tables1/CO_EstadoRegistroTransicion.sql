CREATE TABLE [dbo].[CO_EstadoRegistroTransicion] (
    [IdEstadoRegistroTransicion] INT            IDENTITY (10000, 1) NOT NULL,
    [IdEstadoOrigen]             INT            NULL,
    [IdEstadoDestino]            INT            NULL,
    [Descripcion]                NVARCHAR (MAX) NULL,
    [CreadoPor]                  INT            NULL,
    [CreadoEn]                   DATETIME       NULL,
    [ModificadoPor]              INT            NULL,
    [ModificadoEn]               DATETIME       NULL,
    CONSTRAINT [PK_CO_EstadoRegistroTransicion] PRIMARY KEY CLUSTERED ([IdEstadoRegistroTransicion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_EstadoRegistroTransicion_AP_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_EstadoRegistroTransicion_AP_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

