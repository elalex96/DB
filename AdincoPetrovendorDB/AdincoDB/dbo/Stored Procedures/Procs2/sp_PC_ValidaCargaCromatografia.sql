
CREATE PROCEDURE dbo.sp_PC_ValidaCargaCromatografia
	@IdContrato INT,
	@MesReporte NVARCHAR(10),
	@IdUsuario  INT
AS
BEGIN
-- ================================================================
-- Modulo:	SCOC --> Comercializacion
-- Objetivo: Mostrar un resumen de la carga de cromatografias
--			 como validación antes de generar las comercializaciones de los hidrocarburos
-- Entradas:	Contrato, Mes reporte y Usuario
-- Salida:	Cromatografia cargada en la tabla PC_AnalisisCromatograficoGas
-- ================================================================
-- 20180727	BAAC	Creación de sp
-- ================================================================
SET NOCOUNT ON
-- ================================================================

SELECT
	PVP.IdPuntoVentaProducto,
    PVP.Mes AS 'Fecha de reporte',
    PV.Denominacion AS 'Punto de venta',
    M.TextoBreve AS 'Producto',
	CASE WHEN ISNULL(CROMA.IdAnalisisCromatograficoGas,0) = 0 THEN 'Falta Cromatografia'
		ELSE 'Cromatografia Cargada'
	END	AS [Estatus],
	CASE WHEN ISNULL(CROMA.IdAnalisisCromatograficoGas,0) = 0 THEN 0
		ELSE 1
	END AS [Cargado]
FROM
	PC_PuntoVentaProducto PVP
JOIN
	PC_PtoExpedicionRecepcion PV 
	ON PVP.IdPtoExpedicionRecepcion = PV.IdPtoExpedicionRecepcion
JOIN
	PC_Material M
	ON PVP.IdMaterialPC = M.IdMaterialPC
	AND M.TextoBreve LIKE '%GAS %'
LEFT JOIN
	dbo.PC_AnalisisCromatograficoGas	CROMA
	ON	PV.IdPtoExpedicionRecepcion	=	CROMA.IdPtoExpedicionRecepcion
	AND	PVP.Mes		=	CROMA.MesReporte
WHERE
	PVP.IdContrato = @IdContrato
    AND CONVERT(VARCHAR(11), Mes, 103) = @MesReporte
GROUP BY
	PVP.IdPuntoVentaProducto,
    PVP.Mes,
    PV.Denominacion,
    M.TextoBreve,
	CASE WHEN ISNULL(CROMA.IdAnalisisCromatograficoGas,0) = 0 THEN 'Falta Cromatografia'
		ELSE 'Cromatografia Cargada'
	END,
	CASE WHEN ISNULL(CROMA.IdAnalisisCromatograficoGas,0) = 0 THEN 0
		ELSE 1
	END
END 

