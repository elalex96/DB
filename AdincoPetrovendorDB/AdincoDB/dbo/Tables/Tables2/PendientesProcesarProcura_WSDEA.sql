CREATE TABLE [dbo].[PendientesProcesarProcura_WSDEA](
	[IdProcesamiento] [int] IDENTITY(1,1) NOT NULL,
	[IdBitacora] [nvarchar](max) NULL,
	[Procesado] [bit] NULL,
	[ProcesadoEl] [datetime] NULL
 CONSTRAINT [PK_APP_Novedades] PRIMARY KEY CLUSTERED 
(
	[IdProcesamiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO