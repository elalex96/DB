-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/07/2018
-- Description:	Consulta el contenido nacional de un contrato y sus detalles
-- =============================================
-- Author:		Jose Roman
-- Create date: 14-12-2018
-- Description:	Se toman en cuenta todas las facturas dadas de alta en adinco 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14/05/2019
-- Description: Se modifca  a la logica similar que se usa en adinco para reportes
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_CalculoContenidoNacionalContratoCabecera] --3
	-- Add the parameters for the stored procedure here
	@IDCONTRATO INT,
	@IdPresupuesto INT,
	@Anio INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END;

     --Insert statements for procedure here

	 DECLARE @FECHAINICIO DATE = CAST(@Anio AS NVARCHAR(50)) +'-01-01';
	 DECLARE @FECHAFIN DATETIME = CAST(@Anio AS NVARCHAR(50)) +'-12-01';

	
	DECLARE @TOTALFACTURADO FLOAT;
	DECLARE @TOTALCNMONT FLOAT;
	DECLARE @TOTALCN FLOAT;

	CREATE TABLE #ANEXO3 (
	Codigo NVARCHAR(100),
	Descripcion NVARCHAR(MAX),
	RazonSocial NVARCHAR(MAX),
	RFC NVARCHAR(100),
	Subtotal FLOAT,
	PCN FLOAT,
	CN FLOAT,
	ID INT,
	Repetido INT,
	IdFactura INT
	);

	INSERT INTO #ANEXO3
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

		SET @TOTALFACTURADO = (SELECT SUM(SubTotal) FROM #ANEXO3);

		SET @TOTALCNMONT = (SELECT SUM(CN) FROM #ANEXO3);

		SET @TOTALCN = ((100 * @TOTALCNMONT) / @TOTALFACTURADO);

	SELECT 
		CO.DescripcionContrato,
		COA.NombreAreaContractual,
		CO.FechaFirma,
		CO.InicioVigencia,
		CO.FinVigencia,
		COCT.TipoContratoCorto,
		CO.NumeroContrato,
		ISNULL(@TOTALCN,0) AS TOTALCN, 
		ISNULL(@TOTALFACTURADO,0) AS TOTALFACTURADO,
		ISNULL(@TOTALCNMONT,0) AS TOTALMONTCN,
		(100 - @TOTALCN) AS CNRESTANTE,
		ROUND(ISNULL((@TOTALFACTURADO - @TOTALCNMONT),0),2) AS MONTOSINCN
	FROM Adinco.dbo.CO_Contrato AS CO
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS COA ON COA.IdAreaContractual = CO.IdAreaContractual
		LEFT JOIN Adinco.dbo.CO_TipoContrato AS COCT ON COCT.IdTipoContrato = CO.IdTipoContrato
	WHERE CO.IdContrato = @IDCONTRATO;

END


