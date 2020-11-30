
-- =============================================
-- Author:		DANIEL Cruz
-- Create date: 08-02-18
-- Description:	Consultar detalle de encabezado de aprobación de carta de contenido nacional en procura, se agrego valicación de enviar siempre y cuando se solicito en la aceptación
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_GetDocumentoCNN]
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdAceptacionPedido INT,
@IdUsuario INT,
@IdPedido INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
 


        SELECT CONCAT('Carta contenido nacional ',PG.IdPedido,'_',AC.IdAceptacionPedido,'.pdf') AS Documento,--0
			D.Extension, 
			d.Mime,
			D.Carpeta,
			D.Identificador,
			 AC.IdAceptacionCartaPCN,
			 Ac.IdAceptacionPedido, 
			 AP.IdPedido, 
			 AC.IdDocumento,
			TD.TipoValidacion, 
			TD.IdTipoValidacionDoc, 		
			TP.IdTipoPedido			
		FROM [dbo].[MM_AceptacionCartaPCN] AS AC
		INNER JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		INNER JOIN [dbo].[MM_AceptacionPedido] AS AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		INNER JOIN [dbo].[MM_Pedido] AS P ON P.IdPedido = AP.IdPedido
		INNER JOIN [dbo].[S_Proveedor] AS PR ON PR.IdProveedor = P.IdSubcontratista
		INNER JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
		LEFT JOIN [dbo].[S_Usuario] as U ON U.IdUsuario = AC.IdUsuarioEvaluador
		LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN dbo.RelacionCartaCNPedido RCN ON RCN.IdAceptacionPedido = AP.IdAceptacionPedido
		WHERE  
		AC.IdEstatus= 2  --> QUE ESTE APROBADA 
		AND P.IdProveedorCompras = @IdProveedor
		AND  AC.IdAceptacionPedido =@IdAceptacionPedido---AND IdAceptacionCartaPCN=@IdAceptacionCartaPCN
		AND RCN.PedirCarta=1 ---> QUE SE SOLICTO CARTA

     END;

	  
