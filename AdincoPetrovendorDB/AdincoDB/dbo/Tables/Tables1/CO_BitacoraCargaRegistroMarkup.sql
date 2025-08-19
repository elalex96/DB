CREATE TABLE CO_BitacoraCargaRegistroMarkup
        (
			Id INT IDENTITY(1,1),
			IdArchivoAWS INT,
            IdContrato INT,
            CreadoEl DATETIME,
            CreadoPor INT,
			Mensaje VARCHAR(8000),
			DetalleAnalisis VARCHAR(MAX),
			DetalleInsercion VARCHAR(MAX),
			MarkupRegistrado BIT,
			GastosNoEncontrados INT,
			ContieneMarkup INT,
			CorrectosPorActualizar INT
			Constraint PK_CO_BitacoraCargaRegistroMarkup PRIMARY KEY (Id), 
			CONSTRAINT FK_CO_BitacoraCargaRegistroMarkup_AWS_Documentos FOREIGN KEY (IdArchivoAWS) REFERENCES Adinco.dbo.AWS_Documentos (AWSDocumentoId),
			CONSTRAINT FK_CO_BitacoraCargaRegistroMarkup_Contrato FOREIGN KEY (IdContrato) REFERENCES Adinco.dbo.CO_Contrato (IdContrato),
			CONSTRAINT FK_CO_BitacoraCargaRegistroMarkup_CreadoPor FOREIGN KEY (CreadoPor) REFERENCES Adinco.dbo.AP_Usuario (UsuarioID)
        );