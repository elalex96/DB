CREATE TABLE [dbo].[CO_COPADE] (
    [IdCopade]     INT            IDENTITY (1, 1) NOT NULL,
    [IdContrato]   INT            NULL,
    [NumeroCOPADE] INT            NULL,
    [FechaEmision] DATE           NULL,
    [Archivo]      NVARCHAR (255) NULL,
    [Adjunto]      IMAGE          NULL,
    DocumentoId INT,
Activo BIT,
CreadoPor INT,
CreadoEn DATETIME,
ModificadoPor INT NULL,
ModificadoEn DATETIME NULL,
CONSTRAINT FK_AWS_Archivos_COPADE_Archivo FOREIGN KEY (DocumentoId) REFERENCES AWS_Documentos,
CONSTRAINT FK_AP_Usuario_COPADE_CreadoPor FOREIGN KEY (CreadoPor) REFERENCES AP_Usuario,
CONSTRAINT FK_AP_Usuario_COPADE_ModificadoPor FOREIGN KEY (ModificadoPor) REFERENCES AP_Usuario,
CONSTRAINT [PK_COPADE] PRIMARY KEY CLUSTERED ([IdCopade] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
CONSTRAINT [FK_COPADE_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

