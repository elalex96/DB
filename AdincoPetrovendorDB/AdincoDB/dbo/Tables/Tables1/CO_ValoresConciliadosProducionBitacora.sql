CREATE TABLE [dbo].[CO_ValoresConciliadosProducionBitacora]
(
	 [Id]	                        INT	IDENTITY (1, 1)	NOT NULL,
    [IdValoresConciliadosProducion] INT						NOT NULL,
    [Detalle]				        VARCHAR(MAX)			NULL,	
    [Tipo]				            VARCHAR(MAX)			NOT NULL,	
    [UsuarioID]						INT						NOT NULL,
    [Fecha]						    DATETIME				NOT NULL,    
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdValoresConciliadosProducion]) REFERENCES [dbo].[CO_ValoresConciliadosProducion] ([IdValoresConciliadosProducion]),
	FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);
