-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20-06-2018
-- Description:	Actualice sp para mostrar tipo de pedido 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_PR_MM_PCN_AceptacionFacturaProveedorVentas_Cabecera] --44, 2241
	-- Add the parameters for the stored procedure here consultarEncabezadoAceptacionFacturaDetalle
@IdProveedor        INT,
@IdAceptacionPedido INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE @COMENTARIO_CANCELACION NVARCHAR(MAX) =''

		DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor)

		SET @COMENTARIO_CANCELACION = (SELECT Comentario FROM dbo.MPY_MM_AceptacionFactura WHERE IdAceptacionPedido = @IdAceptacionPedido AND IdEstatus = 3 AND Comentario IS NOT NULL)

		  SELECT TOP 1
			  AP.IdAceptacionPedido, --0
			  AP.IdPedido, --1
			  AP.NombreRecibidoPor,--2 
			  AP.NombreUsuarioEntrega,--3
			  AP.Creado,--4
			  ISNULL(CO.RazonSocial,AP.IdProveedor) AS Proveedor,--5
			  ISNULL(AP.PCN_Agregado,0) AS PCN_Agregado, --6
			  ISNULL(AP.DocumentoDescargado,0) AS DocumentoCargado,--7 
			  ISNULL(AF.IdEstatus,4) AS IdEstatusOperacion,--8
			  CO.RFC,--9
			  ISNULL(AF.IdEstatusXML,4) AS IdEstatusXML,--10
			  ISNULL(AF.IdEstatusPDF,4) AS IdEstatusPDF,--11
			  ISNULL(AC_PCN.IdEstatus,0) AS Estatus,--12
			  AF.ModificadoEl,--13
			  @COMENTARIO_CANCELACION,--14
			  SES.SESNumber,
			  SES.SESReferenceNumber,
			  PSES.IdPRESES
		  FROM MPY_MM_AceptacionPedido AS AP
			  LEFT JOIN MPY_MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			  LEFT JOIN MPY_MM_AceptacionCartaPCN AS AC_PCN ON AC_PCN.IdAceptacionPedido = AP.IdAceptacionPedido
			  LEFT JOIN Adinco.dbo.CO_Contrato AS CC ON CAST(AP.IdContrato AS INT) = CC.IdContrato
			  LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
			  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
			  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
			  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CP ON CP.Planta = PO.Plant
			  LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = CP.IdContratista
		  WHERE 
			AP.IdAceptacionPedido = @IdAceptacionPedido AND AC_PCN.IdEstatus = 2
		  GROUP BY 
			  AP.IdAceptacionPedido, 
			  AP.IdPedido, 
			  AP.NombreRecibidoPor, 
			  AP.NombreUsuarioEntrega,
			  AP.Creado,
			  AP.PCN_Agregado,
			  AP.DocumentoDescargado,
			  AC_PCN.IdEstatus,
			  AF.IdEstatusXML,
			  AF.IdEstatusPDF,
			  AF.IdEstatus,
			  AF.ModificadoEl,
			  AP.IdProveedor,
			  CO.RazonSocial,
			  CO.RFC,
			  SES.SESNumber,
			  SES.SESReferenceNumber,
			  PSES.IdPRESES
     END

	 