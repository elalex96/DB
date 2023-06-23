CREATE TABLE [dbo].[ENT_BitacoraEliminacionInstancia](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Comentario] [varchar](max) NULL,	
	[ContratoId] [int] NULL,
	[UsuarioId] [int] NULL,
	[FechaEliminacion] [datetime] NULL,
	CONSTRAINT [PK_ENT_BitacoraEliminacionInstancia] PRIMARY KEY CLUSTERED ([Id] ASC)	
)