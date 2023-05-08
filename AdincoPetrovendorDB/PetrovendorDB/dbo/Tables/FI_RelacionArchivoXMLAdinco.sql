CREATE TABLE [dbo].[FI_RelacionArchivoXMLAdinco] (
    [IdRelacionArchivoXMLAdinco] INT            IDENTITY (1, 1) NOT NULL,
    [IdArchivoXML]               INT            NOT NULL,
    [IdArchivoXMLAdinco]         INT            NOT NULL,
    [Observacion]                NVARCHAR (MAX) NULL,
    [CreadoEl]                   DATETIME       NULL,
    [EditadoEl]                  DATETIME       NULL,
    CONSTRAINT [PK_FI_RelacionArchivoXMLAdinco] PRIMARY KEY CLUSTERED ([IdRelacionArchivoXMLAdinco] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_RelacionArchivoXMLAdinco_FI_ArchivoXml] FOREIGN KEY ([IdArchivoXML]) REFERENCES [dbo].[FI_ArchivoXml] ([IdArchivoXml])
);

