CREATE TABLE [dbo].[AP_NotificacionTareaBitacora](
	[Id] [int]IDENTITY (1, 1) NOT NULL,
	[InicioEjecucion] [datetime] NOT NULL,
	[FinEjecucion] [datetime] NULL,
	[HostNameTarea] [varchar](100) NOT NULL,
	[TareaId] [varchar](15) NOT NULL,
	[TieneError] [bit] NOT NULL,
CONSTRAINT [PK_AP_NotificacionTareaBitacora] PRIMARY KEY CLUSTERED ([Id] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO