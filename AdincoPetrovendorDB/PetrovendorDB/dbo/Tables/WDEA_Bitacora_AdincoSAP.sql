CREATE TABLE [dbo].[WDEA_Bitacora_AdincoSAP] (
    [Id]                         INT           IDENTITY (1, 1) NOT NULL,
    [Fecha]                      SMALLDATETIME NULL,
    [Mensaje]                    VARCHAR (MAX) NULL,
    [NoConsecutivoProcesamiento] INT           NULL,
    [IdBitacoraLectura]          INT           NULL,
    [IsImportacionExitosa]       BIT           NULL,
    [Purchasing_Document]        VARCHAR (300) NULL,
    CONSTRAINT [PK_WDEA_Bitacora_AdincoSAP] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

