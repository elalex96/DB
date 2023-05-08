CREATE PROCEDURE [dbo].[sp_SCOC_CalculoServicioRecoleccion]
    @idContrato INT,
    @idUsuario INT,
    @FechaElaboracion DATE,
    @FechaEntrega DATE,
    @NumeroControl NVARCHAR(MAX),
	@MesReporte	DATE,
	@Observaciones	VARCHAR(3000),
	@FirmaGCHC	VARCHAR(3000),
	@FirmaConformidad	VARCHAR(3000),
	@LimpiarFirmas	BIT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:	Genera reporte de Recoleccion de BN
-- =============================================
SET NOCOUNT ON;
SET LANGUAGE SPANISH;


DECLARE
	@TotalBN	FLOAT,
	@RegistrosActualizados	INT


	-- SE OBTIENE EL TOTAL DE BN EN MPC
	SELECT
		@TotalBN	=	SUM( ROUND(ISNULL(MMPC20BN,0)*1000,3) + ROUND(ISNULL(CombustibleMTC,0)*1000,3) + ROUND(ISNULL(CombustibleEC,0)*1000,3) + ROUND(ISNULL(CombustibleCAB,0)*1000,3))
	FROM
		dbo.SCOC_ReporteDiarioGas
	WHERE
		IdContrato	=	@idContrato
		AND
		MesReporte	=	@MesReporte

	SELECT
		'Volumen de Gas Residual Recibido en ' + LTRIM(RTRIM(ISNULL(BN.RecibidoEn,''))) + ' y Entregado al Área Contractual ' + LTRIM(RTRIM(ISNULL(AC.NombreAreaContractual,'')))	AS A9,
		'01 al ' + LTRIM(DAY(EOMONTH(@MesReporte))) + ' de ' + DATENAME(MONTH, @MesReporte) + ' de ' + LTRIM(YEAR(@MesReporte))			AS B14,
		LTRIM(ISNULL(BN.NombreServicio,''))					AS B18,
		FORMAT(ISNULL(@TotalBN,0),'###,###,###.###','en-US')									AS B24,
		LTRIM(ISNULL(@Observaciones,''))					AS F24,
		LTRIM(ISNULL(BN.Transporte,''))						AS F25,
		DATENAME(MONTH, @FechaElaboracion) + ' ' + LTRIM(DAY(@FechaElaboracion)) + ', ' + LTRIM(YEAR(@FechaElaboracion))		AS G3,
		DATENAME(MONTH, @FechaEntrega) + ' ' + LTRIM(DAY(@FechaEntrega)) + ', ' + LTRIM(YEAR(@FechaEntrega))					AS G4,
		ROUND(ISNULL(BN.Costo,0),2)							AS B29,
		ROUND(ISNULL(BN.Costo,0) * (ISNULL(BN.PorcentajeServicioAdmon,0)/100),2)			AS B30,
		LTRIM(RTRIM(ISNULL(BN.TituloGCHC,'')))				AS A50,
        'Representante Comercial'							AS E50,
        'Compañia ' + LTRIM(RTRIM(CO.NombreContratista))	AS E51
	FROM
		SCOC_RecoleccionBN	BN
	JOIN
		dbo.CO_Contrato	C
		ON	BN.IdContrato	=	C.IdContrato
	JOIN
		dbo.CO_Contratista	CO
		ON	C.IdContratista	=	CO.IdContratista
	JOIN
		dbo.CO_AreaContractual	AC
		ON	C.IdAreaContractual	=	AC.IdAreaContractual
	WHERE
		BN.IdContrato	=	@idContrato
		AND
		@MesReporte	BETWEEN	BN.FechaIniVig AND BN.FechaFinVig


	-- SE GUARDAN LOS DATOS EN EL HISTORIAL
	-- SI YA EXISTE UN REGISTRO CON LOS MISMO VALORES, SOLO SE ACTUALIZAN LOS DATOS
	UPDATE	SCOC_RecoleccionBN_Historial
		SET	
			Observaciones	=	LTRIM(ISNULL(@Observaciones,'')),
			TotalBN			=	ROUND(ISNULL(@TotalBN,0),3),
			FechaElaboracion	=	@FechaElaboracion,
			FechaEntrega	=	@FechaEntrega,
			Firma_GCHC		=	LTRIM(ISNULL(@FirmaGCHC,'')),
			Firma_Conformidad	=	LTRIM(ISNULL(@FirmaConformidad,'')),
			ModificadoPor	=	@idUsuario,
			ModificadoEn	=	GETDATE()
	WHERE
		IdContrato	=	@idContrato
		AND
		MesReporte	=	@MesReporte

	SELECT @RegistrosActualizados = @@ROWCOUNT

	-- SI NO SE ACTUALIZO NADA, SE INSERTA LA INFORMACION EN LA TABLA
	IF @RegistrosActualizados = 0
	BEGIN
		INSERT INTO SCOC_RecoleccionBN_Historial
		(
			IdContrato,
			MesReporte,
			Observaciones,
			TotalBN,
			FechaElaboracion,
			FechaEntrega,
			Firma_GCHC,
			Firma_Conformidad,
			CreadoPor,
			CreadoEn
		)
		SELECT
			@idContrato,
			@MesReporte,
			LTRIM(ISNULL(@Observaciones,'')),
			ROUND(ISNULL(@TotalBN,0),3),
			@FechaElaboracion,
			@FechaEntrega,
			LTRIM(ISNULL(@FirmaGCHC,'')),
			LTRIM(ISNULL(@FirmaConformidad,'')),
			@idUsuario,
			GETDATE()
	END

-- SI SE MANDA EL INDICADOR DE LIMPIAR, SE BORRAN LAS FIRMAS QUE ESTEN GUARDADAS EN LA TABLA
IF ISNULL(@LimpiarFirmas,0) = 1
BEGIN
	-- SOLO SE LIMPIAN 
	UPDATE	SCOC_RecoleccionBN_Historial
		SET	
			Firma_GCHC		=	'',
			Firma_Conformidad	=	'',
			ModificadoPor	=	@idUsuario,
			ModificadoEn	=	GETDATE()
	WHERE
		IdContrato	=	@idContrato
		AND
		MesReporte	=	@MesReporte
END

END