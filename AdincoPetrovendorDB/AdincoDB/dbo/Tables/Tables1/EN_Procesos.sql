CREATE TABLE [dbo].[EN_Procesos] (
    [IdProceso]       INT            IDENTITY (10000, 1) NOT NULL,
    [NombreProceso]   VARCHAR (1000) NULL,
    [Descripcion]     VARCHAR (3000) NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEl]        DATETIME       NULL,
    [ModificadoPor]   INT            NULL,
    [ModificadoEl]    DATETIME       NULL,
    [Activo]          BIT            NULL,
    [idTipoProceso]   INT            NULL,
    [IdInstalacion]   INT            NULL,
    [IsProcesoEvento] BIT            NULL,
    [IsSerie]         BIT            NULL,
    [Clave]           VARCHAR (MAX)  NULL,
    [EtapaPozoId]   INT            NULL,
    CONSTRAINT [PK_procesos] PRIMARY KEY CLUSTERED ([IdProceso] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Proceso_Instalacion] FOREIGN KEY ([IdInstalacion]) REFERENCES [dbo].[CO_Instalacion] ([IdInstalacion]),
    CONSTRAINT [FK_EN_TipoProcesos_EN_procesos] FOREIGN KEY ([idTipoProceso]) REFERENCES [dbo].[EN_TipoProcesos] ([idTipoProceso]),
    CONSTRAINT [FK_Procesos_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_Procesos_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

