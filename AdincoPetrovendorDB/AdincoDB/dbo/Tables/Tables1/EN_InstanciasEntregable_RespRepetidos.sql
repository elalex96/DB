CREATE TABLE [dbo].[EN_InstanciasEntregable_RespRepetidos] (
    [idInstanciaEntregable]           INT      NOT NULL,
    [FechasLimiteElaboracion]         DATETIME NULL,
    [FechasLimiteRevision]            DATETIME NULL,
    [FechasLimiteAprobacion]          DATETIME NULL,
    [FechaEnvioMensajeAtrasoRevision] DATETIME NULL,
    [idFrecuencua]                    INT      NULL,
    [IdContratoEntregable]            INT      NULL,
    [Estatus]                         INT      NULL,
    [FechaElaboro]                    DATE     NULL,
    [FechaReviso]                     DATE     NULL,
    [FechaAprobo]                     DATE     NULL,
    [CorreoEnviado]                   BIT      NULL,
    [ActividadID]                     INT      NULL,
    [CreadoPor]                       INT      NULL,
    [CreadoEn]                        DATETIME NULL,
    [ModificadoPor]                   INT      NULL,
    [ModificadoEn]                    DATETIME NULL,
    [Activo]                          BIT      NULL,
    [FechaCalculadaEntregaReg]        DATETIME NULL
);

