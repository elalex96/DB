IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CO_RegistraBitacoraCargaRegistroMarkup'
    )
    DROP PROCEDURE USP_INS_CO_RegistraBitacoraCargaRegistroMarkup;
GO
CREATE PROCEDURE [dbo].[USP_INS_CO_RegistraBitacoraCargaRegistroMarkup]
@IdUsuario            INT = 0,
@IdContrato            INT,
@IdContratoSeleccionado   INT,
@Mensaje VARCHAR(MAX) = '',
@IdArchivo   INT = 0,
@Filas CO_Type_BitacoraCargaRegistroMarkupDetalle READONLY
AS
BEGIN
CREATE TABLE #FilasRegistros(
		FilaExcel INT,
		IdRegistroExcel  VARCHAR(30),
		PorcentajeExcel  VARCHAR(30),
		TipoCambioExcel  VARCHAR(30),
		IdRegistro INT,
		Porcentaje FLOAT,
		TipoCambio DECIMAL(15,4) NULL,
		MontoRegistro FLOAT,
		Observacion VARCHAR(MAX),
		IdFactura INT,
		IdPedimentoComprobante INT, 
		IdContrato INT,
		ContieneMarkupAnterior BIT,
		ContieneMarkupAnteriorEnCero BIT,
		GastoEncontrado BIT);

	DECLARE @IdCarga INT = 0, @GastosNoEncontrados INT = 0, @ContieneMarkup INT = 0, @PorActualizar INT  = 0, @AlertasImportacion VARCHAR(MAX);

	INSERT INTO #FilasRegistros(
		FilaExcel,
		IdRegistroExcel,
		PorcentajeExcel,
		TipoCambioExcel ,
		IdRegistro,
		Porcentaje,
		TipoCambio,
		Observacion,
		GastoEncontrado)
	SELECT 
		FilaExcel,
		IdRegistroExcel,
		PorcentajeExcel,
		TipoCambioExcel ,
		CASE
		WHEN ISNUMERIC(IdRegistroExcel) =  1
		THEN
			IdRegistroExcel
		ELSE 0
		END,
		CASE
		WHEN ISNUMERIC(PorcentajeExcel) =  1
		THEN
			PorcentajeExcel
		ELSE 0
		END,
		CASE
		WHEN ISNUMERIC(TipoCambioExcel) =  1
		THEN
			CAST(TipoCambioExcel  AS DECIMAL(15, 4))
		ELSE NULL
		END,
		CONCAT(
		(
		CASE 
			WHEN LEN(IdRegistroExcel) =  0
			THEN '[El IdRegistro es obligatorío], '
			ELSE 
			CASE 
			WHEN ISNUMERIC(IdRegistroExcel) =  0
			THEN
				CONCAT('[El IdRegistro (',LTRIM(IdRegistroExcel),') no es un número entero], ')
			END
			END),
			(CASE 
			WHEN LEN(PorcentajeExcel) =  0
			THEN '[El Porcentaje es obligatorío], '
			ELSE 
			CASE 
			WHEN ISNUMERIC(PorcentajeExcel) =  0
			THEN
				CONCAT('[El Porcentaje (',LTRIM(PorcentajeExcel),') no es un número], ')
			END
			END
			)
		),
		1
    FROM @Filas;

	UPDATE 
		FR
		SET FR.IdFactura = CO_Registro.IdFactura,
		FR.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante,
		FR.MontoRegistro = CO_Registro.MontoRegistro
	FROM 
		#FilasRegistros	FR
	JOIN
		CO_Registro ON 
		FR.IdRegistro =	CO_Registro.IdRegistro
		AND FR.IdRegistro > 0

	
	UPDATE 
		FR
		SET FR.ContieneMarkupAnterior = 1,
			FR.ContieneMarkupAnteriorEnCero =
			CASE 
			WHEN CO_RegistroMarkup.Porcentaje = 0
			THEN 
				1
			ELSE 
				0
		END
	FROM 
		#FilasRegistros	FR
	JOIN
		CO_RegistroMarkup ON 
		FR.IdRegistro =	CO_RegistroMarkup.GastoId
		AND FR.IdRegistro > 0;

	UPDATE 
		FR
		SET FR.IdContrato = FI_Factura.IdContrato
	FROM 
		#FilasRegistros	FR
	JOIN
		FI_Factura 
		ON FR.IdFactura	=	FI_Factura.IdFactura;

	UPDATE 
		FR
		SET FR.IdContrato = FI_PedimentoComprobante.IdContrato
	FROM 
		#FilasRegistros	FR
	JOIN
		FI_PedimentoComprobante 
		ON FR.IdPedimentoComprobante	=	FI_PedimentoComprobante.IdPedimentoComprobante;

	UPDATE 
		FR
	SET FR.Observacion	=	CONCAT(FR.Observacion,' [No existe un Gasto con IdRegistro (',LTRIM(IdRegistroExcel),') asignado]'),
	FR.GastoEncontrado = 0
	FROM
		#FilasRegistros FR
	WHERE 
		FR.IdFactura IS NULL 
	AND 
		FR.IdPedimentoComprobante  IS NULL 

	UPDATE 
		FR
	SET FR.Observacion	=	CONCAT(FR.Observacion,' [El Gasto con IdRegistro (',LTRIM(IdRegistroExcel),') no se encuentra en el contrato seleccionado]'),
	FR.GastoEncontrado = 0
	FROM
		#FilasRegistros FR
	WHERE 
		FR.IdContrato <> @IdContratoSeleccionado;

	UPDATE 
		FR
	SET FR.Observacion	=	CONCAT(FR.Observacion,' [El Gasto con IdRegistro (',LTRIM(IdRegistroExcel),') ya contiene un Markup registrado]')
	FROM
		#FilasRegistros FR
	WHERE 
		FR.ContieneMarkupAnterior = 1 AND FR.ContieneMarkupAnteriorEnCero = 0;


	INSERT INTO CO_BitacoraCargaRegistroMarkup(IdContrato,CreadoEl,CreadoPor,MarkupRegistrado,Mensaje,IdArchivoAWS)
	VALUES (@IdContratoSeleccionado,GETDATE(),@IdUsuario,0,@Mensaje,@IdArchivo);
	SELECT @IdCarga	=	SCOPE_IDENTITY() ;

	SELECT @GastosNoEncontrados = COUNT(1) FROM
	 #FilasRegistros WHERE GastoEncontrado = 0; -- NO ENCONTRADOS 

	SELECT @ContieneMarkup = COUNT(1) FROM
	 #FilasRegistros WHERE ContieneMarkupAnterior = 1 AND ContieneMarkupAnteriorEnCero = 0; -- OMITIDOS POR QUE CONTIENEN MARKUP

	 SELECT @PorActualizar = COUNT(1) FROM
	 #FilasRegistros	WHERE LEN(Observacion) = 0; --Por actualizar

	IF(@IdCarga > 0)
	BEGIN
	INSERT INTO CO_BitacoraCargaRegistroMarkupDetalle(IdCarga,FilaExcel,IdRegistroExcel,PorcentajeExcel,TipoCambioExcel ,IdRegistro,Porcentaje,TipoCambio,Detalle,Correcto)
	SELECT @IdCarga, FilaExcel,IdRegistroExcel,PorcentajeExcel,TipoCambioExcel,IdRegistro,Porcentaje,TipoCambio, Observacion, CASE 
																				WHEN 
																					LEN(Observacion)>0
																				THEN 0
																				ELSE 1
																				END
	FROM
		#FilasRegistros

	SELECT 
			@AlertasImportacion	=	 CONCAT(
                                @AlertasImportacion,
			CONCAT(' (FILA: ',FilaExcel,' - ', Detalle,') '))
		FROM CO_BitacoraCargaRegistroMarkupDetalle
		WHERE IdCarga =  @IdCarga AND Correcto = 0;
		

		UPDATE CO_BitacoraCargaRegistroMarkup
		SET DetalleAnalisis = @AlertasImportacion,
			GastosNoEncontrados = @GastosNoEncontrados,
			ContieneMarkup = @ContieneMarkup,
			CorrectosPorActualizar = @PorActualizar
		WHERE Id = @IdCarga;

	END;

	SELECT
		@IdCarga AS IdCarga,
		FilaExcel ,
		IdRegistroExcel,
		PorcentajeExcel,
		TipoCambioExcel,
		Detalle,
		@IdArchivo AS IdArchivoAWS,
		Correcto,
		@GastosNoEncontrados AS GastosNoEncontrados, 
		@ContieneMarkup AS ContieneMarkup, 
		@PorActualizar AS PorActualizar
	FROM 
		CO_BitacoraCargaRegistroMarkupDetalle (NOLOCK)
	where IdCarga	=	@IdCarga ;

END;


