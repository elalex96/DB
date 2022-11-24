-- =============================================  
-- Author:  <Jose Roman>  
-- Create date: <04-12-2018>  
-- Description: <Se consultan los complementos por factura>  
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: <05/07/2020>  
-- Description: <se omite el filtro de pdf ativo ya que no es necesario el pdf en el complemento>  
-- =============================================  
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 22/10/2021
-- Description:	Se contemplan los complementos de adinco
-- =============================================
CREATE PROCEDURE [dbo].[FI_SP_ConsultaComplementosPorFactura] --20507
 @IdFactura INT,  
 /*---------------------Parametros contrato---------------------*/  
 @IdContrato INT = NULL,  
 @IdUsuario INT = NULL,  
 @FechaRegistro DATETIME = NULL   
 /*---------------------Parametros contrato---------------------*/  
AS  
BEGIN  

	DECLARE @UUIDFACTURA NVARCHAR(1000) = (SELECT UUID FROM dbo.FI_Factura WHERE IdFactura = @IdFactura);
	DECLARE @IDFACTURAADINCO INT = (SELECT IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUIDFACTURA);

	 --COMPLEMENTOS DE PETRO
	 SELECT 
	   fc.IdComplemento,  
	   f.IdFactura,  
	   f.MontoConIva AS SubTotal,  
	   fc.MontoPagado,  
	   f.MontoConIva - fc.MontoPagado AS MontoRemanente,  
	   ISNULL(pdf.IdPDFComplemento, 0) AS IdPDF,
	   CPF.UUID,
	   1 AS IsPetro
	 INTO #COMPLEMENTOS
	 FROM Petrovendor.dbo.FI_FacturaComplemento fc  
		INNER JOIN Petrovendor.dbo.FI_Factura f 
			ON f.IdFactura = fc.IdFactura  
		LEFT JOIN Petrovendor.dbo.FI_PDFComplemento pdf 
			ON pdf.IdFacturaComplemento = fc.IdFacturaComplemento  
		LEFT JOIN Petrovendor.dbo.FI_ComplementoDePago AS CP
			ON fc.IdComplemento =  CP.IdFactura
		LEFT JOIN Petrovendor.dbo.FI_Factura AS CPF
			ON CP.IdFactura = CPF.IdFactura
	 WHERE fc.IdFactura = @IdFactura  
--		AND fc.IsEliminado is null
		AND f.Activa = 1
--		AND pdf.EliminadoPor IS NULL

	--COMPLEMENTOS DE ADINCO
	INSERT INTO #COMPLEMENTOS
	SELECT
		CP.IdComplementoDePago,
		F.IdFactura,
		F.MontoConIva,
		CPDR.ImpPagado,
		(F.MontoConIva - CPDR.ImpPagado),
		0,
		FCP.UUID,
		0
	FROM Adinco.dbo.FI_CPDocRelacionado AS CPDR
	JOIN Adinco.dbo.FI_ComplementoDePago AS CP ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
	JOIN Adinco.dbo.FI_Factura AS FCP ON CP.IdFactura = FCP.IdFactura
	JOIN Adinco.dbo.FI_Factura AS F ON F.UUID = CPDR.IdDocumento
	WHERE CPDR.IdDocumento = @UUIDFACTURA
		AND FCP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS NOT IN (SELECT UUID FROM #COMPLEMENTOS);--PARA NO REPETIR COMPLEMENTOS QUE YA ESTAN EN PETRO

	SELECT * FROM #COMPLEMENTOS;

END