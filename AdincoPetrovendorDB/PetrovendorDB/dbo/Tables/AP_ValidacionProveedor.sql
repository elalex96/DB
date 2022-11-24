CREATE TABLE [dbo].[AP_ValidacionProveedor] (
    [IdProveedor]            INT NULL,
    [EstatusDocumento]       BIT NULL,
    [IdValidacionDocumentos] INT IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_AP_ValidacionProveedor] PRIMARY KEY CLUSTERED ([IdValidacionDocumentos] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

