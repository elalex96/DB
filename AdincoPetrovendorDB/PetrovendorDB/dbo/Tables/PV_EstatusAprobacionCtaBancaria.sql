CREATE TABLE [dbo].[PV_EstatusAprobacionCtaBancaria] (
    [IdEstatusCuentaBancaria] INT          IDENTITY (1, 1) NOT NULL,
    [NombreEstatusAprobacion] VARCHAR (50) NULL,
    CONSTRAINT [PK_PV_EstatusAprobacionCtaBancaria] PRIMARY KEY CLUSTERED ([IdEstatusCuentaBancaria] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

