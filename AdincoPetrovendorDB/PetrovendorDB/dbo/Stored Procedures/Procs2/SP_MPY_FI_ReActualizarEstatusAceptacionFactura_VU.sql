-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017 - UPDATE 13/08/2017
-- Description:	Permite agregar un condicion a un flujo de tareas
-- =============================================
-- Author:		Luis David
-- Create date: 17/06/22
-- Description:	se agrega el nombre del cliente
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_MPY_FI_ReActualizarEstatusAceptacionFactura_VU] 
	-- Add the parameters for the stored procedure here

@IdUsuario int, 
@IdAceptacionPedido int,
@IdOperacion int

 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	


	DECLARE @IdAceptacionFactura int = (SELECT IdAceptacionFactura 
						  FROM MPY_MM_AceptacionFactura 
						  WHERE IdAceptacionPedido = @IdAceptacionPedido)
	DECLARE @ProveedorCliente varchar(500) = (SELECT TOP 1
			 CONCAT (CC.NUMEROCONTRATO,' - ',AC.NOMBREAREACONTRACTUAL)
		  FROM MPY_MM_AceptacionPedido AS AP
			  LEFT JOIN MPY_MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
			  LEFT JOIN MPY_MM_AceptacionCartaPCN AS AC_PCN ON AC_PCN.IdAceptacionPedido = AP.IdAceptacionPedido
			  LEFT JOIN Adinco.dbo.CO_Contrato AS CC ON CAST(AP.IdContrato AS INT) = CC.IdContrato
			  LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
			  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
			  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
			  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CP ON CP.Planta = PO.Plant
			  LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = CP.IdContratista
			  JOIN ADINCO..CO_AREACONTRACTUAL AC ON CC.IDAREACONTRACTUAL = AC.IDAREACONTRACTUAL
		  WHERE 
			AP.IdAceptacionPedido = @IdAceptacionPedido AND AC_PCN.IdEstatus = 2);

	 
	UPDATE MPY_MM_AceptacionFactura 
	SET [IdEstatusXML] = 1,
	[IdEstatusPDF] = 1,
	[ModificadoPor]  = @IdUsuario,
	[ModificadoEl] = getdate(),
	IdEstatus = 1,
	Comentario = NULL
	WHERE IdAceptacionFactura = @IdAceptacionFactura

	UPDATE dbo.MPY_FI_Aprobadores
	SET EstatusAprobacion = NULL
		WHERE IdAceptacionPedido = @IdAceptacionPedido

	DECLARE @IDPRESES INT = (SELECT TOP 1 PSES.IdPRESES
									FROM Adinco.dbo.CO_SAPPRESES AS PSES
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber
										LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
									WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);

		DECLARE @IDSES INT = (SELECT TOP 1 SES.SESNumber
									FROM Adinco.dbo.CO_SAPPRESES AS PSES
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber
										LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
									WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);

		DECLARE @REFERENCE NVARCHAR(100) = (SELECT TOP 1 SES.SESReferenceNumber
									FROM Adinco.dbo.CO_SAPPRESES AS PSES
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber
										LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
									WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);

		DECLARE @PO NVARCHAR(100) = (SELECT TOP 1 SES.PO_SAPNumer
									FROM Adinco.dbo.CO_SAPPRESES AS PSES
										LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber
										LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
									WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);


	SELECT @IdAceptacionFactura AS RESPONSE,
			@IDPRESES,
			@IDSES,
			@REFERENCE,
			@PO,
			@ProveedorCliente

END