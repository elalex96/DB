-- =============================================
-- Author:	Daniel Cruz
-- Create date: 27-03-18
-- Description:	Consultar encabezado de pedimento actual
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PC_CD_ConsultarEncabezadoPedimentoComprobante] 
	-- Add the parameters for the stored procedure here
@IdProveedor        INT,
@IdPedidoComprobante INT,
@IdContrato INT

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
    -- Insert statements for procedure here
         
		 SELECT 
		 IdPedimentoComprobante,
		 IdContrato,
		 NumeroPedimento,
		 CAST(ISNULL(CP.Clave,'') AS NVARCHAR(50))+' '+ CP.Descripcion  AS ClavePedimento,
		 FolioComprobante,
		 FechaPago,
		 PC.Regimen,
		 SI.RazonSocial +' ' + SI.RegimenCapital AS IMPORTADOR,
		 SE.RazonSocial +' ' + SE.RegimenCapital AS EXPORTADOR,
		 TM.TipoMonedaCorto,
		 FP.Nombre AS FormaPago,
		 PC.AcuseElectronico,
		 CASE WHEN  PC.CvTipoDocFacturacion = 2 THEN 
		 'Pedimento de Importación'
		 WHEN  PC.CvTipoDocFacturacion = 3 THEN 
		 'Comprobante Extranjero'
		 END AS CvTipoDocFacturacion,
		 PC.AduanaES AS Aduana
		 FROM dbo.FI_PedimentoComprobante PC
		 LEFT JOIN dbo.S_Proveedor SI ON SI.IdProveedor=PC.IdSubcontratistaImportador
		 LEFT JOIN dbo.S_Proveedor SE ON SE.IdProveedor = PC.IdSubcontratistaExportador
		 LEFT JOIN dbo.PV_TipoMoneda TM ON TM.IdMoneda =PC.IdMoneda
		 LEFT JOIN Adinco.dbo.AP_Lista FP ON FP.IdClave= PC.IdFormaPago AND FP.IdGrupo = 10001  -- CTE DE ADINCO 
		 LEFT JOIN Adinco.dbo.FI_ClavesPedimento  CP ON CP.IdPedimento=PC.ClavePedimento
		 WHERE IdPedimentoComprobante=@IdPedidoComprobante AND PC.IdContrato=@IdContrato 
 
END; 


 