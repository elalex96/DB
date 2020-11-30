
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05-02-18
-- Description:	Consultar encabezado de aceptación de pedido en genración de carta de contenido nacional
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_PCN_AceptacionCPNProveedorVentas_Cabecera] 
	-- Add the parameters for the stored procedure here
@IdProveedor        NVARCHAR(20),
@IdAceptacionPedido INT

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		 DECLARE @IdEstatusUltimoAprobacionCN INT
    -- Insert statements for procedure here
          
		  ---Validación de Estatus de documentos
		  SET @IdEstatusUltimoAprobacionCN = (SELECT TOP 1 IdEstatus FROM dbo.MPY_MM_AceptacionCartaPCN WHERE IdAceptacionPedido = @IdAceptacionPedido ORDER BY CreadoEl DESC)
		   
		  
		  SELECT 
		  AP.IdAceptacionPedido, --0
		  AP.IdPedido,--1
		  ISNULL(SV.RazonSocial,ISNULL(PR.RazonSocial,AP.IdProveedor)) AS Proveedor,--2
		  ISNULL(AP.PCN_Agregado,0) AS PCN_Agregado, --3
		  ISNULL(AP.DocumentoDescargado,0) AS DocumentoCargado,--4
		  ISNULL(@IdEstatusUltimoAprobacionCN,0) AS Estatus,--5
		  ACO.NombreAreaContractual + ' - ' + COC.NumeroContrato ,--6
		  SES.SESNumber,--7
		  SES.SESReferenceNumber,--8
		  PSES.IdPRESES,--9
		  ISNULL(AC_PCN.Editado,0) AS Editado,--10
		  PRA.IdProveedor
		  FROM dbo.MPY_MM_AceptacionPedido AS AP
			  LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC = AP.IdProveedor AND PR.Activo = 1
			  LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC_PCN ON AC_PCN.IdAceptacionPedido = AP.IdAceptacionPedido
			  LEFT JOIN Adinco.dbo.CO_Contrato AS COC ON COC.IdContrato = CAST(AP.IdContrato AS INT)
			  LEFT JOIN Adinco.dbo.CO_AreaContractual AS ACO ON ACO.IdAreaContractual = COC.IdAreaContractual
			  LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer COLLATE Modern_Spanish_CI_AS = AP.IdPedido COLLATE Modern_Spanish_CI_AS AND SES.SESReferenceNumber COLLATE Modern_Spanish_CI_AS = AP.ReferenceNumber COLLATE Modern_Spanish_CI_AS
			  LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
			  LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber = SES.PO_SAPNumer AND PSES.SAPSESNumber = SES.SESReferenceNumber
			  LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PC ON PC.Planta = PO.Plant
			  LEFT JOIN Adinco.dbo.CO_Contratista AS SV ON SV.IdContratista = PC.IdContratista
			  LEFT JOIN dbo.S_Proveedor AS PRA ON PRA.RFC COLLATE Modern_Spanish_CI_AS = SV.RFC COLLATE Modern_Spanish_CI_AS
		  WHERE AP.IdAceptacionPedido = @IdAceptacionPedido

		     
     END; 


