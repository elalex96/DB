CREATE TABLE [dbo].[CO_Contrato] (
    [IdContrato]               INT            IDENTITY (10000, 1) NOT NULL,
    [NumeroContrato]           NVARCHAR (50)  NOT NULL,
    [DescripcionContrato]      NVARCHAR (MAX) NULL,
    [IdContratista]            INT            NOT NULL,
    [IdAreaContractual]        INT            NOT NULL,
    [IDRegFiducidiario]        NVARCHAR (MAX) NULL,
    [Duracion]                 INT            NULL,
    [FechaFirma]               DATE           NULL,
    [InicioVigencia]           DATE           NULL,
    [FinVigencia]              DATE           NULL,
    [IdTipoContrato]           INT            NULL,
    [ValorRegaliaAdicional]    FLOAT (53)     NULL,
    [IncrementoProgramaMinimo] FLOAT (53)     NULL,
    [CreadoPor]                INT            NULL,
    [CreadoEl]                 DATETIME       NULL,
    [ModificadoPor]            INT            NULL,
    [ModificadoEl]             DATETIME       NULL,
    [Activo]                   BIT            NULL,
    [PorcentajeRecuperacion]   DECIMAL (4, 2) NULL,
    [GasNoAsociado]            BIT            NULL,
    [IsPC]                     INT            NULL,
    [IdUbicacionGeografica]    INT            CONSTRAINT [DF_CO_Contrato_IdUbicacionGeografica] DEFAULT ((1)) NULL,
    [MesPresentacionCGI]       DATE           NULL,
    [IdRonda]                  INT            NULL,
    [IsConsorcio]              BIT            NULL,
    [ParticipacionEstado]      VARCHAR (100)  NULL,
    [FechaArranqueEntregables] DATE           NULL,
    [ContratoFicticio]         BIT            NULL,
    [UsaProcura] BIT NULL, 
    CONSTRAINT [PK_Contratos] PRIMARY KEY CLUSTERED ([IdContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Contrato_AP_Usuario] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_Contrato_CO_TipoContrato] FOREIGN KEY ([IdTipoContrato]) REFERENCES [dbo].[CO_TipoContrato] ([IdTipoContrato]),
    CONSTRAINT [FK_CO_Contrato_EN_Rondas] FOREIGN KEY ([IdRonda]) REFERENCES [dbo].[EN_Rondas] ([idRonda]),
    CONSTRAINT [FK_Contratos_AreasContractuales] FOREIGN KEY ([IdAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual]),
    CONSTRAINT [FK_Contratos_Contratistas] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 Terrestre, 2 Aguas Profundas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CO_Contrato', @level2type = N'COLUMN', @level2name = N'IdUbicacionGeografica';

