CREATE TABLE [dbo].[ME_EnvioEvaluacion] (
    [Contestado]          BIT           NULL,
    [FechaContestado]     SMALLDATETIME NULL,
    [FechaEnvio]          SMALLDATETIME NOT NULL,
    [IdEnvioEvaluacion]   INT           IDENTITY (1, 1) NOT NULL,
    [IdMatrizEvaluacion]  INT           NOT NULL,
    [IdProveedorEvaluado] INT           NOT NULL,
    [IdUsuarioEnviado]    INT           NOT NULL
);

