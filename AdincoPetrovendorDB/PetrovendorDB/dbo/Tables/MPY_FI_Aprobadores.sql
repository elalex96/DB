CREATE TABLE [dbo].[MPY_FI_Aprobadores] (
    [IdAprobador_FI]     INT            IDENTITY (1, 1) NOT NULL,
    [IdAceptacionPedido] INT            NULL,
    [IdProveedor]        NVARCHAR (20)  NULL,
    [Nombre]             NVARCHAR (MAX) NULL,
    [Correo]             NVARCHAR (MAX) NULL,
    [EstatusAprobacion]  INT            NULL,
    [Comentario]         NVARCHAR (MAX) NULL,
    [FechaEvaluacion]    DATETIME       NULL,
    CONSTRAINT [PK_MPY_FI_Aprobadores] PRIMARY KEY CLUSTERED ([IdAprobador_FI] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

