CREATE TABLE [dbo].[CO_PropietariosAreaContractual] (
    [IdPropietario]     INT            IDENTITY (10000, 1) NOT NULL,
    [IdAreaContractual] INT            NULL,
    [NombrePropietario] NVARCHAR (500) NULL,
    [KM2]               FLOAT (53)     NULL,
    [FechaIniPago]      DATE           NULL,
    [Bit_Activo]        BIT            NULL,
    [RFC]               NVARCHAR (13)  NULL,
    [Correo]            NVARCHAR (150) NULL,
    [Telefono]          NVARCHAR (15)  NULL,
    [Direccion]         NVARCHAR (250) NULL,
    [MontoRenta]        MONEY          NULL,
    CONSTRAINT [PK_CO_PropietariosAreaContractual] PRIMARY KEY CLUSTERED ([IdPropietario] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PropietariosAreaContractual_CO_AreaContractual] FOREIGN KEY ([IdAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual])
);

