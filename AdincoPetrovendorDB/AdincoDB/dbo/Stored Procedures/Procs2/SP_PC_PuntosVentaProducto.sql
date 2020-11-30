
CREATE PROCEDURE dbo.SP_PC_PuntosVentaProducto
		@IdContrato INT,
		@MesReporte NVARCHAR(50),
		@IdUsuario  INT
AS
BEGIN
-- =============================================
-- Author:		Manuel CD
-- Create date: 25-10-2017
-- Description:	
-- =============================================
-- 20180507	BAAC	Se modifica para insertar los puntos de venta de todos los contratos
-- =============================================
SET NOCOUNT ON
/*Vaciar tabla*/
SET LANGUAGE spanish

CREATE TABLE #Contratos
(
	IdContrato	INT
)

DECLARE  @Fecha	DATE

SELECT @Fecha = CONVERT(DATE,SUBSTRING(@MesReporte,7,4)+SUBSTRING(@MesReporte,4,2)+SUBSTRING(@MesReporte,1,2),112)

INSERT INTO #Contratos
(
    IdContrato
)
SELECT
	IdContrato
FROM
	PC_ContratoCampo
GROUP BY
	IdContrato

DELETE PC_PuntoVentaProducto 
WHERE mes = @Fecha
		--CONVERT(DATE,@MesReporte,112)
--	AND	IdContrato = @IdContrato  
/*Consultar IdContratista*/
--DECLARE @IdContratista INT
--SELECT @IdContratista = CC.IdContratista
--FROM CO_Contratista CC
--    JOIN CO_Contrato C ON CC.IdContratista = C.IdContratista
--WHERE C.IdContrato = @IdContrato  
	
	--DELETE PVP
	--FROM	PC_PuntoVentaProducto	PVP
	--JOIN	PC_DistribucionIngresos	DI
	--	ON	PVP.IdContrato	=	DI.IdContrato
	--	AND	PVP.Mes		=	DATEFROMPARTS( SUBSTRING( DI.MesReporte, 7, 4 ), SUBSTRING( DI.MesReporte, 4, 2 ), 1 )
	--	AND	DI.IdPtoExpedicionRecepcion	=	PVP.IdPtoExpedicionRecepcion
	--JOIN	dbo.CO_Contrato	C
	--	ON	DI.IdContrato	=	C.IdContrato
	--WHERE
	--	PVP.Mes	=	@MesReporte
	--	AND
	--	C.IdContratista	=	@IdContratista
	 
/*Insertar datos al procesar Exceles*/

INSERT INTO [dbo].[PC_PuntoVentaProducto]
    ([IdContrato],
    [Mes],
    [IdPtoExpedicionRecepcion],
    [IdMaterialPC],
    [Aplica],
    [CreadoPor],
    [CreadoEn]
    )
        SELECT DISTINCT
                DI.IdContrato,
                @Fecha,	--DI.MesReporte,
                PV.IdPtoExpedicionRecepcion,
                M.[IdMaterialPC],
                1,
                @IdUsuario,
                GETDATE()
        FROM PC_DistribucionIngresos DI
            LEFT JOIN PC_PtoExpedicionRecepcion PV ON DI.IdPtoExpedicionRecepcion = PV.IdPtoExpedicionRecepcion
            LEFT JOIN PC_Material M ON DI.IdMaterialPC = M.IdMaterialPC
			LEFT JOIN #Contratos	C
				ON	DI.IdContrato	=	C.IdContrato
--		LEFT JOIN dbo.CO_Contrato C ON DI.IdContrato = C.IdContrato
        WHERE DI.MesReporte = @MesReporte 
--		AND C.IdContratista = @IdContratista
		GROUP BY
			DI.IdContrato,
            PV.IdPtoExpedicionRecepcion,
            M.[IdMaterialPC]
END

