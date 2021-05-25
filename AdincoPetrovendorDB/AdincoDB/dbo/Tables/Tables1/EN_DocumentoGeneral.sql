
CREATE TABLE [dbo].[EN_DocumentoGeneral](
	[DocumentoId] [int] NOT NULL IDENTITY(1,1),
	[NivelPadre] [int] NULL,
	[ContratoId] [int] NULL,
	[EtapaId] [int] NULL,
	[ReceptorId] [int] NULL,
	[InstalacionId] [int] NULL,
	[EtapaPozoId] [int] NULL,
	[MarcoLegalId] [int] NULL,
	[EntregableId] [int] NULL,
	[Bucket] [nvarchar](max) NULL,
	[Folder] [nvarchar](max) NULL,
	[UUIDAmazon] [uniqueidentifier] NULL,
	[NombreArchivo] [nvarchar](max) NULL,
	[Meta] [nvarchar](max) NULL,
	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
	[Activo] [bit] NULL,
	[TipoArchivo] [nvarchar](100) NULL,
	[SizeBytes] [decimal] NULL,
	[Comentarios] [nvarchar](max) NULL,
 CONSTRAINT [PK_EN_DocumentoGeneral] PRIMARY KEY CLUSTERED 
(
	[DocumentoId] ASC
),
CONSTRAINT FK_EN_DocumentoGeneral_CO_Contrato
FOREIGN KEY (ContratoId) REFERENCES CO_Contrato(IdContrato))
