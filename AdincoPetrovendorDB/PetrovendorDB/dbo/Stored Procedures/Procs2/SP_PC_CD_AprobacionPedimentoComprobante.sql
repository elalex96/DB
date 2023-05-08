
-- =============================================
-- Author:	Daniel Cruz
-- Create date: 27-03-18
-- Description:	Consultar encabezado de comprobante EXTRANJERO para procura en aprobación 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PC_CD_AprobacionPedimentoComprobante] 
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdOperacion INT,
@IdContrato INT,
@IdUsuario INT 

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
    -- Insert statements for procedure here
          DECLARE @ES_APROBADOR INT 
		  DECLARE @ID_ESTATUS_APROBADOR INT 
		 
		  ---Validación de Estatus de documentos

		  SELECT 
		  @ES_APROBADOR=T.IdAprobador, 
		  @ID_ESTATUS_APROBADOR = T.IdEstatus
		  FROM dbo.TA_Tarea T
		  INNER JOIN dbo.TA_Operacion O ON O.IdOperacion=T.IdOperacion
		  WHERE O.IdOperacion=@IdOperacion
		  AND T.IdAprobador=@IdUsuario
		
		    SELECT 
			O.IdOperacion,
			PC.IdPedidoGeneral,
			O.Descripcion,
			E.Nombre,
			O.FechaRegistro,	
			P.RazonSocial +' '+ P.RegimenCapital  AS Proveedor,
			P.RFC,
			PC.IdPedimentoComprobante,
			DATEADD(DAY,V.DiaVencimiento,O.FechaRegistro) AS FechaVencimiento,
			PR.Nombre,
			O.IdEstatusOperacion,
			PC.IdContrato AS IdContratoActual,
			U.IdUsuario AS IdAsignador,
			U.Nombre AS Aprobador,
			U.Correo AS CorreoAprobador,
			ISNULL(@ES_APROBADOR,0) AS EsAprobador,
			ISNULL(@ID_ESTATUS_APROBADOR,0) AS IdEstatusAprobador,
			ISNULL(D.IdDocumento,0) AS IdDocumento
			FROM dbo.TA_Operacion O 			
			INNER JOIN dbo.FI_PedimentoComprobante PC ON PC.IdPedimentoComprobante=o.IdDocumento
			INNER JOIN dbo.TA_Estatus E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN dbo.S_Proveedor P ON P.IdProveedor=PC.IdSubcontratistaExportador
			INNER JOIN dbo.TA_Prioridad PR ON PR.IdPrioridad=O.IdPrioridad
			INNER JOIN dbo.TA_Vencimiento V ON V.IdVencimiento=O.IdVigencia
			INNER JOIN dbo.S_Usuario U ON U.IdUsuario=O.IdAsignador
			LEFT JOIN dbo.FI_Documento D ON D.IdPedimentoComprobante=PC.IdPedimentoComprobante
			WHERE 
			PC.TipoOrigen='P_CECD' 
			AND  O.IdTipoOperacion=16
			AND PC.IdSubcontratistaImportador=@IdProveedor
			AND O.IdOperacion=@IdOperacion
			
		 
   END; 


