-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21-06-2018
-- Description:	Permite agregar un condicion a un flujo de tareas
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_MPY_FI_ActualizarEstatusAceptacionFactura_VU] 
	-- Add the parameters for the stored procedure here

@IdUsuario int, 
@IdAceptacionPedido int 

 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	


	DECLARE @IdAceptacionFactura int = (SELECT IdAceptacionFactura 
						  FROM MPY_MM_AceptacionFactura 
						  WHERE IdAceptacionPedido = @IdAceptacionPedido)

	 
	UPDATE MPY_MM_AceptacionFactura 
	SET [IdEstatusXML] = 1,
	[IdEstatusPDF] = 1,
	[ModificadoPor]  = @IdUsuario,
	[ModificadoEl] = getdate()
	WHERE IdAceptacionFactura = @IdAceptacionFactura

	
	---IdTipoOperacion --> Operación de Aprobación Factura

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
			@PO 

END
 