-- =============================================
-- Author:		DANIEL AC
-- Create date: 09-04-18
-- Description:	Consultar los comprobantes del proveedor actual 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PC_CD_ConsultarComprobantesExtranjeros]
    -- Add the parameters for the stored procedure here

    @IdUsuario INT,
    @IdProveedor INT,    
	@IdContrato INT, 
	@Estatus INT 
  
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	

	SELECT 
	O.IdOperacion,
	PC.IdPedidoGeneral,
	O.Descripcion,
	E.Nombre,
	O.FechaRegistro,	
	P.RFC,
	P.RazonSocial+' '+ISNULL(P.RegimenCapital,'') AS Proveedor,
	PC.FolioComprobante,
	U.Nombre AS Solicitante,
	AC.NombreAreaContractual AS AreaContractual	
	FROM dbo.TA_Operacion O 	
	INNER JOIN dbo.FI_PedimentoComprobante PC ON PC.IdPedimentoComprobante=o.IdDocumento
	INNER JOIN dbo.TA_Estatus E ON E.IdEstatus = O.IdEstatusOperacion
	INNER JOIN dbo.S_Proveedor P ON P.IdProveedor=PC.IdSubcontratistaExportador
	LEFT JOIN S_Usuario U ON U.IdUsuario=O.IdAsignador
	LEFT JOIN Adinco.dbo.CO_Contrato AS C ON PC.IdContrato = C.IdContrato    
	LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON C.IdAreaContractual = AC.IdAreaContractual
	WHERE  O.IdTipoOperacion=16  AND  PC.TipoOrigen='P_CECD' AND PC.IdSubcontratistaImportador=@IdProveedor 
	AND (E.IdEstatus = @Estatus OR @Estatus = 0) 
	ORDER BY PC.IdPedidoGeneral DESC
	/*DONDE
	PC.TipoOrigen = 'P_CECD' --> PEDIDO COMPROBANTE EXTRANJERO DE COMPRA DIRECTA
	O.IdTipoOperacion = 16 ES APROBACIÓN DE COMPROBANTE EXTRANJERO	
	*/

END;

