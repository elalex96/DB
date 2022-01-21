CREATE TABLE [dbo].[CO_Instalacion] (
    [IdInstalacion]            INT            IDENTITY (1, 1) NOT NULL,
    [NombreInstalacion]        NVARCHAR (MAX) NULL,
    [IdInstalacionPemex]       NVARCHAR (MAX) NULL,
    [EsBolsa]                  BIT            NULL,
    [IdActividad]              INT            NULL,
    [IdUsuario]                INT            NULL,
    [FecMovto]                 DATETIME       NULL,
    [NombreInstalacionAlterno] NVARCHAR (MAX) NULL,
    [IdCatalogoSCIEP]          INT            NULL,
    [IdAreaContractual]        INT            NULL,
    [Activo]                   BIT            NULL,
    [CUIP]                     NVARCHAR (MAX) NULL,
    [WelIID]                   INT            NULL,
    [IdYacimiento]             INT            NULL,
    [IdCampo]                  INT            NULL,
    [UTMX]                     FLOAT (53)     NULL,
    [UTMY]                     FLOAT (53)     NULL,
    [IdEstatus]                INT            NULL,
    [CreadoPor]                INT            NULL,
    [CreadoEn]                 DATETIME       NULL,
    [ModificadoPor]            INT            NULL,
    [ModificadoEn]             DATETIME       NULL,
    [ComodinBolsa]             BIT            NULL,
    CONSTRAINT [PK_Instalaciones] PRIMARY KEY CLUSTERED ([IdInstalacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__CO_Instal__IdEst__2296B1AB] FOREIGN KEY ([IdEstatus]) REFERENCES [dbo].[CO_EstadoPozos] ([idEstatus]),
    CONSTRAINT [FK__CO_Instal__IdEst__4F344DF8] FOREIGN KEY ([IdEstatus]) REFERENCES [dbo].[CO_EstadoPozos] ([idEstatus]),
    CONSTRAINT [FK_CO_Instalaciones_PD_Campo] FOREIGN KEY ([IdCampo]) REFERENCES [dbo].[PD_Campo] ([IdCampo]),
    CONSTRAINT [FK_Instalaciones_Actividades] FOREIGN KEY ([IdActividad]) REFERENCES [dbo].[CO_ActividadCIEP] ([IdActividad]),
    CONSTRAINT [FK_Instalaciones_AreasContractuales] FOREIGN KEY ([IdAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual]),
    CONSTRAINT [FK_Instalaciones_Usuarios] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_Instalaciones_Yacimiento] FOREIGN KEY ([IdYacimiento]) REFERENCES [dbo].[CO_Yacimiento] ([IdYacimiento])
);

go

create index IX_CO_Instalacion								on	CO_Instalacion(IdInstalacion)