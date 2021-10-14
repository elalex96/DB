CREATE TABLE [dbo].[CO_Regulador] (
    [IdRegulador]		INT            IDENTITY (1, 1) NOT NULL,
    [Regulador]			NVARCHAR (MAX) NULL,
    [NombreRegulador]	NVARCHAR (MAX) NULL,
    [LogoRegulador]		VARCHAR (MAX)  NULL,
	[AWSDocumentoId]	int
    CONSTRAINT [PK_CO_Regulador] PRIMARY KEY CLUSTERED ([IdRegulador] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
	constraint FK_CO_Regulador_AWS_Documentos foreign key(AWSDocumentoId) references AWS_Documentos(AWSDocumentoId)
);

