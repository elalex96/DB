CREATE TABLE [dbo].[SIPAC_OperacionesComercializacion] (
    [IdOperacionComerializacion] INT           IDENTITY (1, 1) NOT NULL,
    [IDContratistaSIPAC]         NVARCHAR (4)  NULL,
    [IDRegistroFContrato]        NVARCHAR (16) NULL,
    [FechaEvento]                DATE          NULL,
    [NumeroEvento]               INT           NULL,
    [TipoHidrocarburo]           INT           NULL,
    [VolumenHVendido]            FLOAT (53)    NULL,
    [PrecioVentaH]               MONEY         NULL,
    [Fecha]                      DATE          NULL,
    CONSTRAINT [PK_SIPACOperacionesComercializacion] PRIMARY KEY CLUSTERED ([IdOperacionComerializacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

