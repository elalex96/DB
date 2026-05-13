-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/05/2019
-- Description:	Consulta de lo facturaDO por proveedor de CN
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_RPT_ContenidoNacionalProveedor] --3,3
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdPresupuesto INT,
	@Anio INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FECHAINICIO DATE = CAST(@Anio AS NVARCHAR(50)) +'-01-01';
	 DECLARE @FECHAFIN DATETIME = CAST(@Anio AS NVARCHAR(50)) +'-12-01';

	--ANEXO 3
	DECLARE @TOTALFACTURADO FLOAT;
	DECLARE @TOTALCNMONT FLOAT;
	DECLARE @TOTALCN FLOAT;

    SELECT ISNULL(A.Codigo, 'SinClasificar') AS Codigo, 
           R.Comentarios AS Descripcion, 
           S.RazonSocial AS RazonSocial, 
           S.RFC AS RFC, 
           SUM(CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))) AS SubTotal, 
           ISNULL(R.PCN, 0) AS PCN, 
           SUM(CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2))) AS CN,  
           ROW_NUMBER() OVER(ORDER BY F.IdFactura) AS ID, 
           ROW_NUMBER() OVER(PARTITION BY F.IdFactura, 
           S.RFC ORDER BY R.Comentarios) AS Repetido, 
           F.IdFactura
	 INTO #MONTOSPROVEEDORES
     FROM Adinco.dbo.CO_Registro R
                      JOIN Adinco.dbo.CO_LineaPresupuestoMes L ON L.IdLineaPresupuestoMes = R.IdPrograma
					  JOIN Adinco.dbo.CO_Presupuesto P ON P.IdPresupuesto = L.IdPresupuesto
                      JOIN Adinco.dbo.CO_ProgramaActividad PA ON PA.IdProgramaActividad = P.IdProgramaActividad
                      JOIN Adinco.dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = PA.IdTipoProgramaActividad
                      LEFT JOIN Adinco.dbo.CO_PCNPorPeriodos PPP ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
                      LEFT JOIN Adinco.dbo.FI_Factura F ON F.IdFactura = R.IdFactura
                      LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCD ON F.IdMoneda <> TCD.IdMoneda
                                                               AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                               AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                               AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                      LEFT JOIN Adinco.dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
                      LEFT JOIN Adinco.dbo.MM_BS_Actividad A ON R.IdCBSISH = A.IdActividad
                      LEFT JOIN Adinco.dbo.CO_Servicio SE ON SE.IdServicio = L.IdServicio
                 WHERE 
                       (F.Fecha >= @FECHAINICIO
                            AND F.Fecha <= EOMONTH(@FECHAFIN))
                       AND R.IdGastoRubro = 3 
                       AND F.IdContrato = @IdContrato
                       AND ISNULL(R.PCN,0) <> 0
                 AND PPP.IdContrato = @IdContrato
                 GROUP BY ISNULL(A.Codigo, 'SinClasificar'), 
                          R.Comentarios, 
                          S.RazonSocial, 
                          S.RFC, 
                          CAST(ROUND((ISNULL(R.MontoRegistro, 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 
                          ISNULL(R.PCN, 0), 
                          CAST(ROUND((ISNULL((ISNULL(R.PCN, 0) * R.MontoRegistro), 0) * TCD.TipoCambio), 2) AS DECIMAL(15, 2)), 
                          F.IdFactura
                 ORDER BY S.RFC;


	SET @TOTALFACTURADO = (SELECT SUM(SubTotal) FROM #MONTOSPROVEEDORES);

	SELECT
		RFC,
		RazonSocial,
		(SELECT SUM(MN.SubTotal) FROM #MONTOSPROVEEDORES AS MN  WHERE MN.RFC = PR.RFC) AS TotalFacturadoProveedor,
		(SELECT SUM(MN.CN) FROM #MONTOSPROVEEDORES AS MN  WHERE MN.RFC = PR.RFC) AS CNFacturadoProveedor,
		ROUND((((SELECT SUM(MN.CN) FROM #MONTOSPROVEEDORES AS MN  WHERE MN.RFC = PR.RFC) * 100)/ @TOTALFACTURADO),4) AS PorcentajeCNProveedor
	FROM #MONTOSPROVEEDORES AS PR
	GROUP BY PR.RFC,
             PR.RazonSocial

END