CREATE TABLE [dbo].[CO_AreaContractual] (
    [IdAreaContractual]      INT            IDENTITY (10000, 1) NOT NULL,
    [IdAreaContractualPemex] NVARCHAR (MAX) NULL,
    [NombreAreaContractual]  NVARCHAR (MAX) NOT NULL,
    [Descripcion]            NVARCHAR (MAX) NULL,
    [SuperficieKm2]          FLOAT (53)     NULL,
    [IdRegion]               INT            NULL,
    [IdUsuarioCreadoPor]     INT            NULL,
    [Creado]                 DATETIME       NULL,
    [IdUsuarioModPor]        INT            NULL,
    [Modificado]             DATETIME       NULL,
    [Activo]                 BIT            NULL,
    [IdActivo]               INT            NULL,
    [IdUbicacionAC]          INT            NULL,
    [IdEstado]               INT            NULL,
    [CreadoPor]              INT            NULL,
    CONSTRAINT [PK_AreasContractuales] PRIMARY KEY CLUSTERED ([IdAreaContractual] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_AreaContractual_CO_ActivoCNH] FOREIGN KEY ([IdActivo]) REFERENCES [dbo].[CO_ActivoCNH] ([IdActivo]),
    CONSTRAINT [FK_CO_AreaContractual_CO_Region] FOREIGN KEY ([IdRegion]) REFERENCES [dbo].[CO_Region] ([IdRegion]),
    CONSTRAINT [FK_CO_AreaContractual_CO_UbicacionAC] FOREIGN KEY ([IdUbicacionAC]) REFERENCES [dbo].[CO_UbicacionAC] ([IdUbicacionAC]),
    CONSTRAINT [FK_CO_AreaContractual_PV_EstadoRepublica] FOREIGN KEY ([IdEstado]) REFERENCES [dbo].[PV_EstadoRepublica] ([idEstado])
);

