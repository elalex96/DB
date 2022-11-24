CREATE TABLE [dbo].[PV_FundesEvaluacion] (
    [IdEvaluacionFundes] INT            IDENTITY (1, 1) NOT NULL,
    [DocEvaluacion]      NVARCHAR (MAX) NULL,
    [Puntaje]            FLOAT (53)     NULL,
    [ProveedorEvaluado]  INT            NULL,
    [ProveedorEvaluador] INT            NULL,
    [UsuarioEvaluador]   INT            NULL,
    [ModificadoEl]       DATETIME       NULL,
    [Activo]             BIT            NULL,
    CONSTRAINT [PK_PV_FundesEvaluacion] PRIMARY KEY CLUSTERED ([IdEvaluacionFundes] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

