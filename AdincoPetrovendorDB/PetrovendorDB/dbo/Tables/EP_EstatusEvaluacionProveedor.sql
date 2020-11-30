CREATE TABLE [dbo].[EP_EstatusEvaluacionProveedor] (
    [IdEstatusEvaluacion] INT            IDENTITY (1, 1) NOT NULL,
    [EstatusEvaluacion]   NVARCHAR (100) NULL,
    CONSTRAINT [PK_EP_EstatusEvaluacionProveedor] PRIMARY KEY CLUSTERED ([IdEstatusEvaluacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

