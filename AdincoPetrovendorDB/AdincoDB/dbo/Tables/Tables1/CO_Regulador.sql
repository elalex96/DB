CREATE TABLE [dbo].[CO_Regulador] (
    [IdRegulador]     INT            IDENTITY (1, 1) NOT NULL,
    [Regulador]       NVARCHAR (MAX) NULL,
    [NombreRegulador] NVARCHAR (MAX) NULL,
    [LogoRegulador]   VARCHAR (MAX)  NULL,
    [AWSDocumentoId]  INT            NULL,
    CONSTRAINT [PK_CO_Regulador] PRIMARY KEY CLUSTERED ([IdRegulador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Regulador_AWS_Documentos] FOREIGN KEY ([AWSDocumentoId]) REFERENCES [dbo].[AWS_Documentos] ([AWSDocumentoId])
);

