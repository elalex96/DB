-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14-06-18
-- Description:	Consultar detalle de encabezado de aprobación de carta de contenido nacional en procura 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_PR_MM_ListaAprobacionCNDetalle_S3]
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdAceptacionCartaPCN int
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @PROVEEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor AND Activo = 1)

        SELECT '' AS Documento,--0
		 AC.IdAceptacionCartaPCN,--1
		 Ac.IdAceptacionPedido, --2
		 AP.IdPedido, --3
		 AC.IdDocumento, --4
		 Ac.CreadoEl,--5
		ISNULL(SV.VendorName ,AP.IdSubContratista) AS Proveedor, --7
		TD.TipoValidacion, --8
		TD.IdTipoValidacionDoc, --9
		AC.ComentarioEvaluador, --10
		AC.FechaEvaluacion, --11
		U.Nombre,--12
		ISNULL(AC.ComentarioProveedor,'') AS ComentarioProveedor,--13
		D.Identificador,--14
		D.Carpeta,--15
		D.Extension,--16
		AP.IdPedido,
		SES.SESNumber,
		SES.SESReferenceNumber,
		PSES.IdPRESES,
		ISNULL(AC.IdProceso,0) AS IdProceso
		FROM dbo.MPY_MM_AceptacionCartaPCN AS AC
		LEFT JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		LEFT JOIN [dbo].[S_Proveedor] AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
		LEFT JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		LEFT JOIN [dbo].[S_Usuario] as U ON U.IdUsuario = AC.IdUsuarioEvaluador
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer COLLATE Modern_Spanish_CI_AS = AP.IdPedido COLLATE Modern_Spanish_CI_AS AND SES.SESReferenceNumber COLLATE Modern_Spanish_CI_AS = AP.ReferenceNumber COLLATE Modern_Spanish_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber = SES.PO_SAPNumer AND PSES.SAPSESNumber = SES.SESReferenceNumber
		WHERE  --AP.IdProveedor = @PROVEEDORRFC AND 
		AC.IdAceptacionCartaPCN = @IdAceptacionCartaPCN


     END;
