CREATE TABLE [dbo].[ML_SipacMail] (
    [IdSipacMail]     INT            IDENTITY (10000, 1) NOT NULL,
    [NombreArchivo]   NVARCHAR (250) NULL,
    [ReporteAsociado] NVARCHAR (250) NULL,
    [TipoDocumentos]  NVARCHAR (250) NULL,
    [FechaCarga]      DATETIME       NULL,
    [Estado]          NVARCHAR (250) NULL,
    [ProcesadoMailId] INT            NULL,
    CONSTRAINT [PK_SipacMail] PRIMARY KEY CLUSTERED ([IdSipacMail] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

