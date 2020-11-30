CREATE TABLE [dbo].[CO_SAPPRESES] (
    [IdPRESES]             INT            IDENTITY (1, 1) NOT NULL,
    [SAPPONumber]          VARCHAR (20)   NULL,
    [SAPVendorNumber]      VARCHAR (20)   NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEl]             DATETIME       NULL,
    [IdEstatus]            INT            NULL,
    [ItemNumber]           TINYINT        NULL,
    [Justificacion]        NVARCHAR (MAX) NULL,
    [ModificadoEl]         DATETIME       NULL,
    [ModificadoPor]        INT            NULL,
    [SAPSESNumber]         NVARCHAR (50)  NULL,
    [MontoTotalPrefactura] MONEY          NULL,
    [Plant]                VARCHAR (10)   NULL,
    [SESN]                 NVARCHAR (50)  NULL,
    [ComentarioInterno]    VARCHAR (MAX)  NULL,
    [MatDocN]              VARCHAR (50)   NULL,
    CONSTRAINT [PK_CO_SAPPRESES] PRIMARY KEY CLUSTERED ([IdPRESES] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

