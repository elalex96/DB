CREATE TABLE CO_BitacoraCargaRegistroMarkupDetalle
        (
			Id INT IDENTITY(1,1),
			IdCarga INT,
			FilaExcel INT,
			IdRegistroExcel  VARCHAR(30),
			PorcentajeExcel  VARCHAR(30),
			TipoCambioExcel  VARCHAR(30),
			IdRegistro INT, -- SIN FK DEBIDO A QUE SE PUEDE REGISTRAR X COSA
			Porcentaje FLOAT,
			TipoCambio FLOAT NULL,
			Detalle VARCHAR(MAX),
			Correcto BIT,
			Constraint PK_CO_BitacoraCargaRegistroMarkupDetalle PRIMARY KEY (Id), 
			CONSTRAINT FK_CO_BitacoraCargaRegistroMarkup_Carga FOREIGN KEY (IdCarga) 
			REFERENCES CO_BitacoraCargaRegistroMarkup (Id),
		);
