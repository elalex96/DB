CREATE TABLE [dbo].[PendientesProcesarProcura_WSDEA] (
    [IdProcesamiento] INT            IDENTITY (1, 1) NOT NULL,
    [IdBitacora]      NVARCHAR (MAX) NULL,
    [Procesado]       BIT            NULL,
    [ProcesadoEl]     DATETIME       NULL,
    CONSTRAINT [PK_APP_Novedades] PRIMARY KEY CLUSTERED ([IdProcesamiento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

