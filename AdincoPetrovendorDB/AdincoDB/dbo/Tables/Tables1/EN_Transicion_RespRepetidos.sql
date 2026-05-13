CREATE TABLE [dbo].[EN_Transicion_RespRepetidos] (
    [TransicionID]         INT      NOT NULL,
    [ActividadInicialID]   INT      NOT NULL,
    [AccionID]             INT      NOT NULL,
    [SiguienteActividadID] INT      NOT NULL,
    [IdContratoEntregable] INT      NOT NULL,
    [CreadoPor]            INT      NULL,
    [CreadoEn]             DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    [ModificadoEn]         DATETIME NULL,
    [Activo]               BIT      NULL
);

