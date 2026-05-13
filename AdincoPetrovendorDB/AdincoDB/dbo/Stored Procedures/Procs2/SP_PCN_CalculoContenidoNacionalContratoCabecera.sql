
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16/10/2018
-- Description:	Consulta el contenido nacional de un contrato y sus detalles
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_CalculoContenidoNacionalContratoCabecera] --3
	-- Add the parameters for the stored procedure here
	@IDCONTRATO INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END;

     --Insert statements for procedure here
	
	DECLARE @TOTALCN FLOAT;
	DECLARE @TOTALFACTURADO FLOAT;
	DECLARE @CONTRATO NVARCHAR(50);


	CREATE TABLE #MONTOSFACTURA(ValorFactura FLOAT, PCN FLOAT, MontoPCN FLOAT, Fecha DATE, IdFactura INT, SubTotal FLOAT)

	INSERT INTO #MONTOSFACTURA
	SELECT 
		   ISNULL(V.ValorFactura,0) AS ValorFactura,
           ISNULL(ROUND(APD.PCN, 3),0) AS PCN,
		   ISNULL(ROUND(APD.PCN, 3),0) * ISNULL(V.ValorFactura,0) AS MontoPCN,
		   FI.FechaTimbrado,
		   FI.IdFactura,
		   FI.SubTotal
    FROM Petrovendor.dbo.MM_AceptacionPedidoDetalle AS APD
        JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		JOIN Petrovendor.dbo.MM_PCN_ValoresPesos AS V 
		ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle       
        INNER JOIN Petrovendor.dbo.MM_Pedido AS P
            ON P.IdPedido = PD.IdPedido
		LEFT JOIN Petrovendor.dbo.MM_Pedido AS PE ON PE.IdPedido = PD.IdPedido AND AP.IdPedido = PE.IdPedido
		LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
		LEFT JOIN Petrovendor.dbo.FI_Factura AS FI ON FI.IdFactura = AF.IdFactura
    WHERE AF.IdEstatusXML = 2
		AND FI.IdContrato = @IDCONTRATO
	GROUP BY V.ValorFactura,APD.PCN,FI.FechaTimbrado,FI.IdFactura,FI.SubTotal
	ORDER BY FI.FechaTimbrado DESC
	
	SET @TOTALCN = (SELECT
						SUM(MontoPCN) AS MontoPCN
					FROM #MONTOSFACTURA)

	SET @TOTALFACTURADO = (SELECT
								SUM(ValorFactura) AS ValorFactura
							FROM #MONTOSFACTURA)

	SET @TOTALCN = (@TOTALCN / @TOTALFACTURADO)

	DECLARE @TOTALCNMONT FLOAT = (SELECT
									SUM(MontoPCN) AS MontoPCN
								FROM #MONTOSFACTURA);

	SELECT 
		CO.DescripcionContrato,
		COA.NombreAreaContractual,
		CO.FechaFirma,
		CO.InicioVigencia,
		CO.FinVigencia,
		COCT.TipoContratoCorto,
		CO.NumeroContrato,
		(@TOTALCN * 100) AS TOTALCN, 
		@TOTALFACTURADO AS TOTALFACTURADO,
		@TOTALCNMONT AS TOTALMONTCN
	FROM Adinco.dbo.CO_Contrato AS CO
	LEFT JOIN Adinco.dbo.CO_AreaContractual AS COA ON COA.IdAreaContractual = CO.IdAreaContractual
	LEFT JOIN Adinco.dbo.CO_TipoContrato AS COCT ON COCT.IdTipoContrato = CO.IdTipoContrato
	WHERE CO.IdContrato = @IDCONTRATO

	--SELECT 
	--	'CONTRATO PARA LA EXTRACCIÓN DE HIDROCARBUROS EN YACIMIENTOS CONVENCIONALES TERRESTRES BAJO LA MODALIDAD DE LICENCIA ENTRE COMISIÓN NACIONAL DE HIDROCARBUROS, Y PEMEX EXPLORACIÓN Y PRODUCCIÓN, Y PETROLERA CÁRDENAS MORA, S.A.P.I. DE C.V.',
	--	'Cardenas-Mora',
	--	'06/03/2018',
	--	'06/03/2018',
	--	'06/03/2043',
	--	'Licencia',
	--	'CNH-A3.CÁRDENAS-MORA/2018',
	--	92.7884678313021 AS TOTALCN, 
	--	11022905 AS TOTALFACTURADO,
	--	10227984.66 AS TOTALMONTCN
END
