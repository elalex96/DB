-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16-08-17
-- Description:	Actualiza el estatus de aprobador y de la parobación general  
-- =============================================
-- Author:		Jose Roman
-- Create date: 19-09-2018
-- Description:	Se modifica la aprobacion de factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_FI_ActualizarEstatusAceptacionFactura_RF]
    -- Add the parameters for the stored procedure here
    @IdProveedor NVARCHAR(20),
    @Correo NVARCHAR(MAX),
    @IdAceptacionPedido INT,
	@IdAceptacionFactura INT,
    @Comentario NVARCHAR(MAX),
    @IdEstatus INT,
	@IdUsuario INT

AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

		UPDATE dbo.MPY_MM_AceptacionFactura
		SET IdEstatusXML = @IdEstatus,
			IdEstatusPDF = @IdEstatus,
			IdEstatus = @IdEstatus,
			Comentario = @Comentario,
			IdAprobador = @IdUsuario,
			FechaAprobacion = GETDATE()
		WHERE IdAceptacionFactura = @IdAceptacionFactura

		insert into MPY_MM_AceptacionFactura_bitacora(
		IdAceptacionFactura,		IdEstatus,		CreadoPor,			IdEstatusXML,
		IdEstatusPDF,				CreadoEl,		IdAprobadorRechazo,Comentario,
		IdAprobador,				FechaAprobacion
		)
		select @IdAceptacionFactura,@IdEstatus,		@IdUsuario,			@IdEstatus,
		@IdEstatus,					getdate(),		@IdUsuario,			@Comentario,
		@IdUsuario,					getdate()

    
	SELECT 
		AF.IdFactura, 
		AF.IdAceptacionPedido, 
		AF.IdEstatus,
		E.Nombre ,
		US.Nombre,
		US.Correo,
		US.IdUsuario,
		CO.NombreContratista,
		SES.PO_SAPNumer,
		SES.SESNumber,
		PSES.IdPRESES,
		SES.SESReferenceNumber
	FROM dbo.MPY_MM_AceptacionFactura AS AF 
		LEFT JOIN dbo.TA_Estatus AS E ON E.IdEstatus = AF.IdEstatus
		LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = SV.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN dbo.S_UsuarioProveedor AS UP ON UP.IdProveedor = PR.IdProveedor
		LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = UP.IdUsuario AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
		LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = AP.IdProveedor
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer COLLATE Modern_Spanish_CI_AS = AP.IdPedido COLLATE Modern_Spanish_CI_AS AND SES.SESReferenceNumber COLLATE Modern_Spanish_CI_AS = AP.ReferenceNumber COLLATE Modern_Spanish_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber = SES.PO_SAPNumer AND PSES.SAPSESNumber = SES.SESReferenceNumber
	WHERE AF.IdAceptacionPedido = @IdAceptacionPedido
	AND US.IdUsuario IS NOT NULL
	
END;




