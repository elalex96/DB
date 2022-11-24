CREATE TABLE [dbo].[CO_RegistroLog] (
    [IdRegistroLog]      INT             IDENTITY (1, 1) NOT NULL,
    [IdRegistro]         INT             NULL,
    [IdPrograma]         INT             NULL,
    [IdFactura]          INT             NULL,
    [MontoRegistro]      DECIMAL (18, 4) NULL,
    [InicioEjecucion]    DATE            NULL,
    [FinEjecucion]       DATE            NULL,
    [Comentarios]        NVARCHAR (MAX)  NULL,
    [MesPresentacion]    DATE            NULL,
    [IdEstado]           INT             NULL,
    [IdUsuarioCreadoPor] INT             NULL,
    [IdUsuarioModPor]    INT             NULL,
    [FecMovto]           DATETIME        NULL,
    [IdInstalacion]      INT             NULL,
    [CreadoPor]          INT             NULL,
    CONSTRAINT [PK_RegistrosLog] PRIMARY KEY CLUSTERED ([IdRegistroLog] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

