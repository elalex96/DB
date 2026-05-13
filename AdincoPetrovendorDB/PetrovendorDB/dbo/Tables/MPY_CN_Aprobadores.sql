CREATE TABLE [dbo].[MPY_CN_Aprobadores] (
    [IdAprobador_CN]     INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido] INT            NULL,
    [Nombre]             NVARCHAR (MAX) NULL,
    [Correo]             NVARCHAR (MAX) NULL,
    [EstatusAprobacion]  INT            NULL,
    [Comentario]         NVARCHAR (MAX) NULL,
    [FechaEvaluacion]    DATETIME       NULL,
    CONSTRAINT [PK_MPY_CN_Aprobadores] PRIMARY KEY CLUSTERED ([IdAprobador_CN] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

