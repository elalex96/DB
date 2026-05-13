
CREATE PROCEDURE [dbo].[sp_CP_CalculaContraprestacionesPropietarios]
	@IdContrato		INT,
	@Mes			DATE,
	@Usuario		INT
AS
BEGIN
-- =============================================
-- Description:	Proceso de calculo de contraprestaciones a propietarios de la tierra
-- -------------------------------------------------
-- FECHA	MODIFICÓ	COMENTARIO
-- -------------------------------------------------
-- 20180405	BAAC		Creación de sp
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #Propietarios
(
	Mes			DATE,
	IdPropietario	INT,
	M2				FLOAT,
	Porcentaje		FLOAT
)

CREATE TABLE #Contraprestaciones
(
	IdContrato	INT,
	Mes		DATE,
	NumeroContrato	VARCHAR(50),
	CuotaContractual	FLOAT,
	SuperficieKm2	FLOAT,
	TotalCuotaContractual	FLOAT,
	Impuesto	FLOAT,
	TotalImpuesto	FLOAT
)

-- Variables
DECLARE
	@MensajeError VARCHAR(255), -- Mensaje de Error
	@PercepcionComercializaciones MONEY,
	@Ingresos FLOAT,
	@IdContratista	INT,
	@RegaliaBase	FLOAT,
	@RegaliaAdicional	FLOAT,
	@Cuotas	FLOAT,
	@MontoDestinadoAPago	FLOAT,
	@RegistrosActualizados	INT,
	@PorcentajePorTipoIngreso FLOAT,
	@CantPropietarios	INT,
	@GasNoAsociado	BIT

SELECT
	@IdContratista	=	IdContratista,
	@GasNoAsociado	=	ISNULL(GasNoAsociado,0)
FROM
	dbo.CO_Contrato
WHERE
	IdContrato	=	@IdContrato

-- SE OBTIENEN LOS PROPIETARIOS DEL AREA CONTRACTAL
INSERT INTO #Propietarios
(
	Mes,
    IdPropietario,
    M2,
    Porcentaje
)
SELECT
	@Mes,
	PAC.IdPropietario,
	PAC.KM2,
	PAC.KM2/AC.SuperficieKm2
FROM
	dbo.CO_Contrato	C
JOIN
	dbo.CO_AreaContractual	AC
	ON	C.IdAreaContractual	=	AC.IdAreaContractual
JOIN
	CO_PropietariosAreaContractual	PAC
	ON	AC.IdAreaContractual	=	PAC.IdAreaContractual
	AND	PAC.Bit_Activo	=	1
WHERE
	C.IdContrato	=	@IdContrato

SELECT @CantPropietarios = @@ROWCOUNT
-- Verificamos que haya propietarios dados de alta para el area contractual
IF @CantPropietarios = 0
    BEGIN
        SELECT @MensajeError = 'Error: No existen propietarios registrado para el area contractual '+
		'En el Stored Procedure: dbo.sp_CP_CalculaContraprestacionesPropietarios'
        GOTO ERROR
END

/* EL INGRESO DE OBTENDRA DE LAS COMERCIALIZACIONES
Ingreso: La percepción obtenida por el Asignatario o Contratista derivada de la comercialización de los Hidrocarburos extraídos 
del Área de Extracción Comercial de su Área de Asignación o Área Contractual, después de haber descontado los pagos que deban 
realizarse al Fondo Mexicano del Petróleo en términos de la Asignación o Contrato para la Exploración y Extracción de que se trate,
los cuales serán registrados en los estados financieros dictaminados anualmente, de conformidad con lo establecido por el Código Fiscal
de la Federación y su Reglamento
*/

SELECT
	@PercepcionComercializaciones	=	SUM((PrecioVentaUnitario - CostoUnitarioComercializacion) * VolumenVendido)
FROM
	dbo.COM_OperacionComercializacion
WHERE
	IdContrato	=	@IdContrato
	AND
	MesReporte	=	@Mes


-- OBTENER EL MONTO DE LAS CONTRAPRESTACIONES (cuota exploratoria, regalia y regalia adicional)
INSERT INTO #Contraprestaciones
(
	Mes,
	NumeroContrato,
	CuotaContractual,
	SuperficieKm2,
	TotalCuotaContractual,
	Impuesto,
	TotalImpuesto
)
EXEC sp_CP_CalculaCuotaContractualeImpuesto @IdContratista, @Mes, @Mes

UPDATE	CP
	SET IdContrato = C.IdContrato
FROM
	#Contraprestaciones	CP
JOIN	
	dbo.CO_Contrato	C
	ON	CP.NumeroContrato	=	C.NumeroContrato

SELECT
	@RegaliaBase	=	SUM(ROUND(( MCH.TasaRegalia /100)*  (ROUND(MCH.Precio,2) * ISNULL(MCH.Volumen, 0)),2))
FROM
	CP_MetodoCalculoHidrocarburoMes	MCH
WHERE
	MCH.IdContrato = @IdContrato
    AND MCH.Mes = @Mes

SELECT
	@RegaliaAdicional	=	SUM((ISNULL(MCHM.Volumen, 0) * ROUND(ISNULL(MCHM.Precio, 0),2)) * (C.ValorRegaliaAdicional / 100))
FROM
	dbo.CP_MetodoCalculoHidrocarburoMes		MCHM
JOIN
	dbo.CO_Contrato		C
	ON MCHM.IdContrato         = C.IdContrato
WHERE
	MCHM.IdContrato = @IdContrato
	AND MCHM.Mes     = @Mes

SELECT
	@Cuotas	=	ISNULL(TotalCuotaContractual,0)	--+	ISNULL(TotalImpuesto,0)
FROM 
	#Contraprestaciones
WHERE
	IdContrato	=	@IdContrato

SELECT @Ingresos = @PercepcionComercializaciones - (ISNULL(@RegaliaBase,0) + ISNULL(@RegaliaAdicional,0) + ISNULL(@Cuotas,0))

SELECT
	@MontoDestinadoAPago = SUM(@Ingresos * (CASE WHEN @Ingresos BETWEEN PP.MayorA AND PP.MenorIgualA AND PP.BitGasNoAsociado = @GasNoAsociado
										THEN PP.Porcentaje 
										ELSE 0 END/100)),
	@PorcentajePorTipoIngreso	=	SUM(CASE WHEN @Ingresos BETWEEN PP.MayorA AND PP.MenorIgualA AND PP.BitGasNoAsociado = @GasNoAsociado
										THEN PP.Porcentaje 
										ELSE 0 
									END)
FROM
	dbo.CP_PorcContraprestacionesPropietarios	PP
WHERE
	GETDATE()	BETWEEN	PP.IdFechaIni	AND	PP.FechaFin

-- SE ACTUALIZA LA INFORMACION YA GENERADA
UPDATE	H
	SET
		MontoCalculado	=	@MontoDestinadoAPago * P.Porcentaje,
		ModificadoPor	=	@Usuario,
		ModificadoEl	=	GETDATE()
FROM
	CO_HistorialPagos_Propietarios	H
JOIN
	#Propietarios	P
	ON	H.IdPropietario	=	P.IdPropietario
	AND	H.MesPago	=	P.Mes
	
UPDATE LOG_CalculoPagoPropietarios
		SET UsuarioID	=	@Usuario,
			FecMovto	=	GETDATE()
	WHERE
		MesCalculo				=	@Mes
		AND CantPropietarios	=	@CantPropietarios
		AND IngresoBruto		=	@PercepcionComercializaciones
		AND CuotaExploratoria	=	@Cuotas
		AND RegaliaBase			=	@RegaliaBase
		AND RegaliaAdicional	=	@RegaliaAdicional
		AND IngresoNeto			=	@Ingresos
		AND PorcentajeDestinadoPago	=	@PorcentajePorTipoIngreso
		AND MontoDestinadoPago	=	@MontoDestinadoAPago

SELECT @RegistrosActualizados = @@ROWCOUNT

IF @RegistrosActualizados = 0
BEGIN
	INSERT INTO dbo.LOG_CalculoPagoPropietarios
	(
		MesCalculo,
		CantPropietarios,
		IngresoBruto,
		CuotaExploratoria,
		RegaliaBase,
		RegaliaAdicional,
		IngresoNeto,
		PorcentajeDestinadoPago,
		MontoDestinadoPago,
		UsuarioID,
		FecMovto
	)
	SELECT
		@Mes,
		@CantPropietarios,
		@PercepcionComercializaciones,
		@Cuotas,
		@RegaliaBase,
		@RegaliaAdicional,
		@Ingresos,
		@PorcentajePorTipoIngreso,
		@MontoDestinadoAPago,
		@Usuario,
		GETDATE()
END


INSERT INTO CO_HistorialPagos_Propietarios
(
	IdPropietario,
	MesPago,
	MontoCalculado,
	CreadoPor,
	CreadoEl
)
SELECT
	P.IdPropietario,
	@Mes,
	@MontoDestinadoAPago * P.Porcentaje,
	@Usuario,
	GETDATE()
FROM
	#Propietarios	P
LEFT JOIN
	CO_HistorialPagos_Propietarios	H
	ON	P.IdPropietario	=	H.IdPropietario
	AND	P.Mes	=	H.MesPago
WHERE
	H.IdPropietario	IS NULL;


-----------------------------------------------------------------
	--Para  cuadro dibujado en Pantalla
-----------------------------------------------------------------
SELECT ROUND(ISNULL(@PercepcionComercializaciones,0),2) AS IngresoBruto,
       ROUND(ISNULL(@Cuotas,0),2) AS CuotaExploratoria,
       ROUND(ISNULL(@RegaliaBase,0),2) AS Regalia,
      ROUND(ISNULL( @RegaliaAdicional,0),2) AS RegaliaAdicional,
      ROUND((ISNULL(@RegaliaBase,0) + ISNULL(@RegaliaAdicional,0) + ISNULL(@Cuotas,0)),2) AS TotalPagoFMP,
       ROUND(ISNULL(@Ingresos,0),2) AS IngresoNeto,
       ISNULL(@PorcentajePorTipoIngreso,0) AS PorcentajePorTipoIngreso;
-----------------------------------------------------------------
GOTO FIN
    -- -----------------------------------------------------------------------------------------
    ERROR:
    -- -----------------------------------------------------------------------------------------
    RAISERROR(@MensajeError, 16, 1);
    RETURN 1;	-- Error
    -- -----------------------------------------------------------------------------------------
    FIN:
    -- -----------------------------------------------------------------------------------------
    RETURN 0;	

END
