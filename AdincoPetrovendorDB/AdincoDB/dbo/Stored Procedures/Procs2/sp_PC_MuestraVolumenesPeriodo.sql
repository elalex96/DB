CREATE PROCEDURE dbo.sp_PC_MuestraVolumenesPeriodo
	@IdContrato INT,
	@MesReporte NVARCHAR(10),
	@IdUsuario  INT
AS
BEGIN
-- ================================================================
-- Modulo:	SCOC --> Comercializacion
-- Objetivo: Mostrar un resumen de los volumenes registrados por periodo
--			 como validación antes de geenrar las comercializaciones de los hidrocarburos
-- Entradas:	Contrato, Mes reporte y Usuario
-- Salida:	Volumenes registrados en la tabla PC_VolumenProduccionPeriodo
-- ================================================================
-- 20180727	BAAC	Creación de sp
-- ================================================================
SET NOCOUNT ON

SET LANGUAGE Español

-- SI EL CONTRATO ES DE PRODUCCION COMPARTIDASE MUESTRAN LOS VOLUMENES POR PERIODO
IF 2 = (SELECT ISNULL(IdTipoContrato,0) 
			FROM dbo.CO_Contrato
			WHERE IdContrato = @IdContrato)
BEGIN
		SELECT
			C.NumeroContrato	AS [Contrato],
			CONVERT(VARCHAR(11), VPP.FechaInicio, 106) + ' - ' + CONVERT(VARCHAR(11), VPP.FechaFin, 106)		AS [Periodo],
			VPP.VolumenPetroleoPuntoMedicion	AS [Petroleo],
			VPP.GradosAPI						AS [GradosAPI],
			VPP.ContenidoAzufre					AS [Azufre],
			VPP.MetanoC1,
			VPP.EtanoC2,
			VPP.PropanoC3,
			VPP.ButanoC4,
			VPP.VolumenCondensadoPuntoMedicion	AS [Condensado],
			VPP.VolumenCondensablePuntoMedicion	AS [Condensable]
		FROM
			dbo.CO_Contrato	C
		JOIN
			PC_VolumenProduccionPeriodo	VPP
			ON	C.IdContrato	=	VPP.IdContrato
		WHERE
			C.IdContrato	=	@IdContrato
			AND
			CONVERT(VARCHAR(11), VPP.MesReporte, 103)	=	@MesReporte
		ORDER BY
			VPP.FechaInicio
END
ELSE -- ES UN CONTRATO DE LICENCIA
BEGIN
		SELECT
			C.NumeroContrato	AS [Contrato],
			CONVERT(VARCHAR(11), VPP.MesReporte, 106) + ' - ' + CONVERT(VARCHAR(11), (DATEADD(DAY,-1,DATEADD(MONTH,1,VPP.MesReporte))), 106)		AS [Periodo],
			VPP.VolumenPetroleoPuntoMedicion	AS [Petroleo],
			VPP.GradosAPI						AS [GradosAPI],
			VPP.ContenidoAzufre					AS [Azufre],
			VPP.MetanoC1,
			VPP.EtanoC2,
			VPP.PropanoC3,
			VPP.ButanoC4,
			VPP.VolumenCondensadoPuntoMedicion	AS [Condensado],
			VPP.VolumenCondensablePuntoMedicion	AS [Condensable]
		FROM
			dbo.CO_Contrato	C
		JOIN
			PR_VolumenMensualProduccionPetroleo	VPP
			ON	C.IdContrato	=	VPP.IdContrato
			AND ISNULL(VPP.Activo,0) = 1
		WHERE
			C.IdContrato	=	@IdContrato
			AND
			CONVERT(VARCHAR(11), VPP.MesReporte, 103)	=	@MesReporte
			AND ISNULL(VPP.Activo,0) = 1
		ORDER BY
			VPP.MesReporte
END

END
