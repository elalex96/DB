USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MPY_FI_ActualizarEstatusAceptacionFactura_RF'
)
    DROP PROCEDURE SP_MPY_FI_ActualizarEstatusAceptacionFactura_RF;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16-08-17
-- Description:	Actualiza el estatus de aprobador y de la parobación general  
-- =============================================
-- Author:		Jose Roman
-- Create date: 19-09-2018
-- Description:	Se modifica la aprobacion de factura
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/05/2023
-- Description:	se agrega el filtrado por usuario activo, nolocks y reacomodo de joins
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
	FROM dbo.MPY_MM_AceptacionFactura AS AF (NOLOCK)
		LEFT JOIN dbo.TA_Estatus AS E (NOLOCK)
			ON AF.IdEstatus = E.IdEstatus
			AND AF.IdAceptacionPedido = @IdAceptacionPedido
		LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK)
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV (NOLOCK)
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN dbo.S_Proveedor AS PR (NOLOCK)
			ON SV.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS = PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN dbo.S_UsuarioProveedor AS UP (NOLOCK)
			ON PR.IdProveedor = UP.IdProveedor
		LEFT JOIN dbo.S_Usuario AS US (NOLOCK)
			ON UP.IdUsuario = US.IdUsuario  
			AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4) 
			AND US.Activo = 1
			AND US.IdUsuario IS NOT NULL
		LEFT JOIN Adinco.dbo.CO_Contratista AS CO (NOLOCK)
			ON CO.IdContratista = AP.IdProveedor
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK)
			ON AP.IdPedido COLLATE Modern_Spanish_CI_AS = SES.PO_SAPNumer COLLATE Modern_Spanish_CI_AS 
				AND AP.ReferenceNumber COLLATE Modern_Spanish_CI_AS = SES.SESReferenceNumber COLLATE Modern_Spanish_CI_AS
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK)
			ON SES.PO_SAPNumer = PSES.SAPPONumber
			AND SES.SESReferenceNumber = PSES.SAPSESNumber;
END;




