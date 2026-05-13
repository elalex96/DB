CREATE TABLE [dbo].[SCOC_VolumenPorTarifa] (
    [IdTarifa]           INT        IDENTITY (100, 1) NOT NULL,
    [IdContrato]         INT        NULL,
    [MesReporte]         DATE       NULL,
    [IdTipoHidrocarburo] INT        NULL,
    [Volumen]            FLOAT (53) NULL,
    [Tarifa]             FLOAT (53) NULL
);

